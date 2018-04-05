//
//  UIImage+CoreImageExtensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 04/04/2018.
//

import CoreImage
import UIKit
import GPUImage

public extension UIImage {
    
    public func imageWithAdjustedContrast(value: Float) -> UIImage {
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            return self
        }
        let context = CIContext(options: nil)
        let originalImage = CIImage(image: self)
        contrastFilter.setValue(originalImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(value, forKey: kCIInputContrastKey)
        
        guard let outputImage = contrastFilter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent)  else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    public func imageWithAdjustedBrightness(value: Float) -> UIImage {
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            return self
        }
        let context = CIContext(options: nil)
        let originalImage = CIImage(image: self)
        contrastFilter.setValue(originalImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(value, forKey: kCIInputBrightnessKey)
        
        guard let outputImage = contrastFilter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent)  else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    public func imageWithGreyscale() -> UIImage {
        guard let contrastFilter = CIFilter(name: "CIPhotoEffectNoir") else {
            return self
        }
        let context = CIContext(options: nil)
        let originalImage = CIImage(image: self)
        contrastFilter.setValue(originalImage, forKey: kCIInputImageKey)
        
        guard let outputImage = contrastFilter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent)  else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    public var blackAndWhite: UIImage {
        return self
    }
}
