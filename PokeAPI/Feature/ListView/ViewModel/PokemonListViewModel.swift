//
//  PokemonListViewModel.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import SwiftUI
internal import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
	@Published private(set) var pokemons: [DataModel] = []
	@Published var searchText: String = ""
	@Published private(set) var isLoading: Bool = false
	@Published private(set) var errorMessage: String?
    
    private var isPaginating = false
    
    private var filteredRetryCount = 0

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

	init(api: APIManagerProtocol? = nil, pageSize: Int = 20) {
		self.api = api ?? APIManager()
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
		if let lastPokemon = pokemons.last, lastPokemon.id == item.id {
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

        if isLoading { return }
        isLoading = true

        Task { [weak self] in
            guard let self else { return }

            do {
                let page = try await api.fetchPokemonPage(offset: offset, limit: pageSize)
                let newPokemons = page.pokemons.map { DataModel(from: $0) }

                await MainActor.run {
                    self.pokemons.append(contentsOf: newPokemons)
                    self.nextOffset = page.nextOffset
                    self.totalCount = page.totalCount
                    self.isLoading = false
                }

            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadNextPageCheckSearchActive(currentItem: DataModel) {
        guard !isPaginating else { return }
        isPaginating = true
        
        Task {
            if searchText.isEmpty {
                loadNextPageIfNeeded(currentItem: currentItem)
            } else {
                await loadMoreFilteredPokemon()
            }
            
            isPaginating = false
        }
    }
    
    func loadMoreFilteredPokemon() async {
        guard let offset = nextOffset else { return }
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        var collected: [DataModel] = []
        var localOffset = offset

        while collected.count < 20 {

            do {
                let page = try await api.fetchPokemonPage(offset: localOffset, limit: pageSize)

                let query = searchText.lowercased()

                let matches = page.pokemons
                    .map { DataModel(from: $0) }
                    .filter { pokemon in
                        pokemon.name.lowercased().contains(query) ||
                        pokemon.types.contains { $0.lowercased().contains(query) }
                    }

                collected.append(contentsOf: matches)

                guard let next = page.nextOffset else { break }

                localOffset = next

                if page.pokemons.count < pageSize { break }

            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                isLoading = false
                return
            }
        }

        pokemons.append(contentsOf: collected)

        nextOffset = localOffset
        isLoading = false
    }
    
    private func shouldLoadMoreFiltered(currentItem: DataModel) -> Bool {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard nextOffset != nil else { return false }
        guard !isLoading else { return false }
        return filteredPokemons.last?.id == currentItem.id
    }
    
    func clearError() {
        errorMessage = nil
    }
}

