//
//  DataModel.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

struct DataModel: Identifiable {
    let id: Int
    let name: String
    let types: [String]
    let imageURL: String
    let abilities: String
    
    init(
        id: Int,
        name: String,
        types: [String],
        imageURL: String,
        description: String
    ) {
        self.id = id
        self.name = name
        self.types = types
        self.imageURL = imageURL
        self.abilities = description
    }
    
    init(from network: NWDataModel) {
        self.id = network.id
        self.name = network.name
        self.types = network.types.map { $0.name }
        self.imageURL = network.imageURL ?? ""
        self.abilities = network.description ?? ""
    }
}
