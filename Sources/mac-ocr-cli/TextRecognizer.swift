//
//  TextRecognizer.swift
//  
//
//  Created by Liu Chen on 2022/4/20.
//

import Foundation
import Cocoa
import Vision

class TextRecognizeResult: Codable {
    struct Point: Codable {
        var x, y: Int
    }

    struct Size: Codable {
        var width, height: Int
    }

    struct Rect: Codable {
        var origin: Point
        var size: Size

        init(cgRect: CGRect) {
            origin = Point(x: Int(cgRect.origin.x), y: Int(cgRect.origin.y))
            size = Size(width: Int(cgRect.size.width), height: Int(cgRect.size.height))
        }
    }

    struct Observation: Codable {
        var text: String
        var confidence: Int
        var boundingBox: Rect?
    }

    struct Image: Codable {
        var file: String
        var width, height: Int?
    }

    var code: Int?
    var message: String?
    var image: Image?
    var observations: [Observation]?

    func jsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            return String(data: try encoder.encode(self), encoding: .utf8)!
        } catch {
            let err = TextRecognizeResult.error(code: -1, message: "encode error: \(error)")
            return String(data: try! encoder.encode(err), encoding: .utf8)!
        }
    }

    static func error(code: Int, message: String) -> TextRecognizeResult {
        let result = TextRecognizeResult()
        result.code = code
        result.message = message
        return result
    }
}

class TextRecognizer {
    func perform(file: String) -> TextRecognizeResult {
        let result = TextRecognizeResult()
        result.image = TextRecognizeResult.Image(file: file)

        guard let image = NSImage(byReferencingFile: file) else {
            result.message = "load image fail."
            result.code = 1
            return result
        }

        guard let cgImage = image.cgImage(forProposedRect: .none, context: .none, hints: .none) else {
            result.message = "convert image fail."
            result.code = 2
            return result
        }

        result.image!.width = Int(cgImage.width)
        result.image!.height = Int(cgImage.height)

        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            result.observations = []
            for observation in observations {
                let text = observation.topCandidates(1).first?.string ?? ""
                let confidence = Int(observation.confidence * 100)
                let boundingBox = VNImageRectForNormalizedRect(observation.boundingBox, result.image!.width!, result.image!.height!)
                result.observations!.append(TextRecognizeResult.Observation(text: text, confidence: confidence, boundingBox: TextRecognizeResult.Rect(cgRect: boundingBox)))
            }
        }
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.revision = VNRecognizeTextRequestRevision2
        request.recognitionLanguages = ["zh-Hans"]

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
            result.code = 0
        } catch {
            result.message = "perform error: \(error)"
            result.code = 3
        }

        return result
    }
}
