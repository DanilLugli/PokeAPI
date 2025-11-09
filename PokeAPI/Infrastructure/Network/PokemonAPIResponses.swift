//
//  PokemonListResponse.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import Foundation

struct PokemonListResponse: Decodable {
    struct Result: Decodable {
        let name: String
        let url: URL
    }

    let count: Int
    let next: String?
    let previous: String?
    let results: [Result]
}

struct PokemonDetailResponse: Decodable {
    
    struct Sprite: Decodable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
    
    struct TypeEntry: Decodable {
        struct TypeInfo: Decodable {
            let name: String
            let url: URL
        }
        
        let slot: Int
        let type: TypeInfo
    }
    
    struct AbilityEntry: Decodable {
        struct AbilityInfo: Decodable {
            let name: String
            let url: URL
        }
        
        let ability: AbilityInfo
        let is_hidden: Bool?
        let slot: Int?
    }
    
    let id: Int
    let name: String
    let sprites: Sprite
    let types: [TypeEntry]
    let abilities: [AbilityEntry]
}

