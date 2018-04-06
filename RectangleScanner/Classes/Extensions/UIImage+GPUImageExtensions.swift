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
        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
        stillImageFilter.blurRadiusInPixels = 4
        let stillImageFilter1 = GPUImageLuminanceThresholdFilter()
        stillImageFilter1.threshold = CGFloat(value)
        stillImageFilter.addFilter(stillImageFilter1)
        return stillImageFilter.image(byFilteringImage: self)
    }
    
    public func imageWithPerspectiveTransform(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> UIImage? {
        guard let perspectiveTransform = CIFilter(name: "CIPerspectiveTransform") else {
            return nil
        }
        perspectiveTransform.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        perspectiveTransform.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        perspectiveTransform.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        perspectiveTransform.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        perspectiveTransform.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        guard let perspectiveImage = perspectiveTransform.outputImage else {
            return nil
        }
        return UIImage(ciImage: perspectiveImage)
    }
}
