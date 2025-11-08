//
//  TestViewRow.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//


import SwiftUI

struct PokemonViewRow: View {
	let model: DataModel
	
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: model.imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                } placeholder: {
                    ProgressView()
                }
                
                VStack(alignment: .leading) {
                    Text(model.name)
                    Text(model.description)
                    ForEach(model.types, id: \.self) { type in
                        Text(type.capitalized)
                    }
                }
                Spacer()
            }
        }
    }
}
