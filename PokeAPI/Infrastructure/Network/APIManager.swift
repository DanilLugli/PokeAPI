//
//  APIManager.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import Foundation

class APIManager: APIManagerProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchPokemonPage(offset: Int, limit: Int) async throws -> PokemonPageDTO {
        let requestURL = try makeListURL(offset: offset, limit: limit)
        let listResponse: PokemonListResponse = try await fetch(requestURL)

        let detailModels = try await fetchDetails(for: listResponse.results)
        let nextOffset = Self.extractOffset(from: listResponse.next)

        return PokemonPageDTO(
            pokemons: detailModels.sorted { $0.id < $1.id },
            nextOffset: nextOffset,
            totalCount: listResponse.count
        )
    }

    private func makeListURL(offset: Int, limit: Int) throws -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent("pokemon"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200 ..< 300 ~= httpResponse.statusCode else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.invalidResponse(statusCode: status)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }
    }

    private func fetchDetails(for results: [PokemonListResponse.Result]) async throws -> [NWDataModel] {
        try await withThrowingTaskGroup(of: NWDataModel.self) { group in
            for result in results {
                group.addTask { [weak self] in
                    guard let self else { throw APIError.invalidURL }

                    let detailURL = result.url
                    let detail: PokemonDetailResponse = try await self.fetch(detailURL)

                    let speciesURL = self.baseURL.appendingPathComponent("pokemon-species/\(detail.id)")
                    let species: PokemonSpeciesResponse = try await self.fetch(speciesURL)

                    let description = species.flavorTextEntries
                        .first(where: { $0.language.name == "en" })?
                        .flavorText
                        .replacingOccurrences(of: "\n", with: " ")
                        .replacingOccurrences(of: "\u{000C}", with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    let types = detail.types
                        .sorted { $0.slot < $1.slot }
                        .map { NWType(name: $0.type.name.capitalized) }

                    return NWDataModel(
                        id: detail.id,
                        name: detail.name.capitalized,
                        types: types,
                        description: description,
                        imageURL: detail.sprites.frontDefault
                    )
                }
            }

            var models: [NWDataModel] = []
            models.reserveCapacity(results.count)

            for try await model in group {
                models.append(model)
            }

            return models
        }
    }
    
    private static func extractOffset(from next: String?) -> Int? {
        guard
            let next,
            let components = URLComponents(string: next),
            let items = components.queryItems
        else { return nil }

        return items
            .first { $0.name == "offset" }?
            .value
            .flatMap(Int.init)
    }
}

struct NamedAPIResource: Decodable {
    let name: String
    let url: String
}
