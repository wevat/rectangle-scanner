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
        points = []
        originView = UIView()
    }
    
    public init(points: [CGPoint], originView: UIView) {
        self.points = points
        self.originView = originView
    }
}
