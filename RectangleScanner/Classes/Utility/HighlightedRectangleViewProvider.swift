//
//  HighlightedRectangleViewProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 13/04/2018.
//

import Foundation

protocol HighlightedRectangleViewProvider: class {
    
    var highlightedRectLayer: HighlightedRectangleLayer? { get set }
    
    func updateHighlightedRect(onLayer layer: CALayer, fromPoints points: [CGPoint], withColor color: UIColor)
    func removeHighlightedRect()
}

extension HighlightedRectangleViewProvider {
    
    private func drawHighlightedRect(onLayer layer: CALayer, fromPoints points: [CGPoint], withColor color: UIColor) {
        let highlightedRect = HighlightedRectangleLayer()
        highlightedRect.strokeColor = color.withAlphaComponent(0.4).cgColor
        highlightedRect.fillColor = color.withAlphaComponent(0.4).cgColor
        highlightedRect.lineWidth = 0
        let path = points.joined.cgPath
        highlightedRect.path = path
        layer.addSublayer(highlightedRect)
        highlightedRectLayer = highlightedRect
    }
    
    func updateHighlightedRect(onLayer layer: CALayer, fromPoints points: [CGPoint], withColor color: UIColor) {
        guard let currentRect = highlightedRectLayer else {
            drawHighlightedRect(onLayer: layer, fromPoints: points, withColor: color)
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
