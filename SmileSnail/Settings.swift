//
//  Settings.swift
//  SmileSnail
//
//  Created by hl1sqi on 05/10/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import Foundation
//import UIKit
import CocoaAsyncSocket

class Settings {
    static let shared = Settings()
    var ssid: String?
    var mediaUrl: String?
    var light: Bool?
    var lightLevel: Int?
    var deviceID: String?
    var batteryLevel: Int?
    var patientName: String?
    var socket: GCDAsyncUdpSocket?
    var snapshotReq: Bool?

    private init() {}
}
