//
//  ImagePredictor.swift
//  CoreDex
//
//  Created by Adrian Castro on 24.02.24.
//

import UIKit
import Vision

class ImagePredictor {
    static func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        let imageClassifierWrapper = try? Dex(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        let imageClassifierModel = imageClassifier.model

        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    private static let imageClassifier = createImageClassifier()

    struct Prediction {
        let classification: Int
        let confidence: Float
    }

    typealias ImagePredictionHandler = (_ prediction: Prediction?) -> Void

    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    private func createImageClassificationRequest() -> VNImageBasedRequest {
        let imageClassificationRequest = VNCoreMLRequest(model: ImagePredictor.imageClassifier,
                                                         completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    private func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(photo.imageOrientation.rawValue)) else { return }

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }

        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        try handler.perform(requests)
    }

    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        var topPrediction: Prediction?

        defer {
            predictionHandler(topPrediction)
        }

        if let error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        if let highestConfidenceObservation = observations.max(by: { a, b in a.confidence < b.confidence }) {
            topPrediction = Prediction(classification: Int(highestConfidenceObservation.identifier)!,
                                       confidence: highestConfidenceObservation.confidence)
        }
    }

    func classifyImage(_ image: UIImage, completion: @escaping (Result<Prediction, Error>) -> Void) {
        do {
            try makePredictions(for: image) { prediction in
                if let prediction {
                    completion(.success(prediction))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No predictions available"])))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
