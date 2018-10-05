//
//  Settings.swift
//  SmileSnail
//
//  Created by hl1sqi on 05/10/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import Foundation
import UIKit
import SwiftSocket

class Settings {
    static let shared = Settings()
    var ssid: String = "entlab"
    var mediaUrl: String = "rtsp://192.168.100.1"
    var light: Bool = false
    var lightLevel = 50
    var deviceID: String = "Not Connected"
    var batteryStatus: Int = 100
    var patientName: String = "NONAME"
    
    var udpClient: UDPClient?
    // var udpClient: UDPClient = UDPClient(address: "192.168.100.1", port: 1008)
    // print("Connected to host \(udpClient.address):\(udpClient.port)")
    
    
    private init() {}
}
