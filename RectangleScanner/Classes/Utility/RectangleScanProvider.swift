//
//  RectangleScanProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 29/03/2018.
//

import Foundation
import SceneKit
import ARKit
import Vision

@available(iOS 11.0, *)
class RectangleScanProvider {
    
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private var lastObservation: VNDetectedObjectObservation?
    
    var didFindRectangle: ((_ rect: DetectedRectangle) -> Void)?
    
    func startRectangleRequest(onBuffer buffer: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest { (request, error) in
            self.rectangleRequestDidComplete(request: request, error: error)
        }
        
        do {
            request.minimumConfidence = 0.6
            request.minimumSize = 0.4
            try self.visionSequenceHandler.perform([request], on: buffer)
        } catch {
            print("Throws: \(error)")
        }
    }
    
    func rectangleRequestDidComplete(request: VNRequest, error: Error?) {
        guard let results = request.results,
            let rectangle = results.first as? VNRectangleObservation else {
                return
        }
        DispatchQueue.main.async {
            let detectedRect = DetectedRectangle(rectangle: rectangle)
            self.didFindRectangle?(detectedRect)
        }
    }
}
