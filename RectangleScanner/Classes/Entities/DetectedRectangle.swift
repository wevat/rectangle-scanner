//
//  DetectedRectangle.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 06/04/2018.
//

import Foundation
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
    
    var boundingBox: CGRect {
        let path = UIBezierPath()
        path.move(to: points.last!)
        points.forEach { point in
            path.addLine(to: point)
        }
        return path.cgPath.boundingBox
    }
    
    @available(iOS 11.0, *)
    init(rectangle: VNRectangleObservation) {
        self.topLeft = rectangle.topLeft
        self.topRight = rectangle.topRight
        self.bottomRight = rectangle.bottomRight
        self.bottomLeft = rectangle.bottomLeft
    }
    
    func convertPoints(toView view: UIView) {
        topLeft = view.convertFromCamera(topLeft)
        topRight = view.convertFromCamera(topRight)
        bottomRight = view.convertFromCamera(bottomRight)
        bottomLeft = view.convertFromCamera(bottomLeft)
    }
}
