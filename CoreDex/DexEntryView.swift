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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                headerSection
                spriteSection
                typeSection
                statsSection
                abilitiesSection
                evolutionSection
                flavorTextSection
            }
            .padding()
        }
        .navigationBarTitle(Text(pokemon.species), displayMode: .inline)
        .onAppear {
            readDexEntry()
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text(pokemon.species)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Text("#\(pokemon.num)")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    private var spriteSection: some View {
        HStack(spacing: 20) {
            KFImage(URL(string: pokemon.sprite))
            KFImage(URL(string: pokemon.shinySprite))
            KFImage(URL(string: pokemon.backSprite))
        }
        .padding(.vertical)
    }
    
    private var typeSection: some View {
        HStack {
            ForEach(pokemon.types, id: \.name) { type in
                Text(type.name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
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
    
    private var evolutionSection: some View {
        VStack(alignment: .leading) {
            Text("Evolution")
                .font(.headline)
            if let preEvolutions = pokemon.preevolutions, !preEvolutions.isEmpty {
                ForEach(preEvolutions, id: \.species) { evolution in
                    Text(evolution.species)
                }
            } else {
                Text("No pre-evolutions")
            }
        }
    }
    
    private var flavorTextSection: some View {
        VStack(alignment: .leading) {
            Text("Flavor Text")
                .font(.headline)
            ForEach(pokemon.flavorTexts, id: \.flavor) { flavorText in
                Text(flavorText.flavor)
            }
        }
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
