//
//  CGRect+Extensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import Foundation

extension CGRect {
    
    var cornerPoints: [CGPoint] {
        return [
            CGPoint(x: minX, y: minY),
            CGPoint(x: maxX, y: minY),
            CGPoint(x: maxX, y: maxY),
            CGPoint(x: minX, y: maxY)
        ]
    }
}

extension Array where Element == CGPoint {

    var joined: UIBezierPath {
        let path = UIBezierPath()
        guard let lastPoint = self.last else {
            return path
        }
        path.move(to: lastPoint)
        self.forEach { point in
            path.addLine(to: point)
        }
        return path
    }
}
