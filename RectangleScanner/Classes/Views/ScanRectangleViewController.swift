//
//  ScanRectangleViewControllere.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import UIKit
import Vision

@available(iOS 11.0, *)
open class ScanRectangleViewController: CameraViewController {
    
    var rectangleScanner: RectangleScanProvider
    public var isRectangleDetectionEnabled: Bool = true
    
    var highlightedRectLayer: HighlightedRectangleLayer?
    private var scanConfiguration: RectangleScanConfiguration
    private var highlightedRectLastUpdated: Date?
    private var scanMode: ScanMode
    
    private var highlightedRect: VNRectangleObservation? {
        didSet {
            guard let highlightedRect = highlightedRect else { return }
            updateHighlightedView(withRect: highlightedRect)
            highlightedRectLastUpdated = Date()
        }
    }
    
    private var scanState: ScanState = .lookingForRectangle {
        didSet {
            toggleLoading(scanState.isProcessing())
        }
    }
    
    public init(delegate: CameraViewDelegate,
                scanMode: ScanMode = .autoCrop,
                scanConfiguration: RectangleScanConfiguration? = nil,
                setupClosure: ViewControllerDidLoadCallback? = nil) {
        self.scanConfiguration = scanConfiguration ?? RectangleScanConfiguration()
        self.scanMode = scanMode
        rectangleScanner = RectangleScanProvider()
        super.init()
        self.delegate = delegate
        self.setupClosure = setupClosure
    }
    
    public required init?(coder aDecoder: NSCoder) {
        rectangleScanner = RectangleScanProvider()
        scanConfiguration = RectangleScanConfiguration()
        scanMode = .autoCrop
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        bindCallbacks()
    }
    
    override func setupView() {
        super.setupView()
        rectangleScanner.setScanConfiguration(scanConfiguration)
        rectangleDetectionEnabledView.isHidden = false
        rectangleDetectionEnabledSwitch.setOn(isRectangleDetectionEnabled, animated: false)
        updateViewForTakePictureButton()
    }
    
    override func start() {
        super.start()
        scanState = .lookingForRectangle
    }
    
    override open func takePicture() {
        guard scanState != .processingRectangle else {
            return
        }
        processRectangle()
    }
    
    override open func switchValueChanged(isOn: Bool) {
        isRectangleDetectionEnabled = isOn
        removeHighlightedRect()
        updateViewForTakePictureButton()
    }
    
    open func didFind(rectangle: VNRectangleObservation) {
        guard scanState != .processingRectangle else {
            return
        }
        guard isRectangleDetectionEnabled == true else {
            return
        }
        guard shouldThrottleSettingHighlightedRect() == false else {
            return
        }
        highlightedRect = rectangle
    }
    
    open func bindCallbacks() {
        cameraStream.bufferDidUpdate = {[weak self] buffer in
            guard self?.isRectangleDetectionEnabled == true else {
                return
            }
            self?.rectangleScanner.startRectangleRequest(onBuffer: buffer)
        }
        
        rectangleScanner.didFindRectangle = {[weak self] rectangle in
            self?.didFind(rectangle: rectangle)
        }
    }
    
    open var shouldShowTakePictureButton: Bool {
        return true
    }
    
}

@available(iOS 11.0, *)
extension ScanRectangleViewController: HighlightedRectangleViewProvider {
    
    private func updateViewForTakePictureButton() {
        takePictureButton.isHidden = !shouldShowTakePictureButton
    }
    
    private func updateHighlightedView(withRect rect: VNRectangleObservation) {
        guard isRectangleDetectionEnabled, scanState != .processingRectangle else {
            return
        }
        guard let convertedPoints = rect.convertedPoints(from: cameraStream.previewLayer) else {
            return
        }
        updateHighlightedRect(onLayer: self.cameraStreamView.layer, fromPoints: convertedPoints, withColor: scanConfiguration.highlightedRectColor)
    }
    
    private func shouldThrottleSettingHighlightedRect() -> Bool {
        guard let highlightedRectLastUpdated = highlightedRectLastUpdated else {
            return false
        }
        return highlightedRectLastUpdated.timeIntervalSinceNow > -scanConfiguration.highlightedRectUpdateThrottle
    }
    
    private func processRectangle() {
        scanState = .processingRectangle
        cameraStream.pause(true)
        
        DispatchQueue.main.async {
            self.cameraStream.takeSnapshot { (capturedImage) in
                guard let capturedImage = capturedImage else {
                    self.scanState = .couldntFindRectangle
                    return
                }
                guard self.isRectangleDetectionEnabled else {
                    self.finish(withImage: capturedImage)
                    return
                }
                switch self.scanMode {
                case .autoCrop:
                    self.cropImageAndFinish(originalImage: capturedImage)
                case .originalWithCropRect:
                    self.getHighlightedPointsAndFinish(originalImage: capturedImage)
                }
            }
        }
    }
    
    private func cropImageAndFinish(originalImage: UIImage) {
        let rectToCropTo = highlightedRect?.convertedRect(from: cameraStream.previewLayer) ?? cameraStreamView.frame
        
        ImageProcessor.process(image: originalImage, fromViewRect: self.cameraStreamView.bounds, croppingTo: rectToCropTo) { (croppedImage) in
            self.finish(withImage: croppedImage)
        }
    }
    
    private func getHighlightedPointsAndFinish(originalImage: UIImage) {
        if let highlightedPoints = highlightedRect?.convertedPoints(from: cameraStream.previewLayer) {
            self.finish(withOriginalImage: originalImage, andHighlightedPoints: highlightedPoints)
        } else {
            self.finish(withOriginalImage: originalImage, andHighlightedPoints: cameraStreamView.frame.cornerPoints)
        }
    }
}
