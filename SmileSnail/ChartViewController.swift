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
        // print("ChartVC: viewDidLoad()")
        configButtons(settings.light!)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80.0

        // tableView.register(UINib(nibName: "PatientCell", bundle: nil) , forCellReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.

        // loadPatientList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // print("ChartVC: viewWillAppear()")

        loadPatientList()
        updateDeviceInfo()
        // turnLight(on: false)

        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceInfo), name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // print("ChartVC: viewWillDisappear()")

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    deinit {
        // print("ChartVC: deinit()")
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: self)
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

    @IBAction func menuTapped(_ sender: UIButton) {
        // print(sender.currentTitle!)
        navigateCtrl(sender: sender, navigationController: self.navigationController)
    }

    @IBAction func toggleLightPressed(_ sender: Any) {
        toggleLight(lightOnButton)
        configButtons(settings.light!)
    }

    func loadPatientList() {
        let fm = FileManager.default
        let path = getDocumentsDirectory().path
        // print(path)
        let fileList = try! fm.contentsOfDirectory(atPath: path)

        patientList = fileList.reduce([String: Int]()) { (dict, fileName) -> [String: Int] in
            var dict = dict
            let patient = String(fileName.split(separator: "_")[0])
            if let numberOfPhotos = dict[patient] {
                dict[patient] = numberOfPhotos + 1
            } else {
                dict[patient] = 1
            }
            return dict
        }
        // print("****\(patientList)")
        // print("***\(patientList.sorted(by: <))")
        patientListSorted = patientList.sorted(by: <)
    }

    @objc func updateDeviceInfo() {
        // print("Received notification")
        if settings.snapshotReq! {
            // print("Snapshot Requested")
            settings.snapshotReq = false
        }
        updateStatusLabel(deviceLabel: self.deviceLabel, batteryLabel: self.batteryLabel)
    }
}

extension  ChartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print(patientList)
        return patientListSorted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        // cell.videoLabel.text = "\(String(format: "%03d", indexPath.row+1)). \(Date()) No Name" // messages[indexPath.row]

        cell.textLabel?.text = patientListSorted[indexPath.row].key
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func deleteImages(at indexPath: IndexPath) {
        print("\(indexPath.row): \(patientListSorted[indexPath.row].key)")
    }
}

extension ChartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoImages", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChartViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let nameSuffix = self.patientListSorted[indexPath.row].key

            let fm = FileManager.default
            let path = getDocumentsDirectory().path
            // print(path)
            var fileList: [String] = [String]()

            do {
                fileList = try fm.contentsOfDirectory(atPath: path).filter { fileName in
                    return fileName.hasPrefix(nameSuffix)
                }
            } catch { print("Error in File Listing") }

            for f in fileList {
                let removeFile = getDocumentsDirectory().appendingPathComponent(f)
                do {
                    try fm.removeItem(at: removeFile)
                } catch { print("Error in deleting a file") }
            }
            self.patientListSorted.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        // customize the action appearance
        // deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }

    // func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    //     var options = SwipeOptions()
    //     options.backgroundColor = UIColor.clear
    //     options.expansionStyle = .none
    //     options.transitionStyle = .border
    //     return options
    // }
}

// class PatientCell: SwipeTableViewCell {
//     @IBOutlet weak var patientLabel: UILabel!
//
//     override func awakeFromNib() {
//         // setupIndicatorView()
//     }
// }
