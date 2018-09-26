//
//  CameraViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import ChameleonFramework
//import VerticalSlider
import SwiftSocket


class CameraViewController: UIViewController, VLCMediaPlayerDelegate {
    
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var lightLevelSlider: UISlider!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    let defaults = UserDefaults.standard
    var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
//    let url = URL(string: "rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov")
     let url = URL(string: "rtsp://admin:admin@192.168.100.1/cam1/h264")
    var recordingStatus: Bool = false
    var udpClient: UDPClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configButtonsStyle()
        configVideoViewStyle()

        configLightLevelSlider()
        
        let media = VLCMedia(url: url!)
        media.addOptions([
            // "sout-rtp-proto": "tcp",
            // "sout-rtp-caching": 200,
            // "sout-udp-caching": 0,
            // "clock-jitter": 500,
            "network-caching": 200,
            // "unicast": true,
            // "clock-synchro": 0"
            ])
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = videoView
        
        // Do any additional setup after loading the view.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        videoView.addGestureRecognizer(recognizer)
        
        udpClient = UDPClient(address: "192.168.100.1", port: 1008)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        mediaPlayer.stop()
        // stop recording

        udpClient?.close()
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
            button?.layer.borderColor = UIColor.flatWhite.cgColor
        }
        
        cameraButton.backgroundColor = UIColor.flatWhite
        cameraButton.setTitleColor(UIColor.flatBlack, for: .normal)
        
        if defaults.bool(forKey: "Light") {
            lightOnButton.backgroundColor = UIColor.flatWhite
            lightOnButton.setTitleColor(UIColor.flatBlack, for: .normal)
            lightOnButton.setTitle("Light On", for: .normal)
        } else {
            lightOnButton.backgroundColor = UIColor.flatBlack
            lightOnButton.setTitleColor(UIColor.flatWhite, for: .normal)
            lightOnButton.setTitle("Light Off", for: .normal)

        }
    }
    
    func configVideoViewStyle() {
        // videoView.backgroundColor = UIColor.flatBlack
        videoView.backgroundColor = UIColor.flatBlackDark
        videoView.layer.cornerRadius = 320
    }
    
    func configLightLevelSlider() {
        lightLevelSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        let lightLevel = defaults.integer(forKey: "LightLevel")
        lightLevelSlider.setValue(Float(lightLevel), animated: true)
    }

    @IBAction func toggleLightPressed(_ sender: Any) {
        if lightOnButton.currentTitle! == "Light On" {
            // On to Off
            lightOnButton.setTitle("Light Off", for: .normal)
            defaults.set(false, forKey: "Light")
        } else {
            lightOnButton.setTitle("Light On", for: .normal)
            // Off to On
            defaults.set(true, forKey: "Light")
        }
        turnOnOffLight()
        
        configButtonsStyle()
    }
    
    @IBAction func setLightLevel(_ sender: UISlider) {
        let lightLevel = Int(sender.value)
        defaults.set(lightLevel, forKey: "LightLevel")
        turnOnOffLight()
    }
    
    @IBAction func toggleRecordingPressed(_ sender: UIButton) {
        recordingStatus = !recordingStatus
        if recordingStatus {
            recordingButton.setImage(UIImage(named: "recording"), for: .normal)
        } else {
            recordingButton.setImage(UIImage(named: "record"), for: .normal)
        }
        // mediaPlayer.saveVideoSnapshot(at: ".", withWidth: 320, andHeight: 240)
        // print(mediaPlayer.snapshots)
        
        
//        let player = mediaPlayer.drawable as! UIView
        //        let size = player.frame.size
//        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
//        let rec = player.frame
//        player.drawHierarchy(in: rec, afterScreenUpdates: false)
//
//        let image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        print(image!)
//        debugImage.image = image
        
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        playVideo()
    }
    @objc func didTap() {
        playVideo()
    }
    
    func playVideo() {
        if mediaPlayer.isPlaying {
            mediaPlayer.pause()
            playButton.isHidden = false
            // mediaPlayer.stop()
            // let remaining = mediaPlayer.remainingTime
            // let time = mediaPlayer.time
            // print("Paused at \(time?.stringValue ?? "nil") with \(remaining?.stringValue ?? "nil") time remaining")
        } else {
            playButton.isHidden = true
            mediaPlayer.play()
        }
    }
    
    func turnOnOffLight() {
        guard let udpClient = udpClient else { return }
        // print("Connected to host \(udpClient.address):\(udpClient.port)")
        if defaults.bool(forKey: "Light") {
            let lightLevel = defaults.integer(forKey: "LightLevel")
            let firstByte: Byte = Byte(Int(lightLevel / 10) + 48)
            let secondByte: Byte = Byte(Int(lightLevel % 10) + 48)
            let _ = udpClient.send(data: [0x01, 0x55, firstByte, secondByte, 0x30, 0x30, 0x30, 0x30])
        } else {
            let _ = udpClient.send(data: [0x01, 0x55, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30])
        }
    }
}
