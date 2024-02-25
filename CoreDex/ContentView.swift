//
//  ContentView.swift
//  CoreDex
//
//  Created by Adrian Castro on 24.02.24.
//

import SwiftUI
import Apollo
import AVFoundation
import PkmnApi

let apolloClient = ApolloClient(url: URL(string: "https://graphqlpokemon.favware.tech/v8")!)
let imagePredictor = ImagePredictor()

struct ContentView: View {
    @State private var synthesizer: AVSpeechSynthesizer?
    
    var body: some View {
        VStack {
            Button("CoreDex"){
                DispatchQueue.global(qos: .userInitiated).async {
                    imagePredictor.classifyImage(UIImage(named: "test")!) { result in
                        switch result {
                        case .success(let prediction):
                            print(prediction.classification)
                            print(prediction.confidence)
                            
                            apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: 718 /*prediction.classification*/)) { result in
                                guard let data = try? result.get().data else { return }
                                
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                
                                readDexEntry(pkmn: data.getPokemonByDexNumber)
                            }
                        case .failure(let error):
                            print("Error predicting image: \(error)")
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func readDexEntry(pkmn: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber) {
        print(pkmn.species)
        let audioSession = AVAudioSession()
        
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(false)
        } catch let error {
            print(error.localizedDescription)
        }
        
        synthesizer = AVSpeechSynthesizer()
        
        let dexEntry = "\(pkmn.species). \(pkmn.types.count == 2 ? "\(pkmn.types.first!.name) and \(pkmn.types.last!.name) type." : "\(pkmn.types.first!.name) type.") \( pkmn.flavorTexts.first!.flavor)"
        
        let utterance = AVSpeechUtterance(string: dexEntry)
        utterance.voice = AVSpeechSynthesisVoice.speechVoices().first { voice in
            voice.name == "Zoe (Premium)"
        }
        synthesizer?.speak(utterance)
    }
}

#Preview {
    ContentView()
}
