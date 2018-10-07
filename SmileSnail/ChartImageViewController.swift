//
//  ChartImageViewController.swift
//  SmileSnail
//
//  Created by hl1sqi on 26/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import ImageSlideshow

class ChartImageViewController: UIViewController {

    @IBOutlet weak var slideShow: ImageSlideshow!

    var selected : String? {
        didSet{
            loadImages()
        }
    }

    // let localSource = [ImageSource(imageString: "img1")!, ImageSource(imageString: "img2")!, ImageSource(imageString: "img3")!, ImageSource(imageString: "img4")!]
    var localSource: [ImageSource] = [ImageSource]()

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // slideShow.slideshowInterval = 5.0
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideShow.contentScaleMode = UIView.ContentMode.scaleAspectFill

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideShow.pageIndicator = pageControl

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.currentPageChanged = { page in
            print("current page:", page)
        }

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideShow.setImageInputs(localSource)

        // Do any additional setup after loading the view.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideShow.addGestureRecognizer(recognizer)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func loadImages() {
        let fm = FileManager.default
        let path = getDocumentsDirectory().path
        let fileList = try! fm.contentsOfDirectory(atPath: path)

        for fileName in fileList {
            if fileName.hasPrefix(selected!) {
                // print(fileName)
                let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
                let imageData = try! Data(contentsOf: fileURL)
                let image = UIImage(data: imageData)!
                localSource.append(ImageSource(image: image))
            }
        }
        localSource = localSource.reversed()
        
    }

    @objc func didTap() {
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}
