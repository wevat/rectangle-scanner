//
//  ScanModes.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import Foundation

public enum ScanMode {
    
    ///automatically crops the returned image based on the highlighted rect
    case autoCrop(autoScan: Bool)
    
    ///returns the original image, alongside an array of CGPoints so you can do the processing yourself
    case originalWithCropRect(autoScan: Bool)
}
