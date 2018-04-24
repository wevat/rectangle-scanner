//
//  BackgroundCameraStreamProvider.swift
//  RectangleScanner
//
//  Created by Harry Bloom on 29/03/2018.
//

import UIKit
import AVFoundation

class CameraStreamProvider: NSObject {
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureVideoDataOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var bufferDidUpdate: ((_ buffer: CVPixelBuffer) -> Void)?
    
    override init() {
        super.init()
    }
    
    func load() {
        try? self.initialiseSession()
    }
    
    func start() {
        if captureSession != nil, captureSession?.isRunning == false {
            captureSession?.startRunning()
            pause(false)
        }
    }
    
    func end() {
        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }
    
    func pause(_ on: Bool) {
        previewLayer?.connection?.isEnabled = !on
    }
    
    func initialiseSession() throws {
        
        captureSession = AVCaptureSession()
        videoOutput = AVCaptureVideoDataOutput()
        stillImageOutput = AVCaptureStillImageOutput()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            throw ScanError()
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            captureSession = nil
            throw ScanError()
        }
        
        if let session = captureSession, session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            captureSession = nil
            throw ScanError()
        }
        
        setupVideoCaptureDevice(videoCaptureDevice)
        configureDeviceForHighestFrameRate(videoCaptureDevice)
        
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        
        if let session = captureSession, let videoOutput = videoOutput, session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "CameraStream"))
            session.addOutput(videoOutput)
        }
        
        if let session = captureSession, let stillImageOutput = stillImageOutput, session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    private func setupVideoCaptureDevice(_ device: AVCaptureDevice) {
        try? device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }
        if device.isLowLightBoostSupported {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }
        device.unlockForConfiguration()
    }
    
    private func configureDeviceForHighestFrameRate(_ device: AVCaptureDevice) {
        var bestFormat: AVCaptureDevice.Format?
        var bestFrameRate: AVFrameRateRange?
        
        for format in device.formats {
            for frameRateRange in format.videoSupportedFrameRateRanges {
                if frameRateRange.maxFrameRate > bestFrameRate?.maxFrameRate ?? 0 {
                    bestFormat = format
                    bestFrameRate = frameRateRange
                }
            }
        }
        
        if let bestFormat = bestFormat, let bestFrameRate = bestFrameRate {
            try? device.lockForConfiguration()
            device.activeFormat = bestFormat
            device.activeVideoMaxFrameDuration = bestFrameRate.maxFrameDuration
            device.activeVideoMinFrameDuration = bestFrameRate.minFrameDuration
        }
    }
    
    func setupPreviewLayer(withView view: UIView) {
        guard let captureSession = captureSession else {
            return
        }
        
        if self.previewLayer == nil {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.backgroundColor = UIColor.black.cgColor
            view.layer.addSublayer(previewLayer)
            
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.duration = 0.25
            fadeAnimation.fromValue = 0
            fadeAnimation.toValue = 1
            fadeAnimation.isRemovedOnCompletion = true
            
            previewLayer.add(fadeAnimation, forKey: "opacity")
            self.previewLayer = previewLayer
        } else {
            self.previewLayer?.frame = view.layer.bounds
        }
    }
    
    func takeSnapshot(_ completion: @escaping (_ result: UIImage?) -> Void) {
        if let stillImageOutput = stillImageOutput, let videoConnection = stillImageOutput.connection(with: .video) {

            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in

                guard let imageDataSampleBuffer = imageDataSampleBuffer, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer),
                    let image = UIImage(data: imageData) else {
                        completion(nil)
                        return
                }
                let croppedImage = self.cropToPreviewLayer(originalImage: image)
                completion(croppedImage)
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
    
    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage {
        let outputRect = previewLayer!.metadataOutputRectConverted(fromLayerRect: previewLayer!.bounds)
        var cgImage = originalImage.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        
        cgImage = cgImage.cropping(to: cropRect)!
        let croppedUIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
}

extension CameraStreamProvider: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        bufferDidUpdate?(pixelBuffer)
    }
}

extension CameraStreamProvider: AVCaptureMetadataOutputObjectsDelegate {
    
    func initialiseSession(withView view: UIView, andMetadataTypes: [AVMetadataObject.ObjectType]? = nil) throws -> AVCaptureSession? {
        
        let captureSession = try initialiseSession(withView: view)
        
        if let types = andMetadataTypes, let captureSession = captureSession {
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = types
            } else {
                throw ScanError()
            }
        }
        
        return captureSession
    }
}
