//
//  RectangleScanConfiguration.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import Foundation
import Vision

public struct RectangleScanConfiguration {
    
    ///Colour of the highlighted rect on screen
    var highlightedRectColor: UIColor
    
    ///If set, will throttle updates to how often the highlighted rect will update on the UI
    var highlightedRectUpdateThrottle: TimeInterval
    
    ///Mirroring instance vars from VNDetectRectanglesRequest. See documentation here for understanding how these work: https://developer.apple.com/documentation/vision/vndetectrectanglesrequest
    var minimumAspectRatio: VNAspectRatio?
    var maximumAspectRatio: VNAspectRatio?
    var quadratureTolerance: VNDegrees?
    var minimumSize: Float?
    var minimumConfidence: VNConfidence?
    
    
    public init(highlightedRectColor: UIColor = UIColor.blue,
                highlightedRectUpdateThrottle: TimeInterval = 0,
                minimumAspectRatio: VNAspectRatio? = nil,
                maximumAspectRatio: VNAspectRatio? = nil,
                quadratureTolerance: VNDegrees? = nil,
                minimumSize: Float? = nil,
                minimumConfidence: VNConfidence? = nil) {
        self.highlightedRectColor = highlightedRectColor
        self.highlightedRectUpdateThrottle = highlightedRectUpdateThrottle
        self.minimumAspectRatio = minimumAspectRatio
        self.maximumAspectRatio = maximumAspectRatio
        self.quadratureTolerance = quadratureTolerance
        self.minimumSize = minimumSize
        self.minimumConfidence = minimumConfidence
    }
    
    public init(highlightedRectColor: UIColor = UIColor.blue,
                highlightedRectUpdateThrottle: TimeInterval = 0,
                rectanglePreset: RectanglePreset = .yolo) {
        
        self.init(highlightedRectColor: highlightedRectColor,
                  highlightedRectUpdateThrottle: highlightedRectUpdateThrottle,
                  minimumAspectRatio: rectanglePreset.scanConfig().minimumAspectRatio,
                  maximumAspectRatio: rectanglePreset.scanConfig().maximumAspectRatio,
                  quadratureTolerance: rectanglePreset.scanConfig().quadratureTolerance,
                  minimumSize: rectanglePreset.scanConfig().minimumSize,
                  minimumConfidence: rectanglePreset.scanConfig().minimumConfidence)
    }
}
