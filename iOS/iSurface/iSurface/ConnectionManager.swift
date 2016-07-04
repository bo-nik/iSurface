//
//  ConnectionManager.swift
//  iSurface
//
//  Created by iKing on 22.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

class ConnectionManager: GCDAsyncSocketDelegate {
    
    enum ConnectionStatus {
        case Connected
        case Disconnected
        case Connecting
    }
    
    private static var socket: GCDAsyncSocket! = nil
    
    private(set) static var connectionState = ConnectionStatus.Disconnected
    
    private static var callbacks: [String: (ConnectionStatus, message: String?) -> Void] = [:]
    
    static func connect() {
        if connectionState != .Disconnected {
            return
        }
        if socket == nil {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
        connectionState = .Connecting
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), {
                do {
                    try socket!.connectToHost(Settings.Network.ip, onPort: Settings.Network.port, withTimeout: 10.0)
                } catch {
                    callback(.Disconnected, message: "\(error)")
                    connectionState = .Disconnected
                }
            })
        callback(.Connecting)
    }
    
    static func disconnect() {
        socket.disconnect()
    }
    
    static func send(command: String, data: [String: AnyObject]) {
        guard socket != nil else {
            return
        }
        let commandData = [
            "command": command,
            "data": data
        ]
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(commandData, options: [])
            let jsonString = (NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String) + "\n"
            socket.writeData(jsonString.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
        } catch {
            print("Error in JSON conversion: \(error)")
        }
    }
    
    @objc private static func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        callback(.Connected)
        connectionState = .Connected
    }
    
    @objc private static func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        callback(.Disconnected, message: err?.localizedDescription)
        connectionState = .Disconnected
    }
    
    static func addCallback(callback: (ConnectionStatus, message: String?) -> Void, withTag tag: String) {
        callbacks[tag] = callback
    }
    
    static func removeCallbackWithTag(tag: String) {
        callbacks.removeValueForKey(tag)
    }
    
    private static func callback(status: ConnectionStatus, message: String? = nil) {
        for _callback in callbacks.values {
            _callback(status, message: message)
        }
    }
    
}