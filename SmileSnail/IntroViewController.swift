//
//  ViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!

    let settings = Settings.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        configButtonsStyle()
        updateDeviceInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceInfo), name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configButtonsStyle() {
        for button in [cameraButton, chartButton, settingsButton, lightOnButton] {
            button?.layer.cornerRadius = 10.0
            button?.layer.borderWidth = 5
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.backgroundColor = UIColor.black.cgColor
            button?.setTitleColor(UIColor.white, for: .normal)
        }
    }

    @objc func updateDeviceInfo() {
        // print("Received notification")
        let settings = Settings.shared

        DispatchQueue.main.async {
            let deviceID = settings.deviceID!
            let batteryLevel = settings.batteryLevel!

            if deviceID == "" {
                self.deviceLabel.text = "Not connected"
                self.batteryLabel.text = ""
            } else {
                self.deviceLabel.text = "Device: \(deviceID)"
                self.batteryLabel.text = "Battery: \(batteryLevel)%"
            }
            self.deviceLabel.setNeedsDisplay()
            self.batteryLabel.setNeedsDisplay()
        }
    }

    @IBAction func toggleLight(_ sender: UIButton) {
        if lightOnButton.currentTitle! == "Light On" {
            lightOnButton.setTitle("Light Off", for: .normal)
            lightOnButton.layer.backgroundColor = UIColor.white.cgColor
            lightOnButton.setTitleColor(UIColor.black, for: .normal)
            turnLight(on: true)

        } else {
            lightOnButton.setTitle("Light On", for: .normal)
            lightOnButton.layer.backgroundColor = UIColor.black.cgColor
            lightOnButton.setTitleColor(UIColor.white, for: .normal)
            turnLight(on: false)
        }
    }


}
