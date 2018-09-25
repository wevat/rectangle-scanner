//
//  ScanRectangleViewController.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 27/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import UIKit
import AVFoundation

public protocol CameraViewDelegate: class {
    func didComplete(withCroppedImage: UIImage, sender: UIViewController)
    func didComplete(withOriginalImage: UIImage, andHighlightedPoints: HighlightedPoints, sender: UIViewController)
    func didTapCancel(sender: UIViewController)
}

public extension CameraViewDelegate {
    
    ///Default implementations, either of these is to be implemented in your camera delegate, depending on what scan mode you choose
    func didComplete(withOriginalImage: UIImage, andHighlightedPoints: HighlightedPoints, sender: UIViewController) {}
    func didComplete(withCroppedImage: UIImage, sender: UIViewController) {}
}

open class CameraViewController: UIViewController {
    
    @IBOutlet var cameraStreamView: UIView!
    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet public var rectangleDetectionEnabledLabel: UILabel!
    @IBOutlet var rectangleDetectionEnabledView: UIView!
    @IBOutlet var rectangleDetectionEnabledSwitch: UISwitch!
    
    var cameraStream: CameraStreamProvider
    
    open weak var delegate: CameraViewDelegate?
    
    var setupClosure: ViewControllerDidLoadCallback?
    
    public init() {
        cameraStream = CameraStreamProvider()
        
        super.init(nibName: String(describing: CameraViewController.self), bundle: Bundle(for: CameraViewController.self))
    }
    
    public convenience init(delegate: CameraViewDelegate, setupClosure: ViewControllerDidLoadCallback? = nil) {
        self.init()
        self.delegate = delegate
        self.setupClosure = setupClosure
    }
    
    public required init?(coder aDecoder: NSCoder) {
        cameraStream = CameraStreamProvider()
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        cameraStream.load()
        setupView()
        setupClosure?(self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        cameraStream.end()
    }
    
    open override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    @IBAction func takePictureButtonTapped() {
        takePicture()
    }
    
    @IBAction func closeButtonTapped() {
        cancelled()
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValueChanged(isOn: sender.isOn)
    }
    
    open func takePicture() {
        processImage()
    }
    
    open func switchValueChanged(isOn on: Bool) {
        RectangleDetectionEnabledCache.set(on: on)
    }
    
    open func hideCameraControls(hide: Bool) {
        rectangleDetectionEnabledView.isHidden = hide
        takePictureButton.isHidden = hide
        closeButton.isHidden = hide
    }
    
    func cancelled() {
        delegate?.didTapCancel(sender: self)
    }
    
    func setupView() {
        rectangleDetectionEnabledView.isHidden = true
    }
    
    func start() {
        cameraStream.setupPreviewLayer(withView: cameraStreamView)
        cameraStream.start()
    }
    
    func finish(withImage image: UIImage) {
        delegate?.didComplete(withCroppedImage: image, sender: self)
    }
    
    func finish(withOriginalImage image: UIImage, andHighlightedPoints points: [CGPoint]?) {
        let pointsInfo = HighlightedPoints(points: points, originView: cameraStreamView)
        delegate?.didComplete(withOriginalImage: image, andHighlightedPoints: pointsInfo, sender: self)
    }
}

extension CameraViewController {
    
    private func processImage() {
        cameraStream.pause(true)
        cameraStream.animateSnapshot(withView: cameraStreamView)
        
        DispatchQueue.main.async {
            self.cameraStream.takeSnapshot { (capturedImage) in
                guard let capturedImage = capturedImage else {
                    return
                }
                self.finish(withImage: capturedImage)
            }
        }
    }
}
