//
//  UIImage+GPUImageExtensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 04/04/2018.
//

import UIKit
import GPUImage

public extension UIImage {
    
    public func imageWithAdjustedContrast(value: Float) -> UIImage {
        let stillImageFilter = GPUImageContrastFilter()
        stillImageFilter.contrast = CGFloat(value)
        return stillImageFilter.image(byFilteringImage: self)
    }
    
    public func imageWithAdjustedBrightness(value: Float) -> UIImage {
        let stillImageFilter = GPUImageBrightnessFilter()
        stillImageFilter.brightness = CGFloat(value)
        return stillImageFilter.image(byFilteringImage: self)
    }
    
    public func imageWithBlackAndWhite(value: Float) -> UIImage {
        let stillImageFilter = GPUImageLuminanceThresholdFilter()
        stillImageFilter.threshold = CGFloat(value)
        return stillImageFilter.image(byFilteringImage: self)
    }
}
