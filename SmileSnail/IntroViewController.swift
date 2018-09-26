//
//  ViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import ChameleonFramework

class IntroViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configButtonsStyle()
        // updateDeviceInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configButtonsStyle() {
        for button in [cameraButton, chartButton, settingsButton, lightOnButton] {
            button?.layer.cornerRadius = 20.0
            button?.layer.borderWidth = 5
            button?.layer.borderColor = UIColor.flatWhite.cgColor            
        }
    }
    
    
    @IBAction func toggleLight(_ sender: UIButton) {
        if lightOnButton.currentTitle! == "Light On" {
            lightOnButton.setTitle("Light Off", for: .normal)
            defaults.set(true, forKey: "Light")
        } else {
            lightOnButton.setTitle("Light On", for: .normal)
            defaults.set(false, forKey: "Light")
        }
    }
    

}

