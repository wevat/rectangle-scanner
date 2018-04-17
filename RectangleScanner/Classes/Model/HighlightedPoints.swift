//
//  HighlightedPoints.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 16/04/2018.
//

import UIKit

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
        print("Joined points before: \(points.joined.bounds)")
        points = points.map { (point) -> CGPoint in
            return originView.convert(point, to: view)
        }
        print("Joined points after: \(points.joined.bounds)")
    }
}
