//
//  ScreenshotHelper.swift
//  ImageProcessor
//
//  Created by Harry Bloom on 26/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import UIKit

struct ImageProcessor {
    
    static func process(image: UIImage?, fromViewRect viewRect: CGRect, croppingTo rect: CGRect?, withDelay delay: TimeInterval = 0, completion: @escaping ((UIImage) -> Void)) {
        guard let image = image, let rect = rect else {
            return
        }
        
        let convertedRect = convertRect(imageSize: image.size, viewRect: viewRect, rectToCropTo: rect)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            let croppedImage = image.cropping(toRect: convertedRect)
            completion(croppedImage)
        }
    }
    
    private static func convertRect(imageSize: CGSize, viewRect: CGRect, rectToCropTo: CGRect) -> CGRect {
        let scaledWidth = imageSize.width / viewRect.width
        let scaledHeight = imageSize.height / viewRect.height

        let convertedRect = rectToCropTo
            .applying(CGAffineTransform(scaleX: scaledWidth, y: scaledHeight))
        
        return convertedRect
    }

}
