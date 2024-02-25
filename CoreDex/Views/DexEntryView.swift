//
//  DexEntryView.swift
//  CoreDex
//
//  Created by Adrian Castro on 25.02.24.
//

import SwiftUI
import Kingfisher
import PkmnApi
import AVFoundation

protocol AbilityDisplayable {
    var name: String { get }
    var shortDesc: String { get }
}

extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber.Abilities.First: AbilityDisplayable {}
extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber.Abilities.Second: AbilityDisplayable {}
extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber.Abilities.Hidden: AbilityDisplayable {}

struct DexEntryView: View {
    let pokemon: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerDelegate = AudioPlayerDelegate()
    @State private var showShinySprite = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                spriteSection
                typeSection
                flavorTextSection
                statsSection
                abilitiesSection
            }
            .padding()
        }
        .navigationBarTitle(Text("\(pokemon.species.capitalized) #\(pokemon.num)"), displayMode: .inline)
        .onAppear {
            playPokemonCry() {
                readDexEntry()
            }
        }
    }
    
    private var spriteSection: some View {
        HStack {
            KFAnimatedImage(URL(string: showShinySprite ? pokemon.shinySprite : pokemon.sprite))
                .scaledToFit()
                .frame(width: 150, height: 150)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                playPokemonCry()
                showShinySprite.toggle()
            }
        }
    }
    
    private var typeSection: some View {
        HStack(spacing: 10) {
            ForEach(pokemon.types, id: \.name) { type in
                HStack {
                    Text(type.name.capitalized)
                        .padding(8)
                        .frame(minWidth: 80, alignment: .center)
                    
                    Image(type.name.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 8)
                }
                .foregroundColor(.white)
                .background(pokemonTypeColors[type.name.lowercased()] ?? Color.gray)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
    
    private var flavorTextSection: some View {
        VStack {
            Text(pokemon.flavorTexts.first!.flavor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            readDexEntry()
        }
    }
    
    private var abilitiesSection: some View {
        VStack(alignment: .leading) {
            Text("Abilities")
                .font(.headline)
            abilityView(ability: pokemon.abilities.first, title: "First Ability")
            if let secondAbility = pokemon.abilities.second {
                abilityView(ability: secondAbility, title: "Second Ability")
            }
            if let hiddenAbility = pokemon.abilities.hidden {
                abilityView(ability: hiddenAbility, title: "Hidden Ability")
            }
        }
    }
    
    private func abilityView(ability: AbilityDisplayable, title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
            Text(ability.name)
                .fontWeight(.bold)
            Text(ability.shortDesc)
        }
        .padding(.vertical, 2)
    }
    
    
    private var statsSection: some View {
        VStack(alignment: .leading) {
            Text("Base Stats")
                .font(.headline)
            HStack {
                Text("HP: \(pokemon.baseStats.hp)")
                Spacer()
                Text("Attack: \(pokemon.baseStats.attack)")
            }
            HStack {
                Text("Defense: \(pokemon.baseStats.defense)")
                Spacer()
                Text("Sp. Atk: \(pokemon.baseStats.specialattack)")
            }
            HStack {
                Text("Sp. Def: \(pokemon.baseStats.specialdefense)")
                Spacer()
                Text("Speed: \(pokemon.baseStats.speed)")
            }
        }
    }
    
    private func playPokemonCry(completion: (() -> Void)? = nil) {
        guard let url = URL(string: "https://play.pokemonshowdown.com/audio/cries/\(pokemon.species).mp3") else {
            completion?()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [self] data, response, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    do {
                        audioPlayer = try AVAudioPlayer(data: data)
                        audioPlayerDelegate.onAudioFinished = {
                            try? AVAudioSession.sharedInstance().setActive(false)
                            completion?()
                        }
                        audioPlayer?.delegate = audioPlayerDelegate
                        
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                        try AVAudioSession.sharedInstance().setActive(true)
                        
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                    } catch {
                        print("Error setting up audio player: \(error)")
                        completion?()
                    }
                } else {
                    print("Error loading audio file: \(error?.localizedDescription ?? "Unknown error")")
                    completion?()
                }
            }
        }.resume()
    }
    private func readDexEntry() {
        let audioSession = AVAudioSession()
        
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(false)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let dexEntry = "\(pokemon.species). \(pokemon.types.count == 2 ? "\(pokemon.types.first!.name) and \(pokemon.types.last!.name) type." : "\(pokemon.types.first!.name) type.") \(((pokemon.preevolutions?.first) != nil) ? "The evolution of \(pokemon.preevolutions!.first!.species)." : "") \(pokemon.flavorTexts.first!.flavor)"
        
        let utterance = AVSpeechUtterance(string: dexEntry)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
}
