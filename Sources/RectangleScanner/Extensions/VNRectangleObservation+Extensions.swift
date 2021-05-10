//
//  VNRectangleObservation+Extensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import Vision
import AVFoundation

@available(iOS 11.0, *)
extension VNRectangleObservation {
    
    var points: [CGPoint] {
        return [
            topLeft,
            topRight,
            bottomRight,
            bottomLeft
        ]
    }
    
    func topLeftConverted(from previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: topLeft)
    }
    
    func topRightConverted(from previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: topRight)
    }
    
    func bottomRightConverted(from previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: bottomRight)
    }
    
    func bottomLefttConverted(from previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: bottomLeft)
    }
    
    func convertedPoints(from previewLayer: AVCaptureVideoPreviewLayer?) -> [CGPoint]? {
        guard let previewLayer = previewLayer else {
            return nil
        }
        return points.map { previewLayer.layerPointConverted(fromCaptureDevicePoint: $0) }
    }
    
    func convertedRect(from previewLayer: AVCaptureVideoPreviewLayer?) -> CGRect? {
        guard let convertedPoints = convertedPoints(from: previewLayer) else {
            return nil
        }
        let path = CGMutablePath()
        path.addLines(between: convertedPoints)
        return path.boundingBox
    }
}
