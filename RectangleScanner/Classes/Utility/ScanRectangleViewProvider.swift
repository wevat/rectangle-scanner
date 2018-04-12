//
//  ScanRectangleViewProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import UIKit

public protocol ScanRectangleViewProvider: class {
    
    var canScanRectangle: Bool { get }
    
    func startScan(parentViewController: UIViewController, delegate: CameraViewDelegate, scanConfig: RectangleScanConfiguration?, setupClosure: CameraViewControllerDidLoad?)
}

public extension ScanRectangleViewProvider {
    
    var canScanRectangle: Bool {
        if #available(iOS 11.0, *) {
            return true
        } else {
            return false
        }
    }
    
    func startScan(parentViewController: UIViewController, delegate: CameraViewDelegate, scanConfig: RectangleScanConfiguration? = nil, setupClosure: CameraViewControllerDidLoad? = nil) {
        let cameraOrScanView = availableViewController(delegate, scanConfig, setupClosure)
        parentViewController.present(cameraOrScanView, animated: true, completion: nil)
    }
    
    private func availableViewController(_ delegate: CameraViewDelegate, _ scanConfig: RectangleScanConfiguration?, _ setupClosure: CameraViewControllerDidLoad?) -> UIViewController {
        if #available(iOS 11.0, *) {
            return ScanRectangleViewController(delegate: delegate, scanConfiguration: scanConfig, setupClosure: setupClosure)
        } else {
            return CameraViewController(delegate: delegate, setupClosure: setupClosure)
        }
    }
}

public extension ScanRectangleViewProvider where Self: UIViewController {
    
    func startScan(delegate: CameraViewDelegate, scanConfig: RectangleScanConfiguration? = nil, setupClosure: CameraViewControllerDidLoad? = nil) {
        startScan(parentViewController: self, delegate: delegate, scanConfig: scanConfig, setupClosure: setupClosure)
    }
}
