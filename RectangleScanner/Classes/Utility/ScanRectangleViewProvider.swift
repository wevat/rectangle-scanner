//
//  ScanRectangleViewProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import UIKit

public protocol ScanRectangleViewProvider: class {
    
    var canScanRectangle: Bool { get }
    
    func startScan(parentViewController: UIViewController,
                   delegate: CameraViewDelegate,
                   analyticsDelegate: ScanRectangleAnalyticsDelegate?,
                   scanMode: ScanMode,
                   scanConfig: RectangleScanConfiguration?,
                   setupClosure: ViewControllerDidLoadCallback?)
    
    func availableViewController(_ delegate: CameraViewDelegate,
                                 _ analyticsDelegate: ScanRectangleAnalyticsDelegate?,
                                 _ scanMode: ScanMode,
                                 _ scanConfig: RectangleScanConfiguration?,
                                 _ setupClosure: ViewControllerDidLoadCallback?) -> UIViewController
}

public extension ScanRectangleViewProvider {
    
    var canScanRectangle: Bool {
        if #available(iOS 11.0, *) {
            return true
        } else {
            return false
        }
    }
    
    func startScan(parentViewController: UIViewController, delegate: CameraViewDelegate, analyticsDelegate: ScanRectangleAnalyticsDelegate?, scanMode: ScanMode = .autoCrop(autoScan: true), scanConfig: RectangleScanConfiguration? = nil, setupClosure: ViewControllerDidLoadCallback? = nil) {
        let cameraOrScanView = availableViewController(delegate, analyticsDelegate, scanMode, scanConfig, setupClosure)
        parentViewController.present(cameraOrScanView, animated: true, completion: nil)
    }
    
    public func availableViewController(_ delegate: CameraViewDelegate, _ analyticsDelegate: ScanRectangleAnalyticsDelegate?, _ scanMode: ScanMode, _ scanConfig: RectangleScanConfiguration?, _ setupClosure: ViewControllerDidLoadCallback?) -> UIViewController {
        if #available(iOS 11.0, *) {
            return ScanRectangleViewController(delegate: delegate, analyticsDelegate: analyticsDelegate, scanMode: scanMode, scanConfiguration: scanConfig, setupClosure: setupClosure)
        } else {
            return CameraViewController(delegate: delegate, setupClosure: setupClosure)
        }
    }
}

public extension ScanRectangleViewProvider where Self: UIViewController {
    
    func startScan(delegate: CameraViewDelegate, analyticsDelegate: ScanRectangleAnalyticsDelegate? = nil, scanMode: ScanMode = .autoCrop(autoScan: true), scanConfig: RectangleScanConfiguration? = nil, setupClosure: ViewControllerDidLoadCallback? = nil) {
        startScan(parentViewController: self, delegate: delegate, analyticsDelegate: analyticsDelegate, scanMode: scanMode, scanConfig: scanConfig, setupClosure: setupClosure)
    }
}
