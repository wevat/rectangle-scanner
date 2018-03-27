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


import Foundation

// Filters the given collections to their interesection where comparator returns that the values are the same
// Returns an array of filtered collections
func filterByIntersection<C: Collection, E>(_ collections: [C], where comparator: (E, E) -> Bool) -> [[E]] where E == C.Element {
    var results: [[E]] = []
    
    for currentCollection in collections {
        var resultingCollection: [E] = []
        
        for item1 in currentCollection {
            let keepItem = collections.reduce(true, { (isContained, c) -> Bool in
                isContained && c.contains(where: { (item2) -> Bool in
                    comparator(item1, item2)
                })
            })
            if keepItem {
                resultingCollection.append(item1)
            }
        }
        
        results.append(resultingCollection)
    }
    
    return results
}

//extension Collection {
//    func intersect<C: Collection>(_ collection: C, where comparator: (Self.Element, Self.Element) -> Bool) -> [Self.Element] where C.Element == Self.Element {
//        var result: [Self.Element] = []
//
//        for item1 in self {
//            let isCommon = collection.contains(where: { (item2) -> Bool in
//                return comparator(item1, item2)
//            })
//
//            if isCommon {
//                result.append(item1)
//            }
//        }
//
//        return result
//    }
    
//    func intersect<C: Collection>(_ collection: C, where comparator: (Self.Element, Self.Element) -> Bool) -> ([Self.Element], [Self.Element]) where C.Element == Self.Element {
    
//}

//extension Array where Element:Equatable {
//    func intersect<C: Collection>(_ collection: C) -> [Element] where C.Element == Element {
//        return self.intersect(collection, where: { (item1, item2) -> Bool in
//            item1 == item2
//        })
//    }
//
//}
//
//fileprivate func intersect<C: Collection, E>(_ collections: [C], where comparator: (E, E) -> Bool) -> [E] where E == C.Element {
//    var collections = collections
//    var result: [E] = Array(collections.removeFirst())
//
//    for collection in collections {
//        result = result.intersect(collection, where: comparator)
//    }
//
//    return result
//}
//
//func intersect<C: Collection, E>(_ collections: C..., where comparator: (E, E) -> Bool) -> [E] where E == C.Element {
//    return intersect(collections, where: comparator)
//}
//
//func intersect<C: Collection, E:Equatable>(_ collections: C...) -> [E] where E == C.Element {
//    return intersect(collections, where: { (item1, item2) -> Bool in
//        item1 == item2
//    })
//}

