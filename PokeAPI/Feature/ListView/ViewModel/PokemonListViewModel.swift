import SwiftUI
internal import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
	@Published private(set) var pokemons: [DataModel] = []
	@Published var searchText: String = ""
	@Published private(set) var isLoading: Bool = false
	@Published private(set) var errorMessage: String?

	var filteredPokemons: [DataModel] {
		let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedQuery.isEmpty else { return pokemons }
		let lowercasedQuery = trimmedQuery.lowercased()
		return pokemons.filter { pokemon in
			pokemon.name.lowercased().contains(lowercasedQuery) ||
			pokemon.types.contains { $0.lowercased().contains(lowercasedQuery) }
		}
	}
    
	private let api: APIManagerProtocol
	private let pageSize: Int
	private var nextOffset: Int?
	private var totalCount: Int = 0

	init(api: APIManagerProtocol = APIManager(), pageSize: Int = 20) {
		self.api = api
		self.pageSize = pageSize
		self.nextOffset = 0
	}

	func loadInitial() {
		nextOffset = 0
		pokemons = []
		totalCount = 0
		errorMessage = nil
		loadNextPage()
	}

	func loadNextPageIfNeeded(currentItem item: DataModel?) {
		guard shouldAttemptPagination else { return }
		guard let item else {
			loadNextPage()
			return
		}
		let thresholdIndex = pokemons.index(pokemons.endIndex, offsetBy: -5, limitedBy: pokemons.startIndex) ?? pokemons.startIndex
		if let currentIndex = pokemons.firstIndex(where: { $0.id == item.id }), currentIndex >= thresholdIndex {
			loadNextPage()
		}
	}

	private var shouldAttemptPagination: Bool {
		guard errorMessage == nil else { return false }
		guard !isLoading else { return false }
		guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        if nextOffset != nil { return totalCount == 0 || pokemons.count < totalCount }
		return false
	}

	private func loadNextPage() {
		guard let offset = nextOffset else { return }
		isLoading = true
		errorMessage = nil

		Task {
			do {
				let page = try await api.fetchPokemonPage(offset: offset, limit: pageSize)
                let newPokemons = page.pokemons.map { DataModel(from: $0) }
                await MainActor.run {
					pokemons.append(contentsOf: newPokemons)
					nextOffset = page.nextOffset
					totalCount = page.totalCount
					isLoading = false
				}
			} catch {
				await MainActor.run {
					errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
					isLoading = false
				}
			}
		}
	}
    
    private func shouldLoadMoreFiltered(currentItem: DataModel) -> Bool {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return filteredPokemons.last?.id == currentItem.id
    }
    
    @MainActor
    private func loadMoreFilteredPokemon() async {
        guard let offset = nextOffset else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let page = try await api.fetchPokemonPage(offset: offset, limit: pageSize)

                let q = searchText.lowercased()

                let filtered = page.pokemons
                    .map { DataModel(from: $0) }
                    .filter { pokemon in
                        pokemon.name.lowercased().contains(q) ||
                        pokemon.types.contains { $0.lowercased().contains(q) }
                    }

                await MainActor.run {
                    pokemons.append(contentsOf: filtered)
                    nextOffset = page.nextOffset
                    totalCount = page.totalCount
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}


