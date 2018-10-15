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

func getDeviceID2() {
    var deviceID: String?
    Alamofire.request("http://admin:admin@192.168.100.1/param.cgi?action=list&group=wifi").responseJSON { (response) in
        if response.result.isSuccess {
            //print(JSON(response.result.value!)["device_name"].stringValue.split(separator: "_")[1])
            deviceID = String(JSON(response.result.value!)["device_name"].stringValue)
            print(deviceID!.split(separator: "_")[1])
            Settings.shared.deviceID = String(deviceID!.split(separator: "_")[1])
        } else {
            // print(response.result.error)
            Settings.shared.deviceID = ""
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
