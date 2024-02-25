//
//  ContentView.swift
//  CoreDex
//
//  Created by Adrian Castro on 24.02.24.
//

import SwiftUI
import UIKit
import Apollo
import AVFoundation
import Speech
import PkmnApi

let apolloClient = ApolloClient(url: URL(string: "https://graphqlpokemon.favware.tech/v8")!)
let imagePredictor = ImagePredictor()

struct ContentView: View {
    @State private var synthesizer: AVSpeechSynthesizer?
    @State private var dexnum = 722
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var pokemonData: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber?
    @State private var showDexEntryView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Stepper("PokéMon #\(dexnum)", value: $dexnum, in: 1...1025, step: 1)
                
                Button("Check"){
                    DispatchQueue.global(qos: .userInitiated).async {
                        checkSpeechVoice { voiceExists in
                            if voiceExists {
                                getDexEntry()
                            } else {
                                print("Required voice is not available")
                            }
                        }
                    }
                }.padding()
                
                Button("Scan (Gen 9 Starters)"){
                    DispatchQueue.global(qos: .userInitiated).async {
                        checkSpeechVoice { voiceExists in
                            if voiceExists {
                                showingImagePicker.toggle()
                            } else {
                                print("Required voice is not available")
                            }
                        }
                    }
                }.padding()
                    .sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
                        ImagePicker(image: self.$inputImage)
                    }
            }
            .padding()
            .navigationDestination(isPresented: $showDexEntryView) {
                if let pokemonData = pokemonData {
                    DexEntryView(pokemon: pokemonData)
                }
            }
        }
    }
    
    func processImage() {
        guard let selectedImage = inputImage else { return }
        processImageAndGetDexEntry(image: selectedImage)
    }
    
    private func getDexEntry() {
        DispatchQueue.global(qos: .userInitiated).async {
            apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: dexnum)) { result in
                guard let data = try? result.get().data else { return }
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                DispatchQueue.main.async {
                    self.pokemonData = data.getPokemonByDexNumber
                    self.showDexEntryView = true
                }
            }
        }
    }
    
    private func processImageAndGetDexEntry(image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            imagePredictor.classifyImage(image) { result in
                switch result {
                case .success(let prediction):
                    apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: prediction.classification)) { result in
                        guard let data = try? result.get().data else { return }
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        DispatchQueue.main.async {
                            self.pokemonData = data.getPokemonByDexNumber
                            self.showDexEntryView = true
                        }
                    }
                case .failure(let error):
                    print("Error predicting image: \(error)")
                }
            }
        }
    }
    
    private func checkSpeechVoice(completion: @escaping (Bool) -> Void) {
        let voiceIdentifier = "com.apple.voice.premium.en-US.Zoe"
        let voiceExists = AVSpeechSynthesisVoice(identifier: voiceIdentifier) != nil
        completion(voiceExists)
        
        if !voiceExists {
            DispatchQueue.main.async {
                showAlertForMissingVoice()
            }
        }
    }
    
    private func showAlertForMissingVoice() {
        var keyWindow: UIWindow? {
            let allScenes = UIApplication.shared.connectedScenes
            for scene in allScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows where window.isKeyWindow {
                    return window
                }
            }
            return nil
        }
        
        let alert = UIAlertController(
            title: "Voice not available",
            message: "The Zoe (Premium) voice required for this app is not available. Please download it from Settings > Accessibility > Spoken Content > Voices and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

#Preview {
    ContentView()
}
