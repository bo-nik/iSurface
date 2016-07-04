//
//  MotionManager.swift
//  iSurface
//
//  Created by Borys Pedos on 25.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation
import CoreMotion

class MotionManager {    
    
    private static var motionManager = CMMotionManager()
    
    private static var attitudeCalibration = (roll: 0.0, pitch: 0.0, yaw: 0.0)
    private static var isCalibrationg = false
    
    private static var lastAttitude: (roll: Double, pitch: Double, yaw: Double)? = nil
    
    static func start() {
        if isActive {
            return
        }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        guard motionManager.deviceMotionAvailable else {
            print("Device motion detection is not available...")
            return
        }
        lastAttitude = nil
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: motionHandler)
    }
    
    static func stop() {
        motionManager.stopDeviceMotionUpdates()
        lastAttitude = nil
    }
    
    static var prepareForCalibrationCallback: (() -> Void)? = nil
    
    static func prepareForCalibration() {
        if isActive {
            isCalibrationg = true
//            RemoteController.rotate(roll: 0.0, pitch: 0.0, yaw: 0.0)
            Settings.Temp.gyroscopeRotation = (0.0, 0.0, 0.0)
            prepareForCalibrationCallback?()
        }
    }
    
    static func calibrate() {
        if isActive {
            if let roll = motionManager.deviceMotion?.attitude.roll,
                pitch = motionManager.deviceMotion?.attitude.pitch,
                yaw = motionManager.deviceMotion?.attitude.yaw {
                    attitudeCalibration.roll = roll
                    attitudeCalibration.pitch = pitch
                    attitudeCalibration.yaw = yaw
                    lastAttitude = nil
            }
        }
        isCalibrationg = false
    }
    
    static var isActive: Bool {
        return motionManager.deviceMotionActive
    }
    
    private static func motionHandler(motion: CMDeviceMotion?, error: NSError?) {
        if isCalibrationg {
            return
        }
        if !Settings.Motion.enabled {
            lastAttitude = nil
            return
        }
        if let motionData = motion {
            let currentAttitude = (
                roll: motionData.attitude.roll - attitudeCalibration.roll,
                pitch: motionData.attitude.pitch - attitudeCalibration.pitch,
                yaw: motionData.attitude.yaw - attitudeCalibration.yaw)
            let eps = 0.01
            if let lastAttitude = lastAttitude {
                if abs(lastAttitude.roll - currentAttitude.roll) < eps &&
                    abs(lastAttitude.pitch - currentAttitude.pitch) < eps &&
                    abs(lastAttitude.yaw - currentAttitude.yaw) < eps {
                        return
                }
            }
            lastAttitude = currentAttitude
            
            let rad2deg = 180.0 / M_PI
        
            let roll = currentAttitude.roll * rad2deg
            let pitch = currentAttitude.pitch * rad2deg
            let yaw = currentAttitude.yaw * rad2deg
            
//            RemoteController.rotate(roll: roll, pitch: pitch, yaw: yaw)
            Settings.Temp.gyroscopeRotation = (roll, pitch, yaw)
        }
        if let err = error {
            print(err.localizedDescription)
        }
    }
}