//
//  HighlightedRectangleViewProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 13/04/2018.
//

import UIKit

protocol HighlightedRectangleViewProvider: class {
    
    var highlightedRectLayer: HighlightedRectangleLayer? { get set }
    
    func updateHighlightedRect(onView view: UIView, fromPoints points: [CGPoint], withColor color: UIColor)
    func removeHighlightedRect()
}

extension HighlightedRectangleViewProvider {
    
    private func drawHighlightedRect(onView view: UIView, fromPoints points: [CGPoint], withColor color: UIColor) {
        let highlightedRect = HighlightedRectangleLayer()
        highlightedRect.strokeColor = color.withAlphaComponent(0.4).cgColor
        highlightedRect.fillColor = color.withAlphaComponent(0.4).cgColor
        highlightedRect.lineWidth = 0
        let path = points.joined.cgPath
        highlightedRect.path = path
        view.layer.addSublayer(highlightedRect)
        highlightedRectLayer = highlightedRect
    }
    
    func updateHighlightedRect(onView view: UIView, fromPoints points: [CGPoint], withColor color: UIColor) {
        guard let currentRect = highlightedRectLayer, view.layer.sublayers?.contains(currentRect) == true else {
            drawHighlightedRect(onView: view, fromPoints: points, withColor: color)
            return
        }
        currentRect.path = points.joined.cgPath
    }
    
    func removeHighlightedRect() {
        if let layer = highlightedRectLayer {
            layer.removeFromSuperlayer()
            highlightedRectLayer = nil
        }
    }
}
