//
//  ScanError.swift
//  Pods-RectangleScanner_Example
//
//  Created by Harry Bloom on 29/03/2018.
//

import Foundation

struct ScanError: LocalizedError {
    
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String
    
    init(description: String) {
        self._description = description
    }
    
    init() {
        self.init(description: "Unavailable")
    }
}
