//
//  PokemonSpeciesResponse.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//


struct PokemonSpeciesResponse: Decodable {

    struct FlavorTextEntry: Decodable {
        struct Language: Decodable {
            let name: String
            let url: String
        }

        struct Version: Decodable {
            let name: String
            let url: String
        }

        let flavorText: String
        let language: Language
        let version: Version

        enum CodingKeys: String, CodingKey {
            case flavorText = "flavor_text"
            case language
            case version
        }
    }

    let flavorTextEntries: [FlavorTextEntry]

    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
    }
}
