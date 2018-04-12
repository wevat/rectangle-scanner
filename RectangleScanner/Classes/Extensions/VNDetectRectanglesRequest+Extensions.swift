//
//  VNDetectRectanglesRequest+Extensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import Foundation
import Vision

@available(iOS 11.0, *)
extension VNDetectRectanglesRequest {
    
    func setConfiguration(from config: RectangleScanConfiguration) {
        if let minimumConfidence = config.minimumConfidence {
            self.minimumConfidence = minimumConfidence
        }
        if let minimumSize = config.minimumSize {
            self.minimumSize = minimumSize
        }
        if let maximumAspectRatio = config.maximumAspectRatio {
            self.maximumAspectRatio = maximumAspectRatio
        }
        if let minimumAspectRatio = config.minimumAspectRatio {
            self.minimumAspectRatio = minimumAspectRatio
        }
        if let quadratureTolerance = config.quadratureTolerance {
            self.quadratureTolerance = quadratureTolerance
        }
    }
}
