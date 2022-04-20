//
//  TextRecognizer.swift
//  
//
//  Created by Liu Chen on 2022/4/20.
//

import Foundation
import Cocoa
import Vision

class TextRecognizer {
    let imageFile: String
    var error: Error?

    init(imageFile: String) {
        self.imageFile = imageFile
    }

    func perform() {
        guard let image = NSImage(byReferencingFile: self.imageFile) else {
            print("load image failed")
            return
        }

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("convert image failed")
            return
        }

        print("\(self.imageFile) \(cgImage.width)x\(cgImage.height)")

        let request = VNRecognizeTextRequest(completionHandler: self.requestCompletionHandler)
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.revision = VNRecognizeTextRequestRevision2
        request.recognitionLanguages = ["zh-Hans"]

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("request failed \(error)")
        }
    }

    func requestCompletionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }

        for observation in observations {
            print(observation.topCandidates(1).first?.string ?? "")
            print(observation.confidence)
            print(observation.boundingBox)
            print("")
        }
    }
}
