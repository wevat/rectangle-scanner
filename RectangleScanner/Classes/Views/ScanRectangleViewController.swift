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
    @IBOutlet var instructionView: UIView?
    @IBOutlet var instructionLabel: UILabel?
    @IBOutlet var highlightView: UIView!
    @IBOutlet var takePictureButton: UIButton!
    
    var cameraStream: CameraStreamProvider
    
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private var lastObservation: VNDetectedObjectObservation?
    
    public weak var delegate: ScanRectangleViewDelegate?
    
    private var highlightedRect: CGRect? {
        didSet {
            guard oldValue != highlightedRect else { return }
            guard let highlightedRect = highlightedRect else { return }
            updateHighlightedView(withRect: highlightedRect)
        }
    }
    
    private var scanState: ScanState = .lookingForRectangle {
        didSet {
            instructionLabel?.text = scanState.description()
            toggleLoading(scanState.isProcessing())
        }
    }
    
    private var setupClosure: ((_ viewDidLoadOn: ScanRectangleViewController) -> Void)?
    
    deinit {
        print("ScanRectangleViewController deinited")
    }
    
    public init() {
        cameraStream = CameraStreamProvider()
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
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupClosure?(self)
        bindCameraBuffer()
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
}

@available(iOS 11.0, *)
extension ScanRectangleViewController {
    
    private func setupView() {
        highlightView.layer.borderColor = UIColor.red.cgColor
        highlightView.layer.borderWidth = 3
        highlightView.isHidden = true
    }
    
    func bindCameraBuffer() {
        
        cameraStream.bufferDidUpdate = { buffer in
            let request = VNDetectRectanglesRequest { (request, error) in
                self.rectangleRequestDidComplete(request: request, error: error)
            }
            
            do {
                request.minimumConfidence = 0.8
                try self.visionSequenceHandler.perform([request], on: buffer)
            } catch {
                print("Throws: \(error)")
            }
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
    
    func rectangleRequestDidComplete(request: VNRequest, error: Error?) {
        guard let results = request.results,
              let rectangle = results.first as? VNRectangleObservation,
              results.count > 0 else {
            return
        }
        
        print("Results count: \(results.count)")
        
        DispatchQueue.main.async {
            guard let convertedRect = self.cameraStream.previewLayer?.layerRectConverted(fromMetadataOutputRect: rectangle.boundingBox) else {
                return
            }
            self.highlightedRect = convertedRect
        }
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController {
    
    private func updateHighlightedView(withRect rect: CGRect) {
        highlightView.frame = rect
        highlightView.isHidden = false
        cameraStreamView.bringSubview(toFront: highlightView)
    }
    
    private func getRectToProcess() -> CGRect {
        return highlightedRect ?? cameraStreamView.frame
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
                print("Photo taken at: \(Date().timeIntervalSince1970)")
                
                let rectToCropTo = self.getRectToProcess()
                ScreenshotHelper.processScreenshot(capturedImage, fromViewRect: self.cameraStreamView.frame, croppingTo: rectToCropTo) { (croppedImage) in
                    print("Photo processed at: \(Date().timeIntervalSince1970)")
                    self.finish(withImage: croppedImage)
                }
            }
        }
    }
    
    private func toggleLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
    }
}
