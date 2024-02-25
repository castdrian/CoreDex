//
//  ContentView.swift
//  CoreDex
//
//  Created by Adrian Castro on 24.02.24.
//

import SwiftUI
import Apollo
import AVFoundation
import Speech
import PkmnApi

let apolloClient = ApolloClient(url: URL(string: "https://graphqlpokemon.favware.tech/v8")!)
let imagePredictor = ImagePredictor()

struct ContentView: View {
    @State private var synthesizer: AVSpeechSynthesizer?
    @State private var dexnum = 722
    
    var body: some View {
        VStack {
            Stepper("PokéMon #\(dexnum)", value: $dexnum, in: 1...1025, step: 1)
            
            Button("Check"){
                DispatchQueue.global(qos: .userInitiated).async {
                    checkSpeechVoice { voiceExists in
                        if voiceExists {
                            processImageAndReadDexEntry()
                        } else {
                            print("Required voice is not available")
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func processImageAndReadDexEntry() {
        DispatchQueue.global(qos: .userInitiated).async {
            apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: dexnum)) { result in
                guard let data = try? result.get().data else { return }
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                readDexEntry(pkmn: data.getPokemonByDexNumber)
                //            imagePredictor.classifyImage(UIImage(named: "test")!) { result in
                //                switch result {
                //                case .success(let prediction):
                //                    print(prediction.classification)
                //                    print(prediction.confidence)
                //
                //                    apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: prediction.classification)) { result in
                //                        guard let data = try? result.get().data else { return }
                //
                //                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                //
                //                        readDexEntry(pkmn: data.getPokemonByDexNumber)
                //                    }
                //                case .failure(let error):
                //                    print("Error predicting image: \(error)")
                //                }
                //            }
            }
        }
    }
    
    private func readDexEntry(pkmn: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber) {
        let audioSession = AVAudioSession()
        
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(false)
        } catch let error {
            print(error.localizedDescription)
        }
        
        synthesizer = AVSpeechSynthesizer()
        
        let dexEntry = "\(pkmn.species). \(pkmn.types.count == 2 ? "\(pkmn.types.first!.name) and \(pkmn.types.last!.name) type." : "\(pkmn.types.first!.name) type.") \(((pkmn.preevolutions?.first) != nil) ? "The evolution of \(pkmn.preevolutions!.first!.species)." : "") \(pkmn.flavorTexts.first!.flavor)"
        
        let utterance = AVSpeechUtterance(string: dexEntry)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe")
        utterance.rate = 0.4
        synthesizer?.speak(utterance)
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
