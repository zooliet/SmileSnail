//
//  ChartViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChartViewController: UIViewController  {
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    let settings = Settings.shared

    var patientList: [String: Int] = [String: Int]()
    // var patientList: [String: Int] = ["NONAME": 4, "홍길동": 10, "Anna Kim": 3]
    var patientListSorted: [(key: String, value: Int)] = [(key: String, value: Int)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configButtonsStyle()
        updateDeviceInfo()
        // turnOffLight()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0

        // tableView.register(UINib(nibName: "PatientCell", bundle: nil) , forCellReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.

        let fm = FileManager.default
        let path = getDocumentsDirectory().path
        print(path)
        let fileList = try! fm.contentsOfDirectory(atPath: path)
        for fileName in fileList {
            let patient = String(fileName.split(separator: "_")[0])
            if patientList.keys.contains(patient) {
                patientList[patient] = patientList[patient]! + 1
            } else {
                patientList[patient] = 1
            }
        }
        // print("****\(patientList)")
        // print("***\(patientList.sorted(by: <))")
        patientListSorted = patientList.sorted(by: <)
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

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoImages" {
            let destinationVC = segue.destination as! ChartImageViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selected = patientListSorted[indexPath.row].key
            }
        }
    }

    func configButtonsStyle() {
        for button in [cameraButton, chartButton, settingsButton, lightOnButton] {
            button?.layer.cornerRadius = 10.0
            button?.layer.borderWidth = 5
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.backgroundColor = UIColor.black.cgColor
            button?.setTitleColor(UIColor.white, for: .normal)
        }

        chartButton.layer.backgroundColor = UIColor.white.cgColor
        chartButton.setTitleColor(UIColor.black, for: .normal)

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
            print("Snapshot Requested")
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
}

extension  ChartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // cell.delegate = self
        // cell.videoLabel.text = "\(String(format: "%03d", indexPath.row+1)). \(Date()) No Name" // messages[indexPath.row]
        
        cell.textLabel?.text = patientListSorted[indexPath.row].key
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ChartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoImages", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// extension ChartViewController: SwipeTableViewCellDelegate {
//     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//         // let message = messages[indexPath.row]
//         guard orientation == .right else { return nil }
//         let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//             // self.updateModel(at: indexPath)
//         }
//         // customize the action appearance
//         deleteAction.image = UIImage(named: "delete-icon")
//         return [deleteAction]
//     }
// }

// class PatientCell: SwipeTableViewCell {
//     @IBOutlet weak var patientLabel: UILabel!
//
//     override func awakeFromNib() {
//         // setupIndicatorView()
//     }
// }
