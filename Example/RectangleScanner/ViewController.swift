//
//  ViewController.swift
//  RectangleScanner
//
//  Created by harryblam on 03/27/2018.
//  Copyright (c) 2018 harryblam. All rights reserved.
//

import UIKit
import RectangleScanner

class ViewController: UIViewController {
    
    var scannedImage: UIImage?
    
    @IBAction func startButtonTapped() {
        
        if #available(iOS 11.0, *) {
            startScanFlow()
        } else {
            showAlert()
        }
    }
    
    @available(iOS 11.0, *)
    private func startScanFlow() {
        
        let scanView = ScanRectangleViewController()
        present(scanView, animated: true, completion: nil)
        
        scanView.scannedRectangleCallback = {[weak self] scannedImage in
            
            self?.scannedImage = scannedImage
            self?.performSegue(withIdentifier: "ResultSegue", sender: self)
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Unsupported version", message: "You can only use the scan functionality on iOS 11 or later. Sorry!", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.resultImage = scannedImage
        }
    }
}
