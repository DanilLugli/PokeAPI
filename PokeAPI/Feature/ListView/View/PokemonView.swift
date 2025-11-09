//
//  PokemonView.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/7/25.
//

import SwiftUI

struct PokemonView: View {
    @StateObject private var viewModel = PokemonListViewModel(api: APIManager())
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredPokemons) { pokemon in
                    PokemonViewRow(model: pokemon)
                        .onAppear {
                            viewModel.loadNextPageWithSearchIfNeeded(currentItem: pokemon)
                        }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Pokémon")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText)
            .onAppear {
                viewModel.loadInitial()
            }
            .alert(item: errorBinding) { wrapper in
                Alert(title: Text("Error"), message: Text(wrapper.message))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorBinding: Binding<ErrorWrapper?> {
        Binding(
            get: {
                viewModel.errorMessage
                    .map { ErrorWrapper(message: $0) }
            },
            set: { _ in viewModel.clearError() }
        )
    }
    
    private struct ErrorWrapper: Identifiable {
        let id = UUID()
        let message: String
    }
}
