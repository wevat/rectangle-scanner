//
//  DetectedRectangle.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 06/04/2018.
//

import Foundation
import CoreGraphics
import Vision

class DetectedRectangle {
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint
    
    var points: [CGPoint] {
        return [
            topLeft,
            topRight,
            bottomRight,
            bottomLeft
        ]
    }
    
    var joiningRect: CGRect {
        let path = CGMutablePath()
        path.addLines(between: points)
        return path.boundingBox
    }
    
    @available(iOS 11.0, *)
    init(rectangle: VNRectangleObservation) {
        self.topLeft = rectangle.topLeft
        self.topRight = rectangle.topRight
        self.bottomRight = rectangle.bottomRight
        self.bottomLeft = rectangle.bottomLeft
    }
    
    init(rect: CGRect) {
        self.topLeft = CGPoint(x: rect.minX, y: rect.minY)
        self.topRight = CGPoint(x: rect.maxX, y: rect.minY)
        self.bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        self.bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
    }
    
    init(points: [CGPoint]) {
        self.topLeft = points[0]
        self.topRight = points[1]
        self.bottomRight = points[2]
        self.bottomLeft = points[3]
    }
    
    func convertPoints(toView view: UIView) {
        topLeft = view.convertFromCamera(topLeft)
        topRight = view.convertFromCamera(topRight)
        bottomRight = view.convertFromCamera(bottomRight)
        bottomLeft = view.convertFromCamera(bottomLeft)
    }
}
