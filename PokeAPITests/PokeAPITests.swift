//
//  PokeAPITests.swift
//  PokeAPITests
//
//  Created by Danil Lugli on 11/6/25.
//

import Testing
@testable import PokeAPI
internal import Foundation

struct PokeAPITests {

    @Test func testFetchPokemonPage() async throws {
        let api = await APIManager()
        let page = try await api.fetchPokemonPage(offset: 0, limit: 20)

        #expect(page.pokemons.count == 20)
        #expect(page.totalCount > 0)
        #expect(page.nextOffset != nil)
    }
    
    @Test func testPokemonDetails() async throws {
        let api = await APIManager()
        let page = try await api.fetchPokemonPage(offset: 0, limit: 1)
        let bulbasaur = await page.pokemons.first!

        #expect(bulbasaur.name == "Bulbasaur")
        #expect(!bulbasaur.types.isEmpty)
        #expect(bulbasaur.imageURL?.contains("png") ?? true)
    }
    
    @Test @MainActor func testViewModelInitialLoad() async throws {
        let vm = await PokemonListViewModel(api: APIManager())

        await vm.loadInitial()

        try? await Task.sleep(nanoseconds: 2_000_000_000)

        #expect(vm.pokemons.count > 0)
        #expect(vm.nextOffset != nil)
        #expect(vm.isLoading == false)
    }

    @Test @MainActor func testSearchFiltering() async throws {
        let vm = PokemonListViewModel(api: APIManager())

        await vm.loadInitial()

        vm.searchText = "bulb"

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(vm.filteredPokemons.contains { $0.name == "Bulbasaur" })
        #expect(vm.filteredPokemons.count > 0)
    }

    @Test @MainActor func testSpeciesDescriptionExists() async throws {
        let api = APIManager()

        let page = try await api.fetchPokemonPage(offset: 0, limit: 1)
        let bulbasaur = page.pokemons[0]

        #expect(bulbasaur.description != nil)

        #expect(bulbasaur.description!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
    }
}
