//
//  ScanRectangleViewControllere.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 12/04/2018.
//

import UIKit
import Vision

@available(iOS 11.0, *)
public class ScanRectangleViewController: CameraViewController {
    
    var rectangleScanner: RectangleScanProvider
    
    private var scanConfiguration: RectangleScanConfiguration
    private var selectedRectangleOutlineLayer: CAShapeLayer?
    private var highlightedRectLastUpdated: Date?
    private var isRectangleDetectionEnabled: Bool = true
    
    private var highlightedRect: VNRectangleObservation? {
        didSet {
            guard let highlightedRect = highlightedRect else { return }
            removeSelectedRectangle()
            updateHighlightedView(withRect: highlightedRect)
            highlightedRectLastUpdated = Date()
        }
    }
    
    private var scanState: ScanState = .lookingForRectangle {
        didSet {
            toggleLoading(scanState.isProcessing())
        }
    }
    
    public init(delegate: CameraViewDelegate, scanConfiguration: RectangleScanConfiguration? = nil, setupClosure: CameraViewControllerDidLoad? = nil) {
        self.scanConfiguration = scanConfiguration ?? RectangleScanConfiguration()
        rectangleScanner = RectangleScanProvider()
        super.init()
        self.delegate = delegate
        self.setupClosure = setupClosure
    }

    public required init?(coder aDecoder: NSCoder) {
        rectangleScanner = RectangleScanProvider()
        scanConfiguration = RectangleScanConfiguration()
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindCallbacks()
    }
    
    override func setupView() {
        super.setupView()
        rectangleScanner.setScanConfiguration(scanConfiguration)
        rectangleDetectionEnabledView.isHidden = false
        rectangleDetectionEnabledSwitch.setOn(isRectangleDetectionEnabled, animated: false)
    }
    
    override func start() {
        super.start()
        scanState = .lookingForRectangle
    }
    
    override func takePicture() {
        processRectangle()
    }
    
    override func switchValueChanged(isOn: Bool) {
        isRectangleDetectionEnabled = isOn
        removeSelectedRectangle()
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController {

    private func bindCallbacks() {
        
        cameraStream.bufferDidUpdate = {[weak self] buffer in
            guard self?.isRectangleDetectionEnabled == true else {
                return
            }
            self?.rectangleScanner.startRectangleRequest(onBuffer: buffer)
        }
        
        rectangleScanner.didFindRectangle = {[weak self] rectangle in
            guard self?.isRectangleDetectionEnabled == true else {
                return
            }
            guard self?.shouldThrottleSettingHighlightedRect() == false else {
                return
            }
            self?.highlightedRect = rectangle
        }
    }
    
    private func updateHighlightedView(withRect rect: VNRectangleObservation) {
        guard self.isRectangleDetectionEnabled else {
            return
        }
        guard let convertedPoints = rect.convertedPoints(from: cameraStream.previewLayer) else {
            return
        }
        let selectedShape = self.drawPolygon(convertedPoints, color: scanConfiguration.highlightedRectColor)
        self.selectedRectangleOutlineLayer = selectedShape
        self.cameraStreamView.layer.addSublayer(selectedShape)
    }
    
    private func removeSelectedRectangle() {
        if let layer = selectedRectangleOutlineLayer {
            layer.removeFromSuperlayer()
            selectedRectangleOutlineLayer = nil
        }
    }
    
    private func drawPolygon(_ points: [CGPoint], color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = color.withAlphaComponent(0.4).cgColor
        layer.fillColor = color.withAlphaComponent(0.4).cgColor
        layer.lineWidth = 0
        let path = UIBezierPath()
        path.move(to: points.last!)
        points.forEach { point in
            path.addLine(to: point)
        }
        layer.path = path.cgPath
        return layer
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
                switch self.scanConfiguration.scanMode {
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
        
        ImageProcessor.process(image: originalImage, fromViewRect: self.cameraStreamView.frame, croppingTo: rectToCropTo) { (croppedImage) in
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
