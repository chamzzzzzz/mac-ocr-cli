//
//  TextRecognizer.swift
//  
//
//  Created by Liu Chen on 2022/4/20.
//

import Foundation
import Cocoa
import Vision

enum TextRecognizeError: LocalizedError {
    case loadImageFailed(file: String)
    case convertImageFailed(file: String)
    case performFailed(error: Error)
    case recognizeFailed(error: Error)

    var errorDescription: String? {
        switch self {
        case .loadImageFailed(let file):
            return "load image failed. (\(file))"
        case .convertImageFailed(let file):
            return "convert image failed. (\(file))"
        case .performFailed(error: let error):
            return "perform failed. (\(error))"
        case .recognizeFailed(error: let error):
            return "recognize failed. (\(error))"
        }
    }
}

class TextRecognizer {
    let imageFile: String
    var imageWidth: Int
    var imageHeight: Int
    var error: Error?
    var observations: [VNRecognizedTextObservation]?

    init(imageFile: String) {
        self.imageFile = imageFile
        self.imageWidth = 0
        self.imageHeight = 0
    }

    func perform() {
        guard let image = NSImage(contentsOfFile: self.imageFile) else {
            self.error = TextRecognizeError.loadImageFailed(file: self.imageFile)
            return
        }

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            self.error = TextRecognizeError.convertImageFailed(file: self.imageFile)
            return
        }

        self.imageWidth = cgImage.width
        self.imageHeight = cgImage.height

        let request = VNRecognizeTextRequest(completionHandler: self.requestCompletionHandler)
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.revision = VNRecognizeTextRequestRevision2
        request.recognitionLanguages = ["zh-Hans"]

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            self.error = TextRecognizeError.performFailed(error: error)
        }
    }

    func requestCompletionHandler(request: VNRequest, error: Error?) {
        if error != nil {
            self.error = TextRecognizeError.recognizeFailed(error: error!)
            return
        }

        self.observations = request.results as? [VNRecognizedTextObservation]
    }

    func result() -> String? {
        if self.error != nil {
            return nil
        }

        var lines: [String] = []
        lines.append("\(self.imageWidth)x\(self.imageHeight) \(self.imageFile)")
        if let observations = self.observations {
            for observation in observations {
                let confidence = observation.confidence
                let boudingBox = VNImageRectForNormalizedRect(observation.boundingBox, self.imageWidth, self.imageHeight)
                let text = observation.topCandidates(1).first?.string ?? ""
                let x = Int(boudingBox.origin.x)
                let y = Int(boudingBox.origin.y)
                let width = Int(boudingBox.size.width)
                let height = Int(boudingBox.size.height)
                lines.append("\(confidence) [\(x),\(y),\(width),\(height)] \(text)")
            }
        }
        return lines.joined(separator: "\n")
    }
}
