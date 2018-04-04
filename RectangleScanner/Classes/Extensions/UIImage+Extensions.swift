//
//  UIImage+Extensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 03/04/2018.
//

import UIKit

extension UIImage {
    
    func cropping(toRect rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        let drawRect: CGRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: self.size.width, height: self.size.height)
        
        context.clip(to: CGRect(x:0, y:0, width: rect.size.width, height: rect.size.height))
        
        self.draw(in: drawRect)
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
}
