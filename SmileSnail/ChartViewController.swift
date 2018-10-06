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

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deviceLabel: UILabel!

    let defaults = UserDefaults.standard
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
        }

        chartButton.backgroundColor = UIColor.white
        chartButton.setTitleColor(UIColor.black, for: .normal)

        if defaults.bool(forKey: "Light") {
            lightOnButton.backgroundColor = UIColor.white
            lightOnButton.setTitleColor(UIColor.black, for: .normal)
            lightOnButton.setTitle("Light On", for: .normal)
        } else {
            lightOnButton.backgroundColor = UIColor.black
            lightOnButton.setTitleColor(UIColor.white, for: .normal)
            lightOnButton.setTitle("Light Off", for: .normal)
        }
    }

    func updateDeviceInfo() {
        // getDeviceInfo()
        deviceLabel.text = "Device: \(settings.deviceID)"
    }

    func turnOffLight() {
        turnLight(on: false)
    }

    @IBAction func toggleLightPressed(_ sender: Any) {
        if lightOnButton.currentTitle! == "Light On" {
            // On to Off
            lightOnButton.setTitle("Light Off", for: .normal)
            turnLight(on: false)
        } else {
            lightOnButton.setTitle("Light On", for: .normal)
            turnLight(on: true)
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
        // tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "gotoImages", sender: self)
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
