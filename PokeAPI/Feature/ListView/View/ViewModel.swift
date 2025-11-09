//
//  ViewModel.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import SwiftUI
internal import Combine

@MainActor
final class ViewModel: ObservableObject {
	@Published var data: [DataModel] = []
	@Published var searchText: String = ""
	
	var filteredData: [DataModel] {
        
        guard !searchText.isEmpty else { return data }
        var results: [DataModel] = []
        var available = data
        
        available.forEach { item in
            if item.name.lowercased().contains(searchText.lowercased()) {
                results.append(item)
                available.removeAll { $0.id == item.id }
            }
        }
        
        available.forEach { item in
            if item.types.contains(where: { $0.lowercased().contains(searchText.lowercased()) }) {
                results.append(item)
                available.removeAll { $0.id == item.id }
            }
        }
        
		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		guard !query.isEmpty else { return data }

		return data.filter { item in
			let nameMatches = item.name.lowercased().contains(query)
			let typeMatches = item.types.contains { $0.lowercased().contains(query) }
			return nameMatches || typeMatches
		}
	}
	
	private let api: APIManagerProtocol
	
	init(api: APIManagerProtocol = APIManager()) {
		self.api = api
	}
	
	func handleOnAppear() {
		Task { @MainActor in
			await fetchData()
		}
	}
	
	@MainActor func fetchData() async {
		do {
            let page = try await api.fetchPokemonPage(offset: 0, limit: 20)
            let newData = page.pokemons.map { DataModel(from: $0) }
			
			await MainActor.run {
				self.data = newData
			}
		} catch {
			print(error)
		}
	}

    func shouldLoadMoreFiltered(currentItem: DataModel) -> Bool {
        guard !searchText.isEmpty else { return false }
        return filteredData.last?.id == currentItem.id
    }

    @MainActor
    func fetchMoreFilteredPokemon() async {
        do {
            let nextOffset = data.count
            let page = try await api.fetchPokemonPage(offset: nextOffset, limit: 20)

            let q = searchText.lowercased()

            let newMatches = page.pokemons
                .map { DataModel(from: $0) }
                .filter { pokemon in
                    let nameMatches = pokemon.name.lowercased().contains(q)
                    let typeMatches = pokemon.types.contains { $0.lowercased().contains(q) }
                    return nameMatches || typeMatches
                }

            self.data.append(contentsOf: newMatches)

        } catch {
            print(error)
        }
    }
    
    @MainActor
    func loadNextPageIfNeeded(currentItem: DataModel) {
        guard let last = data.last else { return }
        guard last.id == currentItem.id else { return }

        Task {
            do {
                let nextOffset = data.count
                let page = try await api.fetchPokemonPage(offset: nextOffset, limit: 20)
                let newModels = page.pokemons.map { DataModel(from: $0) }

                await MainActor.run {
                    self.data.append(contentsOf: newModels)
                }
            } catch {
                print(error)
            }
        }
    }
    
}

