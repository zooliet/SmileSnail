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

func turnLight(on: Bool) {
    let settings = Settings.shared
    let defaults = UserDefaults.standard
    
    guard let udpClient = settings.udpClient else { return }
    
    if on {
        let level = settings.lightLevel
        let firstByte: UInt8 = UInt8(Int(level / 10) + 48)
        let secondByte: UInt8 = UInt8(Int(level % 10) + 48)
        let _ = udpClient.send(data: [0x01, 0x55, firstByte, secondByte, 0x30, 0x30, 0x30, 0x30])
        
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

