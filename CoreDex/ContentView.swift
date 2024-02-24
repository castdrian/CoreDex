//
//  ContentView.swift
//  CoreDex
//
//  Created by Adrian Castro on 24.02.24.
//

import SwiftUI
import Apollo
import PkmnApi

let apolloClient = ApolloClient(url: URL(string: "https://graphqlpokemon.favware.tech/v8")!)

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Request"){
                apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: 722)) { result in
                  guard let data = try? result.get().data else { return }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
