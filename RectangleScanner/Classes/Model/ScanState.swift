//
//  ScanState.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 26/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import Foundation

public enum ScanState {
    case waiting
    case lookingForRectangle
    case processingRectangle
    case couldntFindRectangle
    
    func scannerIsRunning() -> Bool {
        switch self {
        case .processingRectangle, .waiting:
            return false
        default:
            return true
        }
    }
}
