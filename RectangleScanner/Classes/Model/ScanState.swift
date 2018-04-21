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
    case processingRectangle
    case couldntFindRectangle
    
    func isProcessing() -> Bool {
        switch self {
        case .processingRectangle:
            return true
        default:
            return false
        }
    }
}
