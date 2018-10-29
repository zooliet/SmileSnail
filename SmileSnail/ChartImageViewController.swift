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
    var fileURLs: [URL] = [URL]()
    let pageControl = UIPageControl()
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // slideShow.slideshowInterval = 5.0
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideShow.contentScaleMode = UIView.ContentMode.scaleAspectFill


        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideShow.pageIndicator = pageControl

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideShow.activityIndicator = DefaultActivityIndicator()

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideShow.setImageInputs(localSource)

        // slideShow.currentPageChanged = { page in
        //     print("current page:", page)
        //     print("\(self.fileURLs[page])")
        // }
        // slideShow.setCurrentPage(1, animated: true)


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
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    func loadImages() {
        let fm = FileManager.default
        let path = getDocumentsDirectory().path
        var fileList: [String] = [String]()

        do {
            fileList = try fm.contentsOfDirectory(atPath: path).sorted(by: >).filter { fileName in
                return fileName.hasPrefix(selected!)
            }
        } catch {
            print("Error in File Listing")
        }

        fileURLs = fileList.map { fileName in getDocumentsDirectory().appendingPathComponent(fileName) }

        localSource = fileURLs.map { (fileURL) -> ImageSource in
            let imageData = try! Data(contentsOf: fileURL)
            let image = UIImage(data: imageData)!
            return ImageSource(image: image)
        }
    }

    @objc func didTap() {

        let fullScreenController = slideShow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        //print(self.slideShow.currentPage)
        //print(self.fileURLs[self.slideShow.currentPage])
        let currentPage = self.slideShow.currentPage
        let fm = FileManager.default
        do {
            try fm.removeItem(at: self.fileURLs[currentPage])
            localSource.remove(at: currentPage)
            fileURLs.remove(at: currentPage)
        } catch {
            print("Error in deleting a file")
        }

        //pageControl.updateCurrentPageDisplay()
        
        slideShow.setImageInputs(localSource)
        if localSource.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        else if currentPage >=  localSource.count {
            slideShow.setCurrentPage(localSource.count-1, animated: true)
        } else {
            slideShow.setCurrentPage(currentPage, animated: true)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
    }
}
