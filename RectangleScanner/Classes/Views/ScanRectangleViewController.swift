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
    
    public override init() {
        rectangleScanner = RectangleScanProvider()
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        rectangleScanner = RectangleScanProvider()
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bindCallbacks()
    }
    
    override func setupView() {
        super.setupView()
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
        let selectedShape = self.drawPolygon(convertedPoints, color: UIColor.blue)
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
    
    private func getRectToProcess() -> CGRect {
        return highlightedRect?.convertedRect(from: cameraStream.previewLayer) ?? cameraStreamView.frame
    }
    
    private func shouldThrottleSettingHighlightedRect() -> Bool {
        guard let highlightedRectLastUpdated = highlightedRectLastUpdated else {
            return false
        }
        return highlightedRectLastUpdated.timeIntervalSinceNow > -0.3
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
                let rectToCropTo = self.getRectToProcess()
                ImageProcessor.process(image: capturedImage, fromViewRect: self.cameraStreamView.frame, croppingTo: rectToCropTo) { (croppedImage) in
                    self.finish(withImage: croppedImage)
                }
            }
        }
    }
}
