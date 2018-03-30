//    MIT License
//
//    Copyright (c) 2017 Melissa Ludowise
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


import UIKit

extension UIImage {
    
    func crop(toRect rect: CGRect) -> UIImage? {    
        guard rect.size.width > 0 && rect.size.height > 0 else {
            return nil
        }
        guard let cgImage = self.cgImage, let imageRef = cgImage.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: imageRef, scale: 1.0, orientation: self.imageOrientation)
    }
    
    
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