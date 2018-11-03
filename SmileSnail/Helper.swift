//
//  Helper.swift
//  SmileSnail
//
//  Created by hl1sqi on 05/10/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

func turnLight(on: Bool) {
    let settings = Settings.shared
    let socket = Settings.shared.socket

    let lightLevel = settings.lightLevel!
    // let light = settings.light!
    var data = Data(hexString: "0155303030303030")!

    if (on && lightLevel > 0) {
        let firstByte: UInt8 = UInt8(Int(lightLevel / 10) + 30)
        let secondByte: UInt8 = UInt8(Int(lightLevel % 10) + 30)
        data = Data(hexString: "0155\(firstByte)\(secondByte)30303030")!
    }

    socket?.send(data, withTimeout: -1, tag: 0)
    settings.light = on
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func getDeviceID() -> String{
    let urlString = "http://admin:admin@192.168.100.1/param.cgi?action=list&group=wifi"
    if let url = URL(string: urlString) {
        if let data = try? String(contentsOf: url) {
            let json = JSON(parseJSON: data)
            return String(json["device_name"].stringValue.split(separator: "_")[1])
        } else {
            return ""
        }
    }
    return ""
}


func getDeviceInfo(completion: @escaping (String?, String?, String?) -> Void) {
    var request = URLRequest(url: (NSURL.init(string: "http://192.168.100.1/param.cgi?action=list&group=wifi")?.absoluteURL)!)
    request.httpMethod = "GET"
    // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 3 // 10 secs
    Alamofire.request(request)
        .authenticate(user: "admin", password: "admin")
        .responseJSON { response in
            if response.result.isSuccess {
                // print(JSON(response.result.value!))
                let ap_ssid: String = String(JSON(response.result.value!)["ap_ssid"].stringValue)
                let ssid: String = String(ap_ssid.split(separator:"_")[0])
                let deviceId: String = String(ap_ssid.split(separator:"_")[1])
                completion(deviceId, ssid, nil)
            } else {
                // print("Error \(String(describing: response.result.error))")
                completion(nil, nil, "Error")
            }
        }
}

func setDeviceSsid(ssid: String, completion: @escaping (String) -> Void) {
    var request = URLRequest(url: (NSURL.init(string: "http://192.168.100.1/param.cgi?action=update&group=wifi&ap_ssid=\(ssid)")?.absoluteURL)!)
    request.httpMethod = "GET"
    // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 10 // 10 secs
    Alamofire.request(request)
        .authenticate(user: "admin", password: "admin")
        .responseJSON { response in
            if response.result.isSuccess {
                // print(JSON(response.result.value!))
                let result: String = String(JSON(response.result.value!)["value"].stringValue)
                if result == "0" {
                    completion("Success")
                } else {
                    completion("Error")
                }
            } else {
                // print("Error \(String(describing: response.result.error))")
                completion("Error")
            }
        }
}


func getDeviceSsid(completion: @escaping (String) -> Void) {

    // 방식 1: 999 Error
    // let url = "http://192.168.100.1/param.cgi"
    // let parameters = ["action": "list", "group": "wifi"]
    // let headers: HTTPHeaders = [
    //   "Accept": "application/json"
    // ]

    // let configuration = URLSessionConfiguration.default
    // configuration.timeoutIntervalForRequest = 3
    // configuration.timeoutIntervalForResource = 3
    //
    // let sessionManager = Alamofire.SessionManager(configuration: configuration)
    // sessionManager.request(url, method: .get, parameters: parameters)
    //     // .authenticate(user: "admin", password: "admin")
    //     .responseJSON { response in
    //         if response.result.isSuccess {
    //             print(JSON(response.result.value!))
    //         } else {
    //             print("Error \(String(describing: response.result.error))")
    //         }
    //     }

    // 방식 2: timeout setting 불가
    // let url = "http://192.168.100.1/param.cgi"
    // let parameters = ["action": "list", "group": "wifi"]
    // Alamofire.request(url, method: .get, parameters: parameters)
    //     .authenticate(user: "admin", password: "admin")
    //     .responseJSON { response in
    //         if response.result.isSuccess {
    //             print(JSON(response.result.value!))
    //         } else {
    //             print("Error \(String(describing: response.result.error))")
    //         }
    //     }

    var request = URLRequest(url: (NSURL.init(string: "http://192.168.100.1/param.cgi?action=list&group=wifi")?.absoluteURL)!)
    request.httpMethod = "GET"
    // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 3 // 10 secs
    Alamofire.request(request)
        .authenticate(user: "admin", password: "admin")
        .responseJSON { response in
            if response.result.isSuccess {
                // print(JSON(response.result.value!))
                let ssid: String = String(String(JSON(response.result.value!)["ap_ssid"].stringValue).split(separator:"_")[0])
                completion(ssid)
            } else {
                // print("Error \(String(describing: response.result.error))")
                completion("")
            }
        }
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}

extension UIViewController {
  func configButtons(_ on: Bool) {
    // print(type(of: self))

    var buttons = [UIButton]()

    if self is CameraViewController {
        let ctrl = (self as? CameraViewController)!
        buttons = [ctrl.cameraButton, ctrl.chartButton, ctrl.settingsButton, ctrl.lightOnButton]
        makeButtonsDefault(buttons)
        makeCurrentButton(ctrl.cameraButton)
        makeLightOnButton(on, ctrl.lightOnButton)
    } else if self is ChartViewController {
        let ctrl = (self as? ChartViewController)!
        buttons = [ctrl.cameraButton, ctrl.chartButton, ctrl.settingsButton, ctrl.lightOnButton]
        makeButtonsDefault(buttons)
        makeCurrentButton(ctrl.chartButton)
        makeLightOnButton(on, ctrl.lightOnButton)
    } else if self is SettingsViewController {
        let ctrl = (self as? SettingsViewController)!
        buttons = [ctrl.cameraButton, ctrl.chartButton, ctrl.settingsButton, ctrl.lightOnButton]
        makeButtonsDefault(buttons)
        makeCurrentButton(ctrl.settingsButton)
        makeLightOnButton(on, ctrl.lightOnButton)
    }
  }

  func makeButtonsDefault(_ buttons: [UIButton]) {
      for button in buttons {
          button.layer.cornerRadius = 10.0
          button.layer.borderWidth = 5
          button.layer.borderColor = UIColor.white.cgColor
          button.layer.backgroundColor = UIColor.black.cgColor
          button.setTitleColor(UIColor.white, for: .normal)
      }
  }

  func makeCurrentButton(_ button: UIButton) {
      button.layer.backgroundColor = UIColor.white.cgColor
      button.setTitleColor(UIColor.black, for: .normal)
  }

  func makeLightOnButton(_ on: Bool, _ button: UIButton) {
      if on {
        button.layer.backgroundColor = UIColor.white.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Light Off", for: .normal)
      } else {
        button.layer.backgroundColor = UIColor.black.cgColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Light On", for: .normal)
      }
  }

  func navigateCtrl(sender: UIButton, navigationController: UINavigationController?) {
      var destinationClassType: AnyClass?
      var destinationClassIdentifier: String?
      let currentTitle = sender.currentTitle

      if currentTitle == "Camera" {
          destinationClassType = CameraViewController.self
          destinationClassIdentifier = "CameraVC"
      } else if currentTitle == "Chart" {
          destinationClassType = ChartViewController.self
          destinationClassIdentifier = "ChartVC"
      } else if currentTitle == "Settings" {
          destinationClassType = SettingsViewController.self
          destinationClassIdentifier = "SettingsVC"
      }

      if let viewControllers = navigationController?.viewControllers {
          for viewController in viewControllers {
              if viewController.isKind(of: destinationClassType!) {
                  navigationController?.popToViewController(viewController, animated: true)
                  return
              }
          }
      }

      let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: destinationClassIdentifier!)
      navigationController?.pushViewController(destinationVC!, animated: true)
  }

  func toggleLight(_ button: UIButton) {
      if button.currentTitle! == "Light On" {
          button.setTitle("Light Off", for: .normal)
          turnLight(on: true)
      } else {
          button.setTitle("Light On", for: .normal)
          turnLight(on: false)
      }
  }
}
