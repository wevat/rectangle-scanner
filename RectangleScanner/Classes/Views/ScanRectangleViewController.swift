//
//  ScanRectangleViewController.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 27/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

public protocol ScanRectangleViewDelegate: class {
    func didComplete(withImage: UIImage, sender: UIViewController)
    func didTapCancel(sender: UIViewController)
}

@available(iOS 11.0, *)
public class ScanRectangleViewController: UIViewController {
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet var cameraStreamView: UIView!
    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var rectangleDetectionEnabledSwitch: UISwitch!
    
    var cameraStream: CameraStreamProvider
    var rectangleScanner: RectangleScanProvider
    
    private var selectedRectangleOutlineLayer: CAShapeLayer?
    
    private var highlightedRectLastUpdated: Date?
    
    public weak var delegate: ScanRectangleViewDelegate?
    
    private var isRectangleDetectionEnabled: Bool = true
    
    private var highlightedRect: DetectedRectangle? {
        didSet {
            guard let highlightedRect = highlightedRect else { return }
            highlightedRect.convertPoints(toView: cameraStreamView)
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
    
    private var setupClosure: ((_ viewDidLoadOn: ScanRectangleViewController) -> Void)?
    
    deinit {
        print("ScanRectangleViewController deinited")
    }
    
    public init() {
        cameraStream = CameraStreamProvider()
        rectangleScanner = RectangleScanProvider()
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    }
    
    public convenience init(delegate: ScanRectangleViewDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    public convenience init(setupClosure: ((_ viewDidLoadOn: ScanRectangleViewController) -> Void)?) {
        self.init()
        self.setupClosure = setupClosure
    }
    
    public required init?(coder aDecoder: NSCoder) {
        cameraStream = CameraStreamProvider()
        rectangleScanner = RectangleScanProvider()
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupClosure?(self)
        bindCallbacks()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraStream.end()
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    @IBAction func takePictureButtonTapped() {
        processRectangle()
    }
    
    @IBAction func closeButtonTapped() {
        delegate?.didTapCancel(sender: self)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        isRectangleDetectionEnabled = sender.isOn
        removeSelectedRectangle()
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController {
    
    private func setupView() {
        rectangleDetectionEnabledSwitch.setOn(isRectangleDetectionEnabled, animated: false)
    }
    
    func bindCallbacks() {
        
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
    
    private func startScan() {
        scanState = .lookingForRectangle
        
        cameraStream.setupPreviewLayer(withView: cameraStreamView)
        cameraStream.start()
    }
    
    private func finish(withImage image: UIImage) {
        delegate?.didComplete(withImage: image, sender: self)
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController {
    
    private func updateHighlightedView(withRect rect: DetectedRectangle) {
        guard self.isRectangleDetectionEnabled else {
            return
        }
        let selectedShape = self.drawPolygon(rect.points, color: UIColor.red)
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
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = 2
        let path = UIBezierPath()
        path.move(to: points.last!)
        points.forEach { point in
            path.addLine(to: point)
        }
        layer.path = path.cgPath
        return layer
    }
    
    private func getRectToProcess() -> CGRect {
        return highlightedRect?.boundingBox ?? cameraStreamView.frame
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
    
    private func toggleLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
    }
}
