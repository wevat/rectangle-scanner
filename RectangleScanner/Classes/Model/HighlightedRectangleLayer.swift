//
//  HighlightedRectangleLayer.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 13/04/2018.
//

import Foundation

class HighlightedRectangleLayer: CAShapeLayer {
    
    override func action(forKey event: String) -> CAAction? {
        guard event == "path" else {
            return super.action(forKey: event)
        }
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = CATransaction.animationDuration()
        animation.timingFunction = CATransaction.animationTimingFunction()
        return animation
    }
}
