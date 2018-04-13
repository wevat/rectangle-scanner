//
//  ViewController.swift
//  RectangleScanner
//
//  Created by harryblam on 03/27/2018.
//  Copyright (c) 2018 harryblam. All rights reserved.
//

import UIKit
import RectangleScanner

class ViewController: UIViewController, ScanRectangleViewProvider {
    
    var scannedImage: UIImage?
    
    @IBAction func startButtonTapped() {
        
        startScan(delegate: self)
    }
}

extension ViewController: CameraViewDelegate {
    
    func didComplete(withCroppedImage image: UIImage, sender: UIViewController) {
        sender.dismiss(animated: true) { [weak self] in
            self?.scannedImage = image
            self?.performSegue(withIdentifier: "ResultSegue", sender: nil)
        }
    }
    
    func didTapCancel(sender: UIViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.resultImage = scannedImage
        }
    }
}
