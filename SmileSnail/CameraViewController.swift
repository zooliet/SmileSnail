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
        // print("CameraVC: viewDidLoad()")

        thumbnailsView.dataSource = self
        thumbnailsView.delegate = self

        configButtons(settings.light!)
        configLightLevelSlider()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        videoView.addGestureRecognizer(recognizer)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // print("CameraVC: viewWillAppear()")
        // videoView.transform = CGAffineTransform(rotationAngle: .pi)
        setupMediaPlayer()

        updateDeviceInfo()

        thumbnails = []
        thumbnailsView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceInfo), name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // print("CameraVC: viewWillDisappear()")

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
        mediaPlayer?.stop()
        mediaPlayer = nil
    }

    deinit {
        // print("CameraVC: deinit()")
        // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "statusPollingNotification"), object: self)
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

    @IBAction func menuTapped(_ sender: UIButton) {
        // print(sender.currentTitle!)
        navigateCtrl(sender: sender, navigationController: self.navigationController)
    }

    @IBAction func setLightLevel(_ sender: UISlider) {
        let lightLevel = Int(sender.value)
        settings.lightLevel = lightLevel
        if lightLevel == 0 {
            turnLight(on: false)
        } else {
            turnLight(on: true)
        }
        configButtons(settings.light!)
    }

    @IBAction func toggleLightPressed(_ sender: Any) {
        toggleLight(lightOnButton)
        configButtons(settings.light!)
    }

    @IBAction func snapshotPressed(_ sender: Any) {
        // mediaPlayer?.saveVideoSnapshot(at: ".", withWidth: 320, andHeight: 240)
        // print(mediaPlayer?.snapshots)

        // performSelector(inBackground: #selector(makeSnapshot), with: nil)
        makeSnapshot()
    }

    func configLightLevelSlider() {
        lightLevelSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        let lightLevel = settings.lightLevel
        lightLevelSlider.setValue(Float(lightLevel!), animated: true)
    }

    @objc func updateDeviceInfo() {
        // print("Received notification")

        if settings.snapshotReq! {
            // print("Snapshot Requested")
            makeSnapshot()
            settings.snapshotReq = false
        }

        updateStatusLabel(deviceLabel: self.deviceLabel, batteryLabel: self.batteryLabel)
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
        videoView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        mediaPlayer?.drawable = videoView
        mediaPlayer?.play()
    }

    @objc func makeSnapshot() {
      if mediaPlayer == nil { return }

      if let player = mediaPlayer?.drawable as? UIView? {
          // player?.transform = CGAffineTransform(rotationAngle: .pi)
          let size = player?.frame.size
          // let size = CGSize(width: 614.5, height: 461.0)
          // print(size!)

          // player?.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
          UIGraphicsBeginImageContext(size!)
          // UIGraphicsBeginImageContextWithOptions(size!, false, UIScreen.main.scale)
          var rec = player?.frame

          // print(rec!.origin.x, rec!.origin.y)
          let x = CGFloat(0.0) // -rec!.origin.x
          let y = CGFloat(0.0) // -rec!.origin.y
          let width = rec!.width + rec!.origin.x
          let height = rec!.height + rec!.origin.y

          rec = CGRect(x: x, y: y, width: width, height: height)

          player?.drawHierarchy(in: rec!, afterScreenUpdates: false)
          // player?.transform = CGAffineTransform(rotationAngle: .pi)
          let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();

          UIGraphicsEndImageContext();
          // print(snapshotImage!)
        
          let rotatedImage = snapshotImage?.rotate(radians: .pi)

          let patientName = settings.patientName!
          let date = Date()
          // let dateFormatter = DateFormatter()
          // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          // let date = dateFormatter.string(from: Date())
          let imageName = "\(patientName)_\(date).jpg"
          let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
          // print(imagePath)

          if let jpegData = rotatedImage?.jpegData(compressionQuality: 100) {
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
        videoView.transform = CGAffineTransform(rotationAngle: 0)
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


extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
