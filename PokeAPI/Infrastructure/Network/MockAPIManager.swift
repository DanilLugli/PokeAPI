//
//  MockAPIManager.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

class MockAPIManager: APIManagerProtocol {

    var toThrow: Error?
    var queuedPages: [PokemonPageDTO]

    init(pages: [PokemonPageDTO] = [
        PokemonPageDTO(
            pokemons: [
                NWDataModel(
                    id: 1,
                    name: "Bulbasaur",
                    types: [
                        NWType(name: "grass"),
                        NWType(name: "poison")
                    ],
                    description: "A strange seed was planted on its back at birth.",
                    imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
                )
            ],
            nextOffset: nil,
            totalCount: 1
        )
    ]) {
        self.queuedPages = pages
    }

    func fetchPokemonPage(offset: Int, limit: Int) async throws -> PokemonPageDTO {
        if let toThrow {
            throw toThrow
        }

        guard !queuedPages.isEmpty else {
            return PokemonPageDTO(pokemons: [], nextOffset: nil, totalCount: 0)
        }

        return queuedPages.removeFirst()
    }
}
