//
//  AppDelegate.swift
//  SmileSnail
//
//  Created by hl1sqi on 25/09/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

let KEEP_ALIVE_COUNT: Int = 3
let POLLING_SEC: Double = 3.0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCDAsyncUdpSocketDelegate {

    var window: UIWindow?
    var statusTimer: Timer?

    var keepAlive: Int = KEEP_ALIVE_COUNT

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializeApplication()
        return true
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
        closeApplication()
    }

    func initializeApplication() {
        let defaults = UserDefaults.standard
        let settings = Settings.shared

        settings.light = false // On startup, turn off the light
        if defaults.object(forKey: "LightLevel") == nil {
            settings.lightLevel = 20
        } else {
            settings.lightLevel = defaults.object(forKey: "LightLevel") as? Int
        }

        getDeviceInfo() { (deviceId, ssid, error)  in
            if error != nil {
                settings.deviceID = ""
                settings.ssid = ""
            } else {
                settings.deviceID = deviceId!
                settings.ssid = ssid!
            }
        }
        // settings.ssid = "" // defaults.string(forKey: "SSID") ?? "entlab"
        // settings.deviceID = ""

        settings.mediaUrl = defaults.string(forKey: "MediaURL") ?? "rtsp://admin:admin@192.168.100.1/cam1/h264"
        settings.mediaUrl = "rtsp://admin:admin@192.168.100.1/cam1/h264"
        // settings.mediaUrl = "rtsp://184.72.239.149/vod/mp4:BigBuckBunny_175k.mov"
        settings.patientName = defaults.string(forKey: "PatientName") ?? "NONAME"


        settings.batteryLevel = 99
        settings.snapshotReq = false
        // settings.socket =  GCDAsyncUdpSocket.init(delegate: self, delegateQueue: DispatchQueue.global(qos: .userInitiated), socketQueue: DispatchQueue.main)
        settings.socket =  GCDAsyncUdpSocket.init(delegate: self, delegateQueue: DispatchQueue.main, socketQueue: DispatchQueue.main)

        makeSocketConnection()
        startTimer()
    }

    func closeApplication() {
        // let defaults = UserDefaults.standard
        let settings = Settings.shared

        // defaults.set(settings.lightLevel!, forKey: "LightLevel")
        // defaults.set(settings.ssid!, forKey: "SSID")
        // defaults.set(settings.mediaUrl!, forKey: "MediaURL")
        // defaults.set(settings.patientName!, forKey: "PatientName")

        settings.socket?.close()
        stopTimer()
    }

    func makeSocketConnection() {
        let socket = Settings.shared.socket

        do {
            // try socket?.connect(toHost: "192.168.0.26", onPort: 1008)
            try socket?.connect(toHost: "192.168.100.1", onPort: 1008)
            try socket?.beginReceiving()
        } catch {
            print("Error: Socket connection")
        }
    }

    func startTimer() {
        statusTimer = Timer.scheduledTimer(timeInterval: POLLING_SEC, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        statusTimer?.invalidate()
        statusTimer = nil
    }

    @objc func runTimedCode() {
        // print("Timer: \(Date())")
        let settings = Settings.shared

        if keepAlive == 0 {
            keepAlive = KEEP_ALIVE_COUNT  // 3번 연속 수신을 못하면 장치 연결 문제라고 판단
            settings.socket?.close()
            settings.deviceID = ""
            sendNotification()
        } else {
            keepAlive = keepAlive - 1
            makeStatusPolling()
        }
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        // print("Connected")
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
       // print("didSendDataWithTag")
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
       // print("didNotSendDataWithTag")
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        // print("Socket closed")
        // let settings = Settings.shared
        // settings.deviceID = ""
        // sendNotification()

        makeSocketConnection()
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        keepAlive = KEEP_ALIVE_COUNT
        var port: UInt16 = 0
        var host: NSString? = nil

        GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress: address)
        // let str = String(decoding: data, as: UTF8.self) as NSString
        // print("Received: \(str) from \(host!):\(port)")
        let settings = Settings.shared

        let batteryLevel = (data[4] - 48) * 10 + (data[5] - 48)
        // print(data[4], data[5], batteryLevel)
        settings.batteryLevel = Int(batteryLevel+1)
        settings.snapshotReq = (data[6] == 49) && (data[7] == 49)

        if settings.deviceID == "" {
            // settings.deviceID = getDeviceID()
            getDeviceInfo() { (deviceId, ssid, error)  in
                if error != nil {
                    settings.deviceID = ""
                    settings.ssid = ""
                } else {
                    settings.deviceID = deviceId!
                    settings.ssid = ssid!
                }
            }
        }

        sendNotification()
    }

    func sendNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "statusPollingNotification"), object: nil)
    }

    func makeStatusPolling() {
        let socket = Settings.shared.socket
        // let data = "any string".data(using: .utf8)!

        let settings = Settings.shared
        let lightLevel = settings.lightLevel!
        let light = settings.light!
        var data = Data(hexString: "0155303030303030")!
        //var data = Data(hexString: "303030303030")!

        if (light && lightLevel > 0) {
            let firstByte: UInt8 = UInt8(Int(lightLevel / 10) + 30)
            let secondByte: UInt8 = UInt8(Int(lightLevel % 10) + 30)
            data = Data(hexString: "0155\(firstByte)\(secondByte)30303030")!
            //data = Data(hexString: "\(firstByte)\(secondByte)30303030")!
        }
        socket?.send(data, withTimeout: -1, tag: 0)
    }
}
