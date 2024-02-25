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
let imagePredictor = ImagePredictor()

struct ContentView: View {
    var body: some View {
        VStack {
            Button("test"){
                DispatchQueue.global(qos: .userInitiated).async {
                    imagePredictor.classifyImage(UIImage(named: "test")!) { result in
                        switch result {
                        case .success(let prediction):
                            print(prediction.classification)
                            print(prediction.confidence)
                        case .failure(let error):
                            print("Error predicting image: \(error)")
                        }
                    }
                }
                
                //                apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: 722)) { result in
                //                  guard let data = try? result.get().data else { return }
                //                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
