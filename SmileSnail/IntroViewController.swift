//
//  ViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!

    @IBOutlet weak var deviceLabel: UILabel!

    let defaults = UserDefaults.standard
    let settings = Settings.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        configButtonsStyle()
        updateDeviceInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configButtonsStyle() {
        for button in [cameraButton, chartButton, settingsButton, lightOnButton] {
            button?.layer.cornerRadius = 10.0
            button?.layer.borderWidth = 5
            button?.layer.borderColor = UIColor.white.cgColor
        }
    }

    func updateDeviceInfo() {
        // getDeviceInfo()
        deviceLabel.text = "Device: \(Settings.shared.deviceID)"
    }

    @IBAction func toggleLight(_ sender: UIButton) {
        if lightOnButton.currentTitle! == "Light On" {
            lightOnButton.setTitle("Light Off", for: .normal)
            turnLight(on: true)
        } else {
            lightOnButton.setTitle("Light On", for: .normal)
            turnLight(on: false)
        }
    }


}
