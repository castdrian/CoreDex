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
extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber {
    var baseStatsArray: [StatInfo] {
        return [
            StatInfo(name: "HP", value: CGFloat(baseStats.hp), maxValue: 255, color: .red),
            StatInfo(name: "Atk", value: CGFloat(baseStats.attack), maxValue: 255, color: .orange),
            StatInfo(name: "Def", value: CGFloat(baseStats.defense), maxValue: 255, color: .yellow),
            StatInfo(name: "Sp.Atk", value: CGFloat(baseStats.specialattack), maxValue: 255, color: .green),
            StatInfo(name: "Sp.Def", value: CGFloat(baseStats.specialdefense), maxValue: 255, color: .blue),
            StatInfo(name: "Speed", value: CGFloat(baseStats.speed), maxValue: 255, color: .purple)
        ]
    }
}

struct StatInfo: Identifiable {
    let id = UUID()
    var name: String
    var value: CGFloat
    var maxValue: CGFloat
    var color: Color
}

struct SpriteView: View {
    let spriteURL: String
    let shinySpriteURL: String
    @Binding var showShinySprite: Bool
    var playPokemonCry: () -> Void
    
    var body: some View {
        HStack {
            KFAnimatedImage(URL(string: showShinySprite ? shinySpriteURL : spriteURL))
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
}

struct DexEntryView: View {
    let pokemon: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerDelegate = AudioPlayerDelegate()
    @State private var showShinySprite = false
    @State private var selectedAbilityIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                spriteSection
                typeSection
                flavorTextSection
                abilitiesSection
                statsSection
            }
            .padding()
        }
        .navigationBarTitle(Text("\(pokemon.species.capitalized) #\(pokemon.num)"), displayMode: .inline)
        .onAppear {
            playPokemonCry() {
                readDexEntry()
            }
        }
        .onDisappear {
            stopAudioPlayback()
        }
    }
    
    private var spriteSection: some View {
        SpriteView(spriteURL: pokemon.sprite,
                   shinySpriteURL: pokemon.shinySprite,
                   showShinySprite: $showShinySprite,
                   playPokemonCry: {
            playPokemonCry()
        })
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
    
    private var abilities: [AbilityDisplayable] {
        var abilitiesList: [AbilityDisplayable] = []
        
        abilitiesList.append(pokemon.abilities.first)
        
        if let second = pokemon.abilities.second {
            abilitiesList.append(second)
        }
        if let hidden = pokemon.abilities.hidden {
            abilitiesList.append(hidden)
        }
        return abilitiesList
    }
    
    private var abilitiesSection: some View {
        VStack(alignment: .leading) {
            Text("Abilities")
                .font(.headline)
            
            TabView(selection: $selectedAbilityIndex) {
                ForEach(0..<abilities.count, id: \.self) { index in
                    abilityView(ability: abilities[index])
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
        )
    }
    
    private func abilityView(ability: AbilityDisplayable) -> some View {
        VStack(alignment: .leading) {
            Text(ability.name)
                .fontWeight(.bold)
                .frame(height: 20)
            Text(ability.shortDesc)
                .frame(height: 60)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading) {
            Text("Base Stats")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(pokemon.baseStatsArray) { stat in
                HStack {
                    Text(stat.name)
                        .frame(width: 60, alignment: .leading)
                    Text("\(Int(stat.value))")
                        .frame(width: 40, alignment: .leading)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 20)
                                .foregroundColor(Color(.systemGray5))
                            Rectangle()
                                .frame(width: min(geometry.size.width * (stat.value / stat.maxValue), geometry.size.width), height: 20)
                                .foregroundColor(stat.color)
                        }
                    }
                }
                .frame(height: 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
        )
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
        
        let classificationText = getClassification(forNumber: pokemon.num).map { "The \($0)." } ?? ""
        
        let dexEntry = "\(pokemon.species). \(classificationText) \(pokemon.types.count == 2 ? "\(pokemon.types.first!.name) and \(pokemon.types.last!.name) type." : "\(pokemon.types.first!.name) type.") \(((pokemon.preevolutions?.first) != nil) ? "The evolution of \(pokemon.preevolutions!.first!.species)." : "") \(pokemon.flavorTexts.first!.flavor)"
        
        let utterance = AVSpeechUtterance(string: dexEntry)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    private func stopAudioPlayback() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error stopping audio session: \(error)")
        }
    }
}
