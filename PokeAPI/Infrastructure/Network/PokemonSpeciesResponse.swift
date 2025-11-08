//
//  PokemonSpeciesResponse.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//


struct PokemonSpeciesResponse: Decodable {
    let flavorTextEntries: [FlavorTextEntry]

    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
    }

    struct FlavorTextEntry: Decodable {
        let flavorText: String
        let language: NamedAPIResource

        enum CodingKeys: String, CodingKey {
            case flavorText = "flavor_text"
            case language
        }
    }
}