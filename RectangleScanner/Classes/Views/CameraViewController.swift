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

public protocol CameraViewDelegate: class {
    func didComplete(withCroppedImage: UIImage, sender: UIViewController)
    func didComplete(withOriginalImage: UIImage, andHighlightedPoints: [CGPoint], sender: UIViewController)
    func didTapCancel(sender: UIViewController)
}

public extension CameraViewDelegate {
    
    ///Default implementations, either of these is to be implemented in your camera delegate, depending on what scan mode you choose
    func didComplete(withOriginalImage: UIImage, andHighlightedPoints: [CGPoint], sender: UIViewController) {}
    func didComplete(withCroppedImage withImage: UIImage, sender: UIViewController) {}
}

public typealias CameraViewControllerDidLoad = ((_ viewDidLoadOn: CameraViewController) -> Void)

public class CameraViewController: UIViewController {
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet var cameraStreamView: UIView!
    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var rectangleDetectionEnabledView: UIView!
    @IBOutlet var rectangleDetectionEnabledSwitch: UISwitch!
    
    var cameraStream: CameraStreamProvider
    
    public weak var delegate: CameraViewDelegate?
    
    var setupClosure: CameraViewControllerDidLoad?
    
    public init() {
        cameraStream = CameraStreamProvider()
        super.init(nibName: String(describing: CameraViewController.self), bundle: Bundle(for: type(of: self)))
    }
    
    public convenience init(delegate: CameraViewDelegate, setupClosure: CameraViewControllerDidLoad? = nil) {
        self.init()
        self.delegate = delegate
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
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
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
        takePicture()
    }
    
    @IBAction func closeButtonTapped() {
        cancelled()
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValueChanged(isOn: sender.isOn)
    }
    
    func takePicture() {
        processImage()
    }
    
    func cancelled() {
        delegate?.didTapCancel(sender: self)
    }
    
    func switchValueChanged(isOn: Bool) {
    }
    
    func setupView() {
        rectangleDetectionEnabledView.isHidden = true
        toggleLoading(false)
    }
    
    func start() {
        cameraStream.setupPreviewLayer(withView: cameraStreamView)
        cameraStream.start()
    }
    
    func finish(withImage image: UIImage) {
        delegate?.didComplete(withCroppedImage: image, sender: self)
    }
    
    func finish(withOriginalImage image: UIImage, andHighlightedPoints points: [CGPoint]) {
        delegate?.didComplete(withOriginalImage: image, andHighlightedPoints: points, sender: self)
    }
    
    func toggleLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
    }
}

extension CameraViewController {
    
    private func processImage() {
        cameraStream.pause(true)
        toggleLoading(true)
        DispatchQueue.main.async {
            self.cameraStream.takeSnapshot { (capturedImage) in
                guard let capturedImage = capturedImage else {
                    return
                }
                self.toggleLoading(false)
                self.finish(withImage: capturedImage)
            }
        }
    }
}
