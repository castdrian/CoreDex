//
//  ScanButton.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import PkmnApi
import SwiftUI

let imagePredictor = ImagePredictor()

struct RingSegment: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

struct RotatingRing: View {
    let ringCount: Int
    let ringRadius: CGFloat
    let segmentGap: Double
    let rotationDuration: Double
    @Binding var rotationAngle: Double

    var body: some View {
        ZStack {
            ForEach(0 ..< ringCount, id: \.self) { index in
                RingSegment(
                    startAngle: .degrees(Double(index) * (360.0 / Double(ringCount)) + segmentGap),
                    endAngle: .degrees(Double(index + 1) * (360.0 / Double(ringCount)) - segmentGap)
                )
                .stroke(Color.blue, lineWidth: 5)
                .frame(width: ringRadius * 2, height: ringRadius * 2)
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(Animation.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct ScanButton: View {
    @State private var showingScanner = false
    @State private var inputImage: UIImage?
    @State private var scale: CGFloat = 1
    @State private var rotateOuterAngle = 0.0
    @State private var rotateInnerAngle = 0.0
    @State private var pokemonData: GetPokemonByDexNumberQuery.Data.GetPokemonByDexNumber?
    @State private var showDexEntryView = false

    func processImage() {
        guard let selectedImage = inputImage else { return }
        processImageAndGetDexEntry(image: selectedImage)
    }

    private func processImageAndGetDexEntry(image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            imagePredictor.classifyImage(image) { result in
                switch result {
                case let .success(prediction):
                    apolloClient.fetch(query: GetPokemonByDexNumberQuery(number: prediction.classification)) { result in
                        guard let data = try? result.get().data else { return }

                        UINotificationFeedbackGenerator().notificationOccurred(.success)

                        DispatchQueue.main.async {
                            pokemonData = data.getPokemonByDexNumber
                            showingScanner = false
                            showDexEntryView = true
                        }
                    }
                case let .failure(error):
                    print("Error predicting image: \(error)")
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RotatingRing(ringCount: 12, ringRadius: 65, segmentGap: 3, rotationDuration: 8, rotationAngle: $rotateOuterAngle)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                            rotateOuterAngle = 360
                        }
                    }

                RotatingRing(ringCount: 12, ringRadius: 55, segmentGap: 3, rotationDuration: 6, rotationAngle: $rotateInnerAngle)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: false)) {
                            rotateInnerAngle = -360
                        }
                    }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    DispatchQueue.global(qos: .userInitiated).async {
                        showingScanner.toggle()
                    }
                }) {
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .padding(15)
                .frame(width: 90, height: 90)
                .background(
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .top, endPoint: .bottom))
                )
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 1)
                )
                .foregroundColor(Color.white)
                .padding()
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        scale = 1.05
                    }
                }
            }
            .modifier(PulsatingWarning())
        }
        .sheet(isPresented: $showingScanner) {
            ScannerView(onImageCaptured: { image in
                processImageAndGetDexEntry(image: image)
            })
        }
        .navigationDestination(isPresented: $showDexEntryView) {
            if let pokemonData {
                DexEntryView(pokemon: pokemonData)
            }
        }
    }
}

struct PulsatingWarning: ViewModifier {
    @State private var pulsate = false

    func body(content: Content) -> some View {
        VStack {
            content
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("scanning is very unstable")
                    .foregroundColor(.red)
                    .font(.caption)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
            .scaleEffect(pulsate ? 1.1 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulsate = true
                }
            }
        }
    }
}

#Preview {
    ScanButton()
}
