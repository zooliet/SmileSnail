////
////  BoardSocket.swift
////  SmileSnail
////
////  Created by hl1sqi on 07/10/2018.
////  Copyright © 2018 entlab. All rights reserved.
////
//
// import Foundation
// import CocoaAsyncSocket
//
//// class BoardSocket: NSObject, GCDAsyncUdpSocketDelegate {
////     var udpSocket: GCDAsyncUdpSocket?
////
////     override init() {
////         super.init()
////        print(self)
////        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
////         //udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main, socketQueue: DispatchQueue.main)
////     }
////
////     func send(_ data: [UInt8]) {
////        let data1:NSData = NSData(bytes: data, length: data.count);
////         udpSocket?.send(data1 as Data, toHost: "192.168.100.1", port: 1008, withTimeout: 100, tag: 0)
////     }
////
////     func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
////         print(tag)
////     }
////
////     func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
////         print("HEllO")
////     }
//// }
//
//class UdpSocketSR: GCDAsyncSocket, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate {
//    var socket: GCDAsyncUdpSocket!
//    var otherSocket: GCDAsyncSocket!
//
//    func SetupAndSend() {
//        let host = "192.168.100.1" // IP
//        let port: UInt16 = 1008   // Port
//        // let message = messageOut.data(using: String.Encoding.utf8)!
//
//        //let bytes = [0x01, 0x55, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35]
//        // let bytes = "0155303132333435"
//        // let data:NSData = NSData(bytes: bytes, length: bytes.count);
//        let data = dataWithHexString(hex: "0155313233343536")
//
//        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
//        otherSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
//
//        do {
//            try otherSocket.accept(onPort: 61443)
//
//            // try socket.bind(toPort: 61443)
//            try socket.enableBroadcast(true)
//            try socket.beginReceiving()
//            socket.send(data, toHost: host, port: port, withTimeout: 2, tag: 0)
//            print(data)
//        } catch {
//            print("error")
//        }
//    }
//
//    // Delegate
//
//    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
//        var host: NSString?
//        var port: UInt16 = 0
//        GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress: address)
//        print(host!)
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//        print("read data")
//    }
//
//    func dataWithHexString(hex: String) -> Data {
//        var hex = hex
//        var data = Data()
//        while(hex.count > 0) {
//            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
//            let c = String(hex[..<subIndex])
//            hex = String(hex[subIndex...])
//            var ch: UInt32 = 0
//            Scanner(string: c).scanHexInt32(&ch)
//            var char = UInt8(ch)
//            data.append(&char, count: 1)
//        }
//        return data
//    }
//}
