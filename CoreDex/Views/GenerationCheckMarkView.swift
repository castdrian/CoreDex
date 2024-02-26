//
//  GenerationCheckMarkView.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import SwiftUI

struct GenerationCheckMarkView: View {
    let generations = 1...9
    @State private var selectedGens: Set<Int> = [7]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Supports Scan:")
                .font(.headline)
                .padding(.bottom, 5)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                ForEach(generations, id: \.self) { gen in
                    HStack {
                        Image(systemName: selectedGens.contains(gen) ? "checkmark.square.fill" : "square")
                        Text("Gen \(gen)")
                    }
                    .padding(5)
                    .onTapGesture {
                        if selectedGens.contains(gen) {
                            selectedGens.remove(gen)
                        } else {
                            selectedGens.insert(gen)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
#Preview {
    GenerationCheckMarkView()
}
