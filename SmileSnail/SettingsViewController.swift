//
//  SettingsViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import SVProgressHUD


class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var patientNameTextField: UITextField!
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!

    let settings = Settings.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsVC: viewDidLoad()")
        configButtons(settings.light!)

        patientNameTextField.delegate = self
        ssidTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapGesture)

//        patientNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        ssidTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SettingVC: viewWillAppear()")

        getDeviceInfo() { (deviceId, ssid, error)  in
            if error != nil {
                self.settings.deviceID = ""
                self.settings.ssid = ""
            } else {
                self.settings.deviceID = deviceId!
                self.settings.ssid = ssid!
            }
        }

        configTextFields()
        updateDeviceInfo()

        // turnOffLight()
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceInfo), name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SettingVC: viewWillDisappear()")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    deinit {
        print("SettingVC: deinit()")
        // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



//    @objc func textFieldDidChange(_ textField: UITextField) {
//        textField.textColor = UIColor.white
//    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func configTextFields() {
        patientNameTextField.text = settings.patientName
        ssidTextField.text = settings.ssid

        patientNameTextField.textColor = UIColor.lightGray
        ssidTextField.textColor = UIColor.lightGray
        //patientNameTextField.isUserInteractionEnabled = false
        //ssidTextField.isUserInteractionEnabled = false
    }

    @objc func updateDeviceInfo() {
        // print("Received notification")
        let settings = Settings.shared
        if settings.snapshotReq! {
            // print("Snapshot Requested")
            settings.snapshotReq = false
        }

        DispatchQueue.main.async {
            let deviceID = settings.deviceID ?? ""
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

    @IBAction func menuTapped(_ sender: UIButton) {
        // print(sender.currentTitle!)
        var destinationClassType: AnyClass?
        var destinationClassIdentifier: String?

        if sender.currentTitle == "Camera" {
            destinationClassType = CameraViewController.self
            destinationClassIdentifier = "CameraVC"
        } else if sender.currentTitle == "Chart" {
            destinationClassType = ChartViewController.self
            destinationClassIdentifier = "ChartVC"
        }

        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: destinationClassType!) {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: destinationClassIdentifier!)
        self.navigationController?.pushViewController(destinationVC!, animated: true)
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
        configButtons(settings.light!)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.white
        // UIView.animate(withDuration: 0.5) {
        //     self.heightConstraint.constant = 308
        //     self.view.layoutIfNeeded()
        // }
    }
    //

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = UIColor.lightGray
    }

    @objc func tapped() {
        //messageTextfield.endEditing(true)
        patientNameTextField.endEditing(true)
        ssidTextField.endEditing(true)
    }

    @IBAction func updateButtonPressed(_ sender: UIButton) {
        patientNameTextField.endEditing(true)
        ssidTextField.endEditing(true)

        SVProgressHUD.show()

        if patientNameTextField.text != settings.patientName {
            settings.patientName = patientNameTextField.text
        }

        // if settings.deviceId != "" {
        //
        // }

        if (ssidTextField.text == settings.ssid) || ssidTextField.text!.count == 0 {
            patientNameTextField.text = settings.patientName
            SVProgressHUD.dismiss()
        } else {
            setDeviceSsid(ssid: ssidTextField.text!) { result  in
                SVProgressHUD.dismiss()
                // print(result)
                if result == "Success" {
                    self.settings.patientName = self.patientNameTextField.text
                    let alert = UIAlertController(title: "SSID Changed!", message: "You need to turn off and on the device.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.patientNameTextField.text = self.settings.patientName
                }
            }
        }
    }
}
