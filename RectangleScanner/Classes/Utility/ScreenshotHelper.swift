//
//  ScreenshotHelper.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 26/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import UIKit

struct ScreenshotHelper {
    
    static func processScreenshot(fromImage lowResImage: UIImage?, toImage highResImage: UIImage?, croppingTo rect: CGRect?, withDelay delay: TimeInterval = 0, completion: @escaping ((UIImage) -> Void)) {
        guard let lowResImage = lowResImage, let highResImage = highResImage, let rect = rect else {
            return
        }
        
        let convertedRect = convertRect(smallImageSize: lowResImage.size, largeImageSize: highResImage.size, smallRect: rect)
        
        print("Original rect to crop: \(rect)")
        print("Scaled rect to crop: \(convertedRect)")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            let croppedImage = highResImage.cropping(toRect: convertedRect)
            completion(croppedImage)
        }
    }
    
    private static func convertRect(smallImageSize: CGSize, largeImageSize: CGSize, smallRect: CGRect) -> CGRect {
        let scaledWidth = largeImageSize.width / smallImageSize.width * 2
        let scaledHeight = largeImageSize.height / smallImageSize.height * 2
        
        let convertedRect = smallRect
            .applying(CGAffineTransform(scaleX: scaledWidth, y: scaledHeight))
    
        return convertedRect
    }
}
