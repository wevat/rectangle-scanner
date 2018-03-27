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

extension UIView {
    
    // Converts a point from camera coordinates (0 to 1 or -1 to 0, depending on orientation)
    // into a point within the given view
    func convertFromCamera(_ point: CGPoint) -> CGPoint {
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch orientation {
        case .portrait, .unknown:
            return CGPoint(x: point.y * frame.width, y: point.x * frame.height)
        case .landscapeLeft:
            return CGPoint(x: (1 - point.x) * frame.width, y: point.y * frame.height)
        case .landscapeRight:
            return CGPoint(x: point.x * frame.width, y: (1 - point.y) * frame.height)
        case .portraitUpsideDown:
            return CGPoint(x: (1 - point.y) * frame.width, y: (1 - point.x) * frame.height)
        }
    }
    
    // Converts a rect from camera coordinates (0 to 1 or -1 to 0, depending on orientation)
    // into a point within the given view
    func convertFromCamera(_ rect: CGRect) -> CGRect {
        let orientation = UIApplication.shared.statusBarOrientation
        let x, y, w, h: CGFloat
        
        switch orientation {
        case .portrait, .unknown:
            w = rect.height
            h = rect.width
            x = rect.origin.y
            y = rect.origin.x
        case .landscapeLeft:
            w = rect.width
            h = rect.height
            x = 1 - rect.origin.x - w
            y = rect.origin.y
        case .landscapeRight:
            w = rect.width
            h = rect.height
            x = rect.origin.x
            y = 1 - rect.origin.y - h
        case .portraitUpsideDown:
            w = rect.height
            h = rect.width
            x = 1 - rect.origin.y - w
            y = 1 - rect.origin.x - h
        }
        
        return CGRect(x: x * frame.width, y: y * frame.height, width: w * frame.width, height: h * frame.height)
    }
    
    
    func screenShot() -> UIImage? {
        UIGraphicsBeginImageContext(self.frame.size)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
