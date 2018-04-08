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
    @IBOutlet var filterSwitch: UISwitch!
    
    var resultImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        resultImageView.image = resultImage
        
        if filterSwitch.isOn {
            applyBestFilter()
        }
    }
    
    private func applyBestFilter() {
        let blackAndWhiteImage = resultImage?.imageWithBlackAndWhite(value: slider.value)
        resultImageView.image = blackAndWhiteImage
    }
    
    private func resetFilters() {
        resultImageView.image = resultImage
    }
    
    @IBAction func filterSwitchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            applyBestFilter()
        } else {
            resetFilters()
        }
    }
    
    @IBAction func noneButtonTapped() {
        resetFilters()
    }
    
    @IBAction func constrastButtonTapped() {
        let constastImage = resultImage?.imageWithAdjustedContrast(value: slider.value)
        resultImageView.image = constastImage
    }
    
    @IBAction func blackAndWhiteButtonTapped() {
        applyBestFilter()
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
