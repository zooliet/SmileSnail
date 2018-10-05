//
//  AppDelegate.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import SwiftSocket

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initSettings()
        return true
    }
    
    
    func initSettings() {
        let defaults = UserDefaults.standard
        let settings = Settings.shared
        
        // Light
        defaults.set(false, forKey: "Light")
        settings.light = false
        
        // Light Level
        if defaults.object(forKey: "LightLevel") == nil {
            defaults.set(50, forKey: "LightLevel")
        }
        settings.lightLevel = defaults.integer(forKey: "LightLevel")
        
        // SSID
        if defaults.object(forKey: "SSID") == nil {
            defaults.set("entlab", forKey: "SSID")
        }
        settings.ssid = defaults.string(forKey: "SSID")!

        // MediaURL
        if defaults.object(forKey: "MediaURL") == nil {
            // defaults.set("rtsp://admin:admin@192.168.100.1/cam1/h264", forKey: "MediaURL")
            defaults.set("rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov", forKey: "MediaURL")
        }
        settings.mediaUrl = defaults.string(forKey: "MediaURL")!
        
        // Device ID
        settings.deviceID = "1234"
        
        // Battery
        settings.batteryStatus = 100 // getBatteryStatus()
        
        // Patient Name
        if defaults.object(forKey: "PatientName") == nil {
            defaults.set("NONAME", forKey: "PatientName")
        }
        settings.patientName = defaults.string(forKey: "PatientName")!
        settings.udpClient = UDPClient(address: "192.168.100.1", port: 1008)
        // print("Connected to host \(udpClient.address):\(udpClient.port)")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Settings.shared.udpClient?.close()
    }


}

