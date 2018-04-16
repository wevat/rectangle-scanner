//
//  HighlightedPoints.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 16/04/2018.
//

import Foundation

public struct HighlightedPoints {
    
    public var points: [CGPoint]
    public var originView: UIView
    
    public init() {
        points = [CGPoint.zero]
        originView = UIView()
    }
    
    public init(points: [CGPoint], originView: UIView) {
        self.points = points
        self.originView = originView
    }
    
    public mutating func convertPoints(toView view: UIView) {
        points = points.map { (point) -> CGPoint in
            let scaledWidth = view.frame.width / originView.frame.width
            let scaledHeight = view.frame.height / originView.frame.height
            return CGPoint(x: point.x * scaledWidth, y: point.y * scaledHeight)
        }
    }
}
