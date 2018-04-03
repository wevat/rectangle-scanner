//
//  UIImage+StaticExtensions.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 03/04/2018.
//

import UIKit

extension UIImage {
    
    static var closeIcon: UIImage? {
        return getImageFromBundle(name: "close-icon")
    }
    
    static var topShadow: UIImage? {
        return getImageFromBundle(name: "top-shadow-view")
    }
    
    static var takePicture: UIImage? {
        return getImageFromBundle(name: "take-picture-icon")
    }
    
    static func getImageFromBundle(name: String) -> UIImage? {
        let podBundle = Bundle(for: CameraStreamProvider.self)
        return UIImage(named: name, in: podBundle, compatibleWith: nil)
    }
}
