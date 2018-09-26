//
//  ChartViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let defaults = UserDefaults.standard
    
    var messages = ["Bush", "HL1SQI", "ZOOLU"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80.0
        
        // videoTableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil) , forCellReuseIdentifier: "videoTableViewCell")
        // Do any additional setup after loading the view.
        
        configButtonsStyle()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.delegate = self
        cell.videoLabel.text = "\(String(format: "%03d", indexPath.row+1)). \(Date()) No Name" // messages[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        let message = messages[indexPath.row]
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            // self.updateModel(at: indexPath)
        }
        
        // customize the action appearance
        // deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "gotoImages", sender: self)
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "gotoImages" {
            let destinationVC = segue.destination as! ChartImageViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selected = indexPath.row
            }
        }
    }
    
    
    func configButtonsStyle() {
        for button in [cameraButton, chartButton, settingsButton, lightOnButton] {
            button?.layer.cornerRadius = 10.0
            button?.layer.borderWidth = 5
            button?.layer.borderColor = UIColor.flatWhite.cgColor
        }
        
        chartButton.backgroundColor = UIColor.flatWhite
        chartButton.setTitleColor(UIColor.flatBlack, for: .normal)
        
        defaults.set(false, forKey: "Light")
        lightOnButton.backgroundColor = UIColor.flatBlack
        lightOnButton.setTitleColor(UIColor.flatWhite, for: .normal)
        lightOnButton.setTitle("Light Off", for: .normal)        
    }

}

class VideoCell: SwipeTableViewCell {
    @IBOutlet weak var videoLabel: UILabel!
    
    override func awakeFromNib() {
        // setupIndicatorView()
    }
}
