//
//  RectangleDetectionEnabledCache.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 23/04/2018.
//

import Foundation

struct RectangleDetectionEnabledCache {
    
    static let isEnabledKey = "RectangleDetectionEnabledKey"
    
    static func set(on: Bool, defaults: UserDefaults = UserDefaults.standard) {
        defaults.set(on, forKey: isEnabledKey)
    }
    
    static func get(defaults: UserDefaults = UserDefaults.standard) -> Bool? {
        guard let isEnabled = defaults.object(forKey: isEnabledKey) as? Bool else {
            return nil
        }
        return isEnabled
    }
    
    static func getInitialValue(defaults: UserDefaults = UserDefaults.standard) -> Bool {
        return get(defaults: defaults) ?? true
    }
}
