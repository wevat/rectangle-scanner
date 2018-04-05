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
        var constastImage = resultImage?.imageWithAdjustedContrast(value: slider.value)
        resultImageView.image = constastImage
    }
    
    @IBAction func greyscaleButtonTapped() {
        var greyscale = resultImage?.imageWithGreyscale()
        resultImageView.image = greyscale
    }
    
    @IBAction func brightnessButtonTapped() {
        var brightness = resultImage?.imageWithAdjustedBrightness(value: slider.value)
        resultImageView.image = brightness
    }
    
    @IBAction func allButtonTapped() {
        var all = resultImage?.imageWithGreyscale().imageWithAdjustedContrast(value: slider.value)
        resultImageView.image = all
    }
}
