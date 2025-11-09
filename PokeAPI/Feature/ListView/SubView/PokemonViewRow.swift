//
//  PokemonViewRow.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import SwiftUI

struct PokemonViewRow: View {
    let model: DataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {

                AsyncImage(url: URL(string: model.imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(model.name)
                        .font(.headline)

                    HStack(spacing: 6) {
                        ForEach(model.types, id: \.self) { type in
                            Text(type.capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                    }

                    Text(model.abilities)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}
