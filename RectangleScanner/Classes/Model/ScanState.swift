//
//  ScanState.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 26/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import Foundation

enum ScanState {
    case lookingForRectangle
    case releaseRectangle
    case processingRectangle
    case couldntFindRectangle
    
    func description() -> String {
        switch self {
        case .lookingForRectangle:
            return "Please tap and hold on the rectangle."
        case .releaseRectangle:
            return "Release to select rectangle"
        case .processingRectangle:
            return "Processing image..."
        case .couldntFindRectangle:
            return "Couldn't find rectangle. Please move perspective a little and try selecting again."
        }
    }
    
    func isProcessing() -> Bool {
        switch self {
        case .processingRectangle:
            return true
        default:
            return false
        }
    }
}
