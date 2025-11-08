//
//  NWDataModel.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import Foundation

struct NWDataModel: Identifiable, Codable {
    let id: Int
    let name: String
    let types: [NWType]
    let description: String?
    let imageURL: String?

    var identifier: String { "\(id)" }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case types
        case description
        case imageURL = "image_url"
    }
}

struct NWType: Codable {
    let name: String
}

struct PokemonPageDTO: Codable {
    let pokemons: [NWDataModel]
    let nextOffset: Int?
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case pokemons = "results"
        case nextOffset = "next_offset"
        case totalCount = "count"
    }
}
