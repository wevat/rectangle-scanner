//
//  ScreenshotHelper.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 26/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import UIKit

struct ScreenshotHelper {
    
    static func takeAndProcessScreenshot(fromImage image: UIImage?, croppingTo rect: CGRect?, withDelay delay: TimeInterval, completion: @escaping ((UIImage) -> Void)) {
        guard let image = image, let rect = rect else {
            return
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + delay) {
            let convertedRect = rect.applying(CGAffineTransform(scaleX: 2, y: 2))
            let croppedImage = image.cropping(toRect: convertedRect)
            completion(croppedImage)
        }
    }
}
