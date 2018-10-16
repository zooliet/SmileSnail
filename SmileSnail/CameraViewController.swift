//
//  CameraViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, VLCMediaPlayerDelegate {
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightOnButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var thumbnailsView: UICollectionView!
    @IBOutlet weak var lightLevelSlider: UISlider!
    @IBOutlet weak var snapshotButton: UIButton!

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceInfo), name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
        mediaPlayer?.stop()
        mediaPlayer = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

        cameraButton.layer.backgroundColor = UIColor.white.cgColor
        cameraButton.setTitleColor(UIColor.black, for: .normal)

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

    func configVideoViewStyle() {
        // videoView.backgroundColor = UIColor.black
        // videoView.layer.cornerRadius = 30
    }

    func configLightLevelSlider() {
        lightLevelSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        let lightLevel = settings.lightLevel
        lightLevelSlider.setValue(Float(lightLevel!), animated: true)
    }

    @objc func updateDeviceInfo() {
        // print("Received notification")
        let settings = Settings.shared
        if settings.snapshotReq! {
            // print("Snapshot Requested")
            makeSnapshot()
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

    func setupMediaPlayer() {
        mediaPlayer = VLCMediaPlayer()
        let url = URL(string: settings.mediaUrl!)
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

        // performSelector(inBackground: #selector(makeSnapshot), with: nil)
        makeSnapshot()
//
//        if let player = mediaPlayer?.drawable as? UIView? {
//            let size = player?.frame.size
//            // print(size!)
//
//            UIGraphicsBeginImageContext(size!)
//            // UIGraphicsBeginImageContextWithOptions(size!, false, UIScreen.main.scale)
//            let rec = player?.frame
//            player?.drawHierarchy(in: rec!, afterScreenUpdates: false)
//            let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            // print(snapshotImage!)
//
//            settings.patientName = "Anna Kim"
//            let patientName = settings.patientName
//            let imageName = "\(patientName)_\(Date()).jpg"
//            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
//
//            if let jpegData = snapshotImage?.jpegData(compressionQuality: 80) {
//                try? jpegData.write(to: imagePath)
//            }
//
//            thumbnails.insert(imagePath.path, at: 0)
//            let indexPath = IndexPath(item: 0, section: 0)
//            thumbnailsView.insertItems(at: [indexPath])
//        }
    }

    @objc func makeSnapshot() {
      if mediaPlayer == nil { return }

      if let player = mediaPlayer?.drawable as? UIView? {
          let size = player?.frame.size
          // let size = CGSize(width: 614.5, height: 461.0)
          print(size!)

          UIGraphicsBeginImageContext(size!)
          // UIGraphicsBeginImageContextWithOptions(size!, false, UIScreen.main.scale)
          var rec = player?.frame
          print(rec!.origin.x, rec!.origin.y)
          let x = -rec!.origin.x
          let y = -rec!.origin.y
          let width = rec!.width + rec!.origin.x
          let height = rec!.height + rec!.origin.y

          rec = CGRect(x: x, y: y, width: width, height: height)
          player?.drawHierarchy(in: rec!, afterScreenUpdates: false)
          let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();
          // print(snapshotImage!)

          let patientName = settings.patientName!
          let date = Date()
          // let dateFormatter = DateFormatter()
          // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          // let date = dateFormatter.string(from: Date())
          let imageName = "\(patientName)_\(date).jpg"
          let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

          if let jpegData = snapshotImage?.jpegData(compressionQuality: 100) {
              try? jpegData.write(to: imagePath)
          }

          thumbnails.insert(imagePath.path, at: 0)
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
