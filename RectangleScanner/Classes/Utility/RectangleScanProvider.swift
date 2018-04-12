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
    
    var didFindRectangle: ((_ rect: VNRectangleObservation) -> Void)?
    
    var scanConfig: RectangleScanConfiguration?
    
    func setScanConfiguration(_ config: RectangleScanConfiguration) {
        scanConfig = config
    }
    
    func startRectangleRequest(onBuffer buffer: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest { (request, error) in
            self.rectangleRequestDidComplete(request: request, error: error)
        }
        
        do {
            if let config = scanConfig {
                request.setConfiguration(from: config)
            }
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
            self.didFindRectangle?(rectangle)
        }
    }
}
