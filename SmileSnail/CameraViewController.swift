//
//  CameraViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
// import ChameleonFramework
// import SwiftSocket


class CameraViewController: UIViewController, VLCMediaPlayerDelegate {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var thumbnailsView: UICollectionView!
    @IBOutlet weak var lightLevelSlider: UISlider!
    @IBOutlet weak var snapshotButton: UIButton!

    @IBOutlet weak var deviceLabel: UILabel!

    let defaults = UserDefaults.standard
    let settings = Settings.shared

    var mediaPlayer: VLCMediaPlayer?
    var thumbnails: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configButtonsStyle()
        configVideoViewStyle()
        configLightLevelSlider()
        updateDeviceInfo()

        setupMediaPlayer()

        thumbnailsView.dataSource = self
        thumbnailsView.delegate = self

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        videoView.addGestureRecognizer(recognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func viewWillDisappear(_ animated: Bool) {
        // mediaPlayer?.stop()
        // mediaPlayer = nil
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
        }

        cameraButton.backgroundColor = UIColor.white
        cameraButton.setTitleColor(UIColor.black, for: .normal)

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

    func configVideoViewStyle() {
        // videoView.backgroundColor = UIColor.black
        // videoView.layer.cornerRadius = 30
    }

    func configLightLevelSlider() {
        lightLevelSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        let lightLevel = settings.lightLevel
        lightLevelSlider.setValue(Float(lightLevel), animated: true)
    }

    func updateDeviceInfo() {
        // getDeviceInfo()
        deviceLabel.text = "Device: \(Settings.shared.deviceID)"
    }

    func setupMediaPlayer() {
        mediaPlayer = VLCMediaPlayer()
        let url = URL(string: settings.mediaUrl)
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
        mediaPlayer?.media = media
        mediaPlayer?.delegate = self
        mediaPlayer?.drawable = videoView
        mediaPlayer?.play()
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

    @IBAction func setLightLevel(_ sender: UISlider) {
        let lightLevel = Int(sender.value)
        settings.lightLevel = lightLevel
        if lightLevel == 0 {
            turnLight(on: false)
        } else {
            turnLight(on: true)
        }
        configButtonsStyle()
    }

    @IBAction func snapshotPressed(_ sender: Any) {
        // mediaPlayer?.saveVideoSnapshot(at: ".", withWidth: 320, andHeight: 240)
        // print(mediaPlayer?.snapshots)

        if let player = mediaPlayer?.drawable as? UIView? {
            let size = player?.frame.size
            // print(size!)

            UIGraphicsBeginImageContext(size!)
            // UIGraphicsBeginImageContextWithOptions(size!, false, UIScreen.main.scale)
            let rec = player?.frame
            player?.drawHierarchy(in: rec!, afterScreenUpdates: false)
            let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // print(snapshotImage!)

            thumbnails.insert("img\(Int(arc4random_uniform(4)+1))", at: 0)
            let indexPath = IndexPath(item: 0, section: 0)
            thumbnailsView.insertItems(at: [indexPath])
        }

    }



    @objc func didTap() {
        if mediaPlayer == nil {
            setupMediaPlayer()
        }
        // playVideo()
    }

    func playVideo() {
        if (mediaPlayer?.isPlaying)! {
            mediaPlayer?.pause()
            // playButton.isHidden = false
            // mediaPlayer.stop()
            // let remaining = mediaPlayer.remainingTime
            // let time = mediaPlayer.time
            // print("Paused at \(time?.stringValue ?? "nil") with \(remaining?.stringValue ?? "nil") time remaining")
        } else {
            // playButton.isHidden = true
            mediaPlayer?.play()
        }
    }

//    func turnOnOffLight() {
//        // guard let udpClient = udpClient else { return }
//        // print("Connected to host \(udpClient.address):\(udpClient.port)")
//        if defaults.bool(forKey: "Light") {
//            let lightLevel = defaults.integer(forKey: "LightLevel")
//            let firstByte: Byte = Byte(Int(lightLevel / 10) + 48)
//            let secondByte: Byte = Byte(Int(lightLevel % 10) + 48)
//            // let _ = udpClient.send(data: [0x01, 0x55, firstByte, secondByte, 0x30, 0x30, 0x30, 0x30])
//        } else {
//            // let _ = udpClient.send(data: [0x01, 0x55, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30])
//        }
//    }
}

extension CameraViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        cell.thumbnailImage.image = UIImage(named: thumbnails[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mediaPlayer = nil
        videoView.image = UIImage(named: thumbnails[indexPath.item])
        // collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension CameraViewController: UIScrollViewDelegate, UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.thumbnailsView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
