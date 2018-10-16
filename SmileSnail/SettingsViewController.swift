//
//  SettingsViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var patientNameTextField: UITextField!
    @IBOutlet weak var ssidTextField: UITextField!

    let settings = Settings.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        patientNameTextField.delegate = self
        ssidTextField.delegate = self

        // Do any additional setup after loading the view.
        configButtonsStyle()
        updateDeviceInfo()
        // turnOffLight()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapGesture)

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
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func configButtonsStyle() {
        for button in [cameraButton, chartButton, settingsButton, lightOnButton] {
            button?.layer.cornerRadius = 10.0
            button?.layer.borderWidth = 5
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.backgroundColor = UIColor.black.cgColor
            button?.setTitleColor(UIColor.white, for: .normal)
        }

        settingsButton.layer.backgroundColor = UIColor.white.cgColor
        settingsButton.setTitleColor(UIColor.black, for: .normal)

        if settings.light! {
            lightOnButton.layer.backgroundColor = UIColor.white.cgColor
            lightOnButton.setTitleColor(UIColor.black, for: .normal)
            lightOnButton.setTitle("Light Off", for: .normal)
        } else {
            lightOnButton.layer.backgroundColor = UIColor.black.cgColor
            lightOnButton.setTitleColor(UIColor.white, for: .normal)
            lightOnButton.setTitle("Light On", for: .normal)
        }
    }

    @objc func updateDeviceInfo() {
        // print("Received notification")
        let settings = Settings.shared
        if settings.snapshotReq! {
            // print("Snapshot Requested")
            settings.snapshotReq = false
        }

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

    func turnOffLight() {
        turnLight(on: false)
    }

    @IBAction func toggleLightPressed(_ sender: Any) {
        if lightOnButton.currentTitle! == "Light On" {
            lightOnButton.setTitle("Light Off", for: .normal)
            // lightOnButton.layer.backgroundColor = UIColor.white.cgColor
            // lightOnButton.setTitleColor(UIColor.black, for: .normal)
            turnLight(on: true)

        } else {
            lightOnButton.setTitle("Light On", for: .normal)
            // lightOnButton.layer.backgroundColor = UIColor.black.cgColor
            // lightOnButton.setTitleColor(UIColor.white, for: .normal)
            turnLight(on: false)
        }
        configButtonsStyle()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField)
        // UIView.animate(withDuration: 0.5) {
        //     self.heightConstraint.constant = 308
        //     self.view.layoutIfNeeded()
        // }
    }
    //
    func textFieldDidEndEditing(_ textField: UITextField) {
        // UIView.animate(withDuration: 0.5) {
        //     self.heightConstraint.constant = 50
        //     self.view.layoutIfNeeded()
        // }
    }

    @objc func tapped() {
        //messageTextfield.endEditing(true)
    }
}
