//
//  UIView+Extensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 03/04/2018.
//

import UIKit

extension UIView {
    
    func screenShot() -> UIImage? {
        UIGraphicsBeginImageContext(self.frame.size)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
