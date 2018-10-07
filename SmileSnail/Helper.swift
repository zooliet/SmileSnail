//
//  Helper.swift
//  SmileSnail
//
//  Created by hl1sqi on 05/10/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import Foundation
import UIKit
import SwiftSocket
import Alamofire
import SwiftyJSON

func turnLight(on: Bool) {
    let settings = Settings.shared
    let defaults = UserDefaults.standard

    guard let udpClient = settings.udpClient else { return }

    if on {
        let level = settings.lightLevel
        let firstByte: UInt8 = UInt8(Int(level / 10) + 48)
        let secondByte: UInt8 = UInt8(Int(level % 10) + 48)
        let _ = udpClient.send(data: [0x01, 0x55, firstByte, secondByte, 0x30, 0x30, 0x30, 0x30])
//        switch r {
//        case .success:
//            let data = udpClient.recv(1024)
//            print(data)
//        case .failure:
//            print("Error")
//        }

        settings.light = true
        settings.lightLevel = level
        defaults.set(true, forKey: "Light")
        defaults.set(level, forKey: "LightLevel")

    } else {  // off
        let _ = udpClient.send(data: [0x01, 0x55, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30])
        settings.light = false
        defaults.set(false, forKey: "Light")
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}


func checkDeviceStatus() {
    let settings = Settings.shared
    let defaults = UserDefaults.standard

    guard let udpClient = settings.udpClient else { return }
    let lightLevel = settings.lightLevel
    let light = settings.light
    var data: [UInt8] = [UInt8]()
    if (light && lightLevel > 0) {
        let firstByte: UInt8 = UInt8(Int(lightLevel / 10) + 48)
        let secondByte: UInt8 = UInt8(Int(lightLevel % 10) + 48)
        data = [0x01, 0x55, firstByte, secondByte, 0x30, 0x30, 0x30, 0x30]
    } else {
        data = [0x01, 0x55, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30]
    }

    switch udpClient.send(data: data) {
    case .success:
        let result = udpClient.recv(1024)
            print(result)
    case .failure:
        print("Error")
    }


}

func getDeviceID() -> String {
    let urlString = "http://admin:admin@192.168.100.1/param.cgi?action=list&group=wifi"
    if let url = URL(string: urlString) {
        if let data = try? String(contentsOf: url) {
            let json = JSON(parseJSON: data)
            return String(json["device_name"].stringValue.split(separator: "_")[1])
        } else {
            return "Not connected"
        }
    }
    return "Not connected"


    // var deviceID: String?
    // Alamofire.request("http://admin:admin@192.168.100.1/param.cgi?action=list&group=wifi").responseJSON { (response) in
    //     if response.result.isSuccess {
    //         //print(JSON(response.result.value!)["device_name"].stringValue.split(separator: "_")[1])
    //         deviceID = String(JSON(response.result.value!)["device_name"].stringValue)
    //         print(deviceID!.split(separator: "_")[1])
    //         Settings.shared.deviceID = String(deviceID!.split(separator: "_")[1])
    //     } else {
    //         // print(response.result.error)
    //         Settings.shared.deviceID = "Not Connected"
    //     }
    // }
}


func getBatteryStatus() -> Int {
    let settings = Settings.shared
    let defaults = UserDefaults.standard

    guard let udpClient = settings.udpClient else { return 0 }
    let lightLevel = settings.lightLevel
    let light = settings.light
    var data: [UInt8] = [UInt8]()
    if (light && lightLevel > 0) {
        let firstByte: UInt8 = UInt8(Int(lightLevel / 10) + 48)
        let secondByte: UInt8 = UInt8(Int(lightLevel % 10) + 48)
        data = [0x01, 0x55, firstByte, secondByte, 0x30, 0x30, 0x30, 0x30]
    } else {
        data = [0x01, 0x55, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30]
    }

    switch udpClient.send(data: data) {
    case .success:
        let result = udpClient.recv(1024)
            print(result)
    case .failure:
        print("Error")
    }

    return 90
}


//        statusTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
//            print("Check status")
//        }

// statusTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: true)
// statusTimer?.invalidate()
// statusTimer = nil
