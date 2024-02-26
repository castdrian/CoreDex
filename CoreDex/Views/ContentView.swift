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
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var pokemonData: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber?
    @State private var showDexEntryView = false
    @State private var isVoiceAvailable = true
    @State private var selectedNumber: Int = 722
    
    let numberRange = Array(1...1025)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Pokémon #\(selectedNumber)")
                    .font(.headline)
                    .padding(.top, 20)
                
                Picker(String(), selection: $selectedNumber) {
                    ForEach(numberRange, id: \.self) {
                        Text("#\($0)").tag($0)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                
                Button(action: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        getDexEntry()
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .padding(15)
                .frame(width: 100, height: 100)
                .background(
                    ZStack {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .top, endPoint: .bottom))
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 5, y: 5)
                        
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    }
                )
                .foregroundColor(Color.white)
                
                Button(action: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        showingImagePicker.toggle()
                    }
                }) {
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                .padding(30)
                .frame(width: 200, height: 200)
                .background(
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .top, endPoint: .bottom))
                )
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
                .foregroundColor(Color.white)
                .padding()
                .sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
                    ImagePicker(image: self.$inputImage)
                }
                
                Text("Scan currently Gen 9 starters only")
            }
            .padding()
            .navigationDestination(isPresented: $showDexEntryView) {
                if let pokemonData = pokemonData {
                    DexEntryView(pokemon: pokemonData)
                }
            }
            .onAppear {
                checkSpeechVoice { voiceExists in
                    isVoiceAvailable = voiceExists
                    if !isVoiceAvailable {
                        showAlertForMissingVoice()
                    }
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
            apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: selectedNumber)) { result in
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
            message: "The Zoe (Premium) voice required for this app is not available. Please download it from Settings > Accessibility > Spoken Content > Voices",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

#Preview {
    ContentView()
}
