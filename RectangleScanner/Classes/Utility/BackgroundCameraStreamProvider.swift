//
//  BackgroundCameraStreamProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 29/03/2018.
//

import UIKit
import AVFoundation

protocol BackgroundCameraStreamPresenter: class {
    
    func initialiseSession() throws
    func startCameraStream()
    func endCameraStream()
    func pauseCameraStream(pause: Bool)
    func setupPreviewLayer(withView view: UIView)
    func takeSnapshot(_ completion: @escaping (_ result: UIImage?) -> Void)
    func animateSnapshot(withView view: UIView)
    
    var captureSession: AVCaptureSession? { get set }
    var previewLayer: AVCaptureVideoPreviewLayer? { get set }
    var stillImageOutput: AVCaptureStillImageOutput? { get set }
}

extension BackgroundCameraStreamPresenter  {
    
    func startCameraStream() {
        if captureSession != nil, captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }
    
    func endCameraStream() {
        
        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }
    
    func pauseCameraStream(pause: Bool) {
        previewLayer?.connection?.isEnabled = !pause
    }
    
    func initialiseSession() throws {
        
        captureSession = AVCaptureSession()
        stillImageOutput = AVCaptureStillImageOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            throw ScanError(description: "Camera unavailiable")
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            captureSession = nil
            throw ScanError(description: "Camera unavailiable")
        }
        
        if let session = captureSession, session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            captureSession = nil
            throw ScanError(description: "Camera unavailiable")
        }
        
        stillImageOutput?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        
        if let session = captureSession, let stillImageOutput = stillImageOutput, session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    func setupPreviewLayer(withView view: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(previewLayer)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.duration = 0.25
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        
        previewLayer.add(fadeAnimation, forKey: "opacity")
        self.previewLayer = previewLayer
    }
    
    func takeSnapshot(_ completion: @escaping (_ result: UIImage?) -> Void) {
        if let stillImageOutput = stillImageOutput, let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                guard let imageDataSampleBuffer = imageDataSampleBuffer, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer),
                    let image = UIImage(data: imageData) else {
                        completion(nil)
                        return
                }
                completion(image)
            }
        } else {
            completion(nil)
        }
    }
    
    func animateSnapshot(withView view: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0
        }) { (completed) in
            view.alpha = 1
        }
    }
}

extension BackgroundCameraStreamPresenter where Self: AVCaptureMetadataOutputObjectsDelegate {
    
    func initialiseSession(withView view: UIView, andMetadataTypes: [AVMetadataObject.ObjectType]? = nil) throws -> AVCaptureSession? {
        
        let captureSession = try initialiseSession(withView: view)
        
        if let types = andMetadataTypes, let captureSession = captureSession {
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = types
            } else {
                throw ScanError(description: "Camera unavailiable")
            }
        }
        
        return captureSession
    }
    
}
