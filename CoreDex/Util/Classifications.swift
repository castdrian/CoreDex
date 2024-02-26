//
//  Classifications.swift
//  CoreDex
//
//  Created by Adrian Castro on 26.02.24.
//

import Foundation

struct PokemonClassification: Codable {
    var number: Int
    var classification: String
}

func loadPokemonClassifications() -> [PokemonClassification]? {
    guard let url = Bundle.main.url(forResource: "classifications", withExtension: "json") else {
        print("Classifications data file not found")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let classifications = try decoder.decode([PokemonClassification].self, from: data)
        return classifications
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

func getClassification(forNumber number: Int) -> String? {
    guard let classifications = loadPokemonClassifications() else {
        return nil
    }

    return classifications.first { $0.number == number }?.classification
}
