//
//  ResultViewController.swift
//  RectangleScanner_Example
//
//  Created by Harry Bloom on 27/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RectangleScanner

class ResultViewController: UIViewController {

    @IBOutlet var resultImageView: UIImageView!
    
    var resultImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        resultImageView.image = resultImage
    }
}
