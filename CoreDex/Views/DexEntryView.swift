//
//  DexEntryView.swift
//  CoreDex
//
//  Created by Adrian Castro on 25.02.24.
//

import AVFoundation
import Kingfisher
import PkmnApi
import SwiftUI

protocol AbilityDisplayable {
    var name: String { get }
    var shortDesc: String { get }
}

extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber.Abilities.First: AbilityDisplayable {}
extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber.Abilities.Second: AbilityDisplayable {}
extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber.Abilities.Hidden: AbilityDisplayable {}
extension GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber {
    var baseStatsArray: [StatInfo] {
        [
            StatInfo(name: "HP", value: CGFloat(baseStats.hp), maxValue: 255, color: .red),
            StatInfo(name: "Atk", value: CGFloat(baseStats.attack), maxValue: 255, color: .orange),
            StatInfo(name: "Def", value: CGFloat(baseStats.defense), maxValue: 255, color: .yellow),
            StatInfo(name: "Sp.Atk", value: CGFloat(baseStats.specialattack), maxValue: 255, color: .green),
            StatInfo(name: "Sp.Def", value: CGFloat(baseStats.specialdefense), maxValue: 255, color: .blue),
            StatInfo(name: "Speed", value: CGFloat(baseStats.speed), maxValue: 255, color: .purple),
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

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context _: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

struct SpriteView: View {
    let spriteURL: String
    let shinySpriteURL: String
    @Binding var showShinySprite: Bool
    var playPokemonCry: () -> Void
    @State private var documentURL: URL?
    @State private var isLoading = false

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
        .onLongPressGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            loadImageData()
        }
        .background(
            Group {
                if documentURL != nil {
                    DocumentInteractionController(url: documentURL!)
                        .onAppear {
                            documentURL = nil
                        }
                }
            }
        )
    }

    private func loadImageData() {
        isLoading = true
        guard let imageURL = URL(string: showShinySprite ? shinySpriteURL : spriteURL) else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data, error == nil else {
                print("Error loading image data: \(String(describing: error))")
                return
            }

            let tempURL = saveImageToTemporaryDirectory(imageData: data)

            DispatchQueue.main.async {
                if let tempURL {
                    documentURL = tempURL
                }
            }
        }.resume()
    }

    private func saveImageToTemporaryDirectory(imageData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("gif")

        do {
            try imageData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving image to temporary directory: \(error)")
            return nil
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
    @State private var hasAppeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                spriteSection
                typeSection
                dimensionsAndGenderSection
                flavorTextSection
                abilitiesSection
                statsSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("\(pokemon.species.capitalized) #\(pokemon.num.description)")
                        .font(.headline)
                    if let classification = pokemon.classification {
                        Text(classification)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            if !hasAppeared {
                playPokemonCry {
                    let dynamicCorrections = createDynamicCorrections(for: pokemon)
                    readDexEntry(with: dynamicCorrections)
                }
                hasAppeared = true
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

    private var dimensionsAndGenderSection: some View {
        VStack {
            HStack {
                Text("♂")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                Text(pokemon.gender.male)
                Text("♀")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                Text(pokemon.gender.female)
            }
            Text("Height: \(pokemon.height.description) M | Weight: \(pokemon.weight.description) KG")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
        )
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
            let dynamicCorrections = createDynamicCorrections(for: pokemon)
            readDexEntry(with: dynamicCorrections)
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
                ForEach(0 ..< abilities.count, id: \.self) { index in
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
        .onTapGesture {
            let dynamicCorrections = createDynamicCorrections(for: pokemon)
            readAbilityEntry(with: ability, dynamicCorrections: dynamicCorrections)
        }
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

        URLSession.shared.dataTask(with: url) { [self] data, _, error in
            DispatchQueue.main.async {
                if let data, error == nil {
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

    private func createDynamicCorrections(for pokemon: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber) -> [(String, String, CorrectionMode)] {
        var corrections = [(String, String, CorrectionMode)]()

        if let ipa = pokemon.ipa {
            corrections.append((pokemon.species.lowercased(), ipa, .ipa))
        }

        if let preevolutions = pokemon.preevolutions {
            for preevolution in preevolutions {
                if let ipa = preevolution.ipa {
                    corrections.append((preevolution.species.lowercased(), ipa, .ipa))
                }
            }
        }

        //        return corrections
        return []
    }

    private func readDexEntry(with dynamicCorrections: [(String, String, CorrectionMode)]? = nil) {
        let audioSession = AVAudioSession()

        do {
            try audioSession.setCategory(.ambient, options: .duckOthers)
            try audioSession.setActive(false)
        } catch {
            print(error.localizedDescription)
        }

        let classificationText = pokemon.classification != nil ? "The \(pokemon.classification!.split(separator: " ").dropLast().joined(separator: " ")) POH-kee-MAHN!" : ""
        let typeText = pokemon.types.count == 2 ? "\(pokemon.types.first!.name) and \(pokemon.types.last!.name) type!" : "\(pokemon.types.first!.name) type!"
        let preevolutionText = (pokemon.preevolutions?.first != nil) ? "The evolution of \(pokemon.preevolutions!.first!.species)!" : ""
        let flavorText = pokemon.flavorTexts.first?.flavor ?? ""

        let dexEntry = "\(pokemon.species)! \(classificationText) \(typeText) \(preevolutionText) \(flavorText)"

        let utterance = AVSpeechUtterance(attributedString: applyCorrections(to: dexEntry, with: dynamicCorrections))
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe")
        utterance.rate = 0.4

        synthesizer.speak(utterance)
    }

    private func readAbilityEntry(with ability: AbilityDisplayable, dynamicCorrections: [(String, String, CorrectionMode)]? = nil) {
        let audioSession = AVAudioSession()

        do {
            try audioSession.setCategory(.ambient, options: .duckOthers)
            try audioSession.setActive(false)
        } catch {
            print(error.localizedDescription)
        }

        let abilityText = "\(ability.name). \(ability.shortDesc)"

        let utterance = AVSpeechUtterance(attributedString: applyCorrections(to: abilityText, with: dynamicCorrections))
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe")
        utterance.rate = 0.4

        synthesizer.speak(utterance)
    }

    enum CorrectionMode {
        case ipa
        case textReplacement
    }

    private func applyCorrections(to text: String, with corrections: [(String, String, CorrectionMode)]?) -> NSMutableAttributedString {
        let constantCorrections: [(String, String, CorrectionMode)] = [
            ("pokémon", "ˈpo͡ʊ.ki.ˈmɑn", .ipa),
        ]

        var dynamicCorrections = corrections ?? []
        dynamicCorrections += constantCorrections

        let pronunciationKey = NSAttributedString.Key(rawValue: AVSpeechSynthesisIPANotationAttribute)
        let attributedString = NSMutableAttributedString(string: text)
        let normalizedText = text.folding(options: .diacriticInsensitive, locale: .current).lowercased()

        for (target, correction, mode) in dynamicCorrections {
            let normalizedTarget = target.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            var searchRange = NSRange(location: 0, length: normalizedText.utf16.count)

            while let range = normalizedText.range(of: normalizedTarget, options: .caseInsensitive, range: Range(searchRange, in: normalizedText)) {
                let nsRange = NSRange(range, in: normalizedText)
                if mode == .ipa {
                    attributedString.setAttributes([pronunciationKey: correction], range: nsRange)
                } else if mode == .textReplacement {
                    attributedString.replaceCharacters(in: nsRange, with: correction)
                }
                print("Applied correction for \(target)")
                searchRange = NSRange(location: nsRange.location + nsRange.length, length: normalizedText.utf16.count - (nsRange.location + nsRange.length))
            }

            if !normalizedText.contains(normalizedTarget) {
                print("No correctible text found for \(target)")
            }
        }
        return attributedString
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
