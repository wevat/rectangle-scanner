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


import ARKit

extension SCNVector3 {
    func distance(from vector: SCNVector3) -> CGFloat {
        let deltaX = self.x - vector.x
        let deltaY = self.y - vector.y
        let deltaZ = self.z - vector.z
        
        return CGFloat(sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ))
    }
    
    func midpoint(from vector: SCNVector3) -> SCNVector3 {
        let midX = (self.x + vector.x) / 2
        let midY = (self.y + vector.y) / 2
        let midZ = (self.z + vector.z) / 2
        return SCNVector3Make(midX, midY, midZ)
    }
    
    // from Apples demo APP
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}
