//
//  ScanRectangleViewController.swift
//  ReceiptScanner
//
//  Created by Harry Bloom on 27/03/2018.
//  Copyright © 2018 WeVat. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import AVFoundation

public protocol ScanRectangleViewDelegate: class {
    func didComplete(withImage: UIImage, sender: UIViewController)
    func didTapCancel(sender: UIViewController)
}

@available(iOS 11.0, *)
public class ScanRectangleViewController: UIViewController, BackgroundCameraStreamPresenter {
    @IBOutlet var loadingView: UIView!
    @IBOutlet var cameraStreamView: UIView!
    @IBOutlet var instructionView: UIView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    private var selectedRectangleOutlineLayer: CAShapeLayer?
    private var selectedRectangleObservation: VNRectangleObservation?
    private var selectedRectangleLastUpdated: Date?
    private var currTouchLocation: CGPoint?
    private var searchingForRectangles = false
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    private var surfaceNodes = [ARPlaneAnchor:SurfaceNode]()
    
    public weak var delegate: ScanRectangleViewDelegate?
    
    private var scanState: ScanState = .lookingForRectangle {
        didSet {
            instructionLabel.text = scanState.description()
            toggleLoading(scanState.isProcessing())
        }
    }
    
    private var setupClosure: ((_ viewDidLoadOn: ScanRectangleViewController) -> Void)?
    
    var backgroundCameraStream: DispatchQueue
    
    deinit {
        print("ScanRectangleViewController deinited")
    }
    
    public init() {
        backgroundCameraStream = DispatchQueue(label: "camera", attributes: .concurrent)
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
        backgroundCameraStream = DispatchQueue(label: "camera")
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

        startScan()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        endCameraStream()
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let currentFrame = sceneView.session.currentFrame else {
                return
        }
        guard scanState.isProcessing() == false else {
            return
        }
        currTouchLocation = touch.location(in: sceneView)
        findRectangle(locationInScene: currTouchLocation!, frame: currentFrame)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard scanState.isProcessing() == false else {
            return
        }
        // Ignore if we're currently searching for a rect
        if searchingForRectangles {
            return
        }
        
        guard let touch = touches.first,
            let currentFrame = sceneView.session.currentFrame else {
                return
        }
        
        currTouchLocation = touch.location(in: sceneView)
        findRectangle(locationInScene: currTouchLocation!, frame: currentFrame)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard scanState.isProcessing() == false else {
            return
        }
        currTouchLocation = nil
        
        guard let selectedRectangle = selectedRectangleOutlineLayer?.path?.boundingBox else {
            return
        }
        
        processRectangle(selectedRectangle)
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController {
    
    private func setupView() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    private func startScan() {
        let scene = SCNScene()
        sceneView.scene = scene
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
        scanState = .lookingForRectangle
        removeSelectedRectangle()
    }
    
    private func finish(withImage image: UIImage) {
        delegate?.didComplete(withImage: image, sender: self)
    }
    
    private func findRectangle(locationInScene location: CGPoint, frame currentFrame: ARFrame) {
        // Note that we're actively searching for rectangles
        searchingForRectangles = true
        selectedRectangleObservation = nil
        
        // Perform request on background thread
        DispatchQueue.global(qos: .background).async {
            let request = VNDetectRectanglesRequest(completionHandler: { (request, error) in
                
                // Jump back onto the main thread
                DispatchQueue.main.async {
                    guard self.scanState.isProcessing() == false else {
                        return
                    }
                    
                    // Mark that we've finished searching for rectangles
                    self.searchingForRectangles = false
                    
                    // Access the first result in the array after casting the array as a VNClassificationObservation array
                    guard let observations = request.results as? [VNRectangleObservation],
                        let _ = observations.first else {
                            print ("No results")
                            self.scanState = .couldntFindRectangle
                            return
                    }
                    
                    print("\(observations.count) rectangles found")
                    
                    self.removeSelectedRectangle()
                    
                    // Find the rect that overlaps with the given location in sceneView
                    guard let selectedRect = observations.filter({ (result) -> Bool in
                        let convertedRect = self.sceneView.convertFromCamera(result.boundingBox)
                        return convertedRect.contains(location)
                    }).first else {
                        print("No results at touch location")
                        self.scanState = .couldntFindRectangle
                        return
                    }
                    
                    // Outline selected rectangle
                    let points = [selectedRect.topLeft, selectedRect.topRight, selectedRect.bottomRight, selectedRect.bottomLeft]
                    let convertedPoints = points.map { self.sceneView.convertFromCamera($0) }
                    
                    self.addSelectedRectangle(fromObservation: selectedRect, withConvertedPoints: convertedPoints)
                    self.scanState = .releaseRectangle
                }
            })
            
            // Perform request
            let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
            try? handler.perform([request])
        }
    }
    
    private func addPlaneRect(for observedRect: VNRectangleObservation) {
        removeSelectedRectangle()
        
        // Convert to 3D coordinates
        guard let planeRectangle = PlaneRectangle(for: observedRect, in: sceneView) else {
            print("No plane for this rectangle")
            self.scanState = .couldntFindRectangle
            return
        }
        
        let rectangleNode = RectangleNode(planeRectangle)
        sceneView.scene.rootNode.addChildNode(rectangleNode)
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
    
    private func addSelectedRectangle(fromObservation observation: VNRectangleObservation, withConvertedPoints points: [CGPoint]) {
        let selectedShape = self.drawPolygon(points, color: UIColor.red)
        self.selectedRectangleOutlineLayer = selectedShape
        self.sceneView.layer.addSublayer(selectedShape)
        self.selectedRectangleObservation = observation
        self.selectedRectangleLastUpdated = Date()
    }
    
    private func removeSelectedRectangle() {
        if let layer = selectedRectangleOutlineLayer {
            layer.removeFromSuperlayer()
            selectedRectangleOutlineLayer = nil
            selectedRectangleObservation = nil
        }
    }
    
    private func processRectangle(_ rect: CGRect) {
        scanState = .processingRectangle
        sceneView.session.pause()
        sceneView.stop(self)
        print("Scan paused at: \(Date().timeIntervalSince1970)")
        
        try? self.initialiseSession()
        setupPreviewLayer(withView: cameraStreamView)
        startCameraStream()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.takeSnapshot { (fullResImage) in
                guard let fullResImage = fullResImage else {
                    self.scanState = .couldntFindRectangle
                    return
                }
                print("Photo taken at: \(Date().timeIntervalSince1970)")
                let lowResImage = self.sceneView.snapshot()
                ScreenshotHelper.processScreenshot(fromImage: lowResImage, toImage: fullResImage, croppingTo: rect) { (croppedImage) in
                    print("Photo processed at: \(Date().timeIntervalSince1970)")
                    self.finish(withImage: croppedImage)
                }
                self.endCameraStream()
            }
        }
    }
    
    private func toggleLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController: ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let currTouchLocation = currTouchLocation,
            let currentFrame = sceneView.session.currentFrame else {
                return
        }
        if selectedRectangleLastUpdated?.timeIntervalSinceNow ?? 0 < 1 {
            return
        }
        
        findRectangle(locationInScene: currTouchLocation, frame: currentFrame)
    }
}

@available(iOS 11.0, *)
extension ScanRectangleViewController: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let surface = SurfaceNode(anchor: anchor)
        surfaceNodes[anchor] = surface
        node.addChildNode(surface)
        
        scanState = .lookingForRectangle
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor,
            let surface = surfaceNodes[anchor] else {
                return
        }
        
        surface.update(anchor)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor,
            let surface = surfaceNodes[anchor] else {
                return
        }
        
        surface.removeFromParentNode()
        surfaceNodes.removeValue(forKey: anchor)
    }
}
