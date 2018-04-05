//
//  ResultViewController.swift
//  RectangleScanner_Example
//
//  Created by Harry Bloom on 27/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RectangleScanner
//import GPUImage

class ResultViewController: UIViewController {

    @IBOutlet var resultImageView: UIImageView!
    @IBOutlet var slider: UISlider!
    
    var resultImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultImageView.image = resultImage
    }
    
    @IBAction func noneButtonTapped() {
        resultImageView.image = resultImage
    }
    
    @IBAction func constrastButtonTapped() {
        let constastImage = resultImage?.imageWithAdjustedContrast(value: slider.value)
        resultImageView.image = constastImage
    }
    
    @IBAction func blackAndWhiteButtonTapped() {
        let blackAndWhiteImage = resultImage?.imageWithBlackAndWhite(value: slider.value)
        resultImageView.image = blackAndWhiteImage
    }
    
    @IBAction func brightnessButtonTapped() {
        let brightness = resultImage?.imageWithAdjustedBrightness(value: slider.value)
        resultImageView.image = brightness
    }
    
    @IBAction func allButtonTapped() {
        let all = resultImage?.imageWithAdjustedContrast(value: slider.value).imageWithBlackAndWhite(value: slider.value)
        resultImageView.image = all
    }
}
