//
//  APIError.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//


import Foundation

enum APIError: Error, LocalizedError {
    
    // MARK: - Networking
    case invalidURL
    case requestFailed(underlying: Error)
    case invalidResponse(statusCode: Int)
    case noData
    
    // MARK: - Decoding
    case decodingFailed(underlying: Error)
    
    // MARK: - Connectivity
    case offline
    
    // MARK: - Unknown
    case unknown
    
    // MARK: - User friendly messages
    var errorDescription: String? {
        switch self {
            
        case .invalidURL:
            return "The URL used for this request is not valid."
            
        case .decodingFailed(let underlying):
            return "Failed to decode data: \(underlying.localizedDescription)"
                
            
        case .requestFailed(let underlying):
            return "The network request failed: \(underlying.localizedDescription)"
            
        case .invalidResponse(let statusCode):
            return "The server responded with an unexpected status code: \(statusCode)."
            
        case .noData:
            return "The server returned no data."
            
        case .decodingFailed(let underlying):
            return "Failed to decode data: \(underlying.localizedDescription)"
            
        case .offline:
            return "You appear to be offline. Please check your connection."
            
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
