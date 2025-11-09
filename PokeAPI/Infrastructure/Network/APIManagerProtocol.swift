//
//  APIManagerProtocol.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

@MainActor
protocol APIManagerProtocol {
	func fetchPokemonPage(offset: Int, limit: Int) async throws -> PokemonPageDTO
}
