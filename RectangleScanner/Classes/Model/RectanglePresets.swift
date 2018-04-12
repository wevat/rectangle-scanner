//
//  RectanglePresets.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import Foundation

public enum RectanglePreset {
    
    case receipt
}

public extension RectanglePreset {
    
    func scanConfig() -> RectangleScanConfiguration {
        switch self {
        case .receipt:
            return RectangleScanConfiguration(minimumAspectRatio: 0.1, minimumSize: 0.2, minimumConfidence: 0.9)
        }
    }
}
