//
//  ImageClassifier.swift
//  CoreDex
//
//  Created by Adrian Castro on 24.02.24.
//

import Foundation
import CoreML
import Vision

func createImageClassifier() -> VNCoreMLModel {
    let defaultConfig = MLModelConfiguration()

    let imageClassifierWrapper = try? Gen9(configuration: defaultConfig)

    guard let imageClassifier = imageClassifierWrapper else {
        fatalError("App failed to create an image classifier model instance.")
    }

    let imageClassifierModel = imageClassifier.model

    guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
        fatalError("App failed to create a `VNCoreMLModel` instance.")
    }

    return imageClassifierVisionModel
}
