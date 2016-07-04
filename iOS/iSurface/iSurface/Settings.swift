//
//  Settings.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

class Settings {
    
    // MARK: - Temp
    
    struct Temp {
        static var permanentRotation = (x: 0.0, y: 0.0, z: 0.0) {
            didSet {
                permanentRotation.x %= 360
                permanentRotation.y %= 360
                permanentRotation.z %= 360
                RemoteController.rotatePermanent(
                    x: permanentRotation.x,
                    y: permanentRotation.y,
                    z: permanentRotation.z)
            }
        }
        
        static var permanentTanslation = (x: 0.0, y: 0.0, z: 0.0) {
            didSet {
                RemoteController.translatePermanent(
                    x: permanentTanslation.x,
                    y: permanentTanslation.y,
                    z: permanentTanslation.z)
            }
        }
        
        static var gyroscopeRotation = (roll: 0.0, pitch: 0.0, yaw: 0.0) {
            didSet {
                RemoteController.rotate(
                    roll: gyroscopeRotation.roll,
                    pitch: gyroscopeRotation.pitch,
                    yaw: gyroscopeRotation.yaw)
            }
        }
        
        static var enableChachingUpdates = 0 {
            didSet {
                if enableChachingUpdates != oldValue {
                    if enableChachingUpdates < 0 {
                        enableChachingUpdates = 0
                    }
                    if enableChachingUpdates > 0 {
                        RemoteController.setCachingUpdates(true)
                    } else {
                        RemoteController.setCachingUpdates(false)
                    }
                }
            }
        }
        
        static var enablePointObserver = true
    }
    
    // MARK: - Defaults
    
    struct Defaults {
        static let valuesRange = -999...999
        
//        static let globalColors: [UInt] = [
//            0xFF0000, 0x00FF00, 0x0000FF,
//            0xFFFF00, 0xFF00FF, 0x00FFFF,
//            0x880000, 0x008800, 0x000088]

        static let globalColors: [UInt] = [
            0x880000, 0x008800, 0x000088,
            0x888800, 0x880088, 0x008888,
            0xFF0000, 0x00FF00, 0x0000FF]
        
        static let portionCornerColors: [UInt] = [
            globalColors[0],
            globalColors[1],
            globalColors[2],
            globalColors[3]
        ]
        
        static let maxPortionsCount = 1024
    }
    
    // MARK: - Network
    
    struct Network {
        static var ip: String = "0.0.0.0"
        static var port: UInt16 = 8088
    }
    
    // MARK: - Presets
    
    struct Presets {
        static func add(surface: Surface) {

            var data = [String: AnyObject]()
            
            if var surfaces = NSUserDefaults.standardUserDefaults().dictionaryForKey("surfaces") {
                if var presets = surfaces["presets"] as? [String: AnyObject] {
                    presets[surface.name] = surface.toDisctionary()
                    surfaces["presets"] = presets
                } else {
                    surfaces["presets"] = [surface.name : surface.toDisctionary()]
                }
                data["surfaces"] = surfaces
            } else {
                data = [
                    "surfaces": [
                        "presets": [
                            surface.name : surface.toDisctionary()
                        ]
                    ]
                ]
            }
            
            NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(data)
        }
        
        static func removeWithName(name: String) {
            if var surfaces = NSUserDefaults.standardUserDefaults().dictionaryForKey("surfaces") {
                if var presets = surfaces["presets"] as? [String: AnyObject] {
                    presets.removeValueForKey(name)
                    surfaces["presets"] = presets
                }
                NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(["surfaces": surfaces])
            }
        }
        
        static func load(name: String) -> Surface {
            if var surfaces = NSUserDefaults.standardUserDefaults().dictionaryForKey("surfaces") {
                return Surface.fromDistionary(surfaces["presets"]?[name] as? [String: AnyObject] ?? [:])
            }
            return Surface(degree: (n: 3, m: 3))
        }
        
        static func list() -> [String] {
            if let surfaces = NSUserDefaults.standardUserDefaults().dictionaryForKey("surfaces") {
                if let presets = surfaces["presets"] as? [String: AnyObject] {
                    return Array(presets.keys)
                }
            }
            return []
        }
    }
    
    // MARK: - Appearance
    
    struct Appearance {
        
        enum SkeletonVisibility: Int {
            case Always = 0
            case OnPortionEditing
            case Never
            
            static var count: Int {
                return SkeletonVisibility.Never.hashValue + 1
            }
            
            var label: String {
                switch self {
                case Always:
                    return "Always"
                case OnPortionEditing:
                    return "On portion editing"
                case Never:
                    return"Never"
                }
            }
        }
        
        static var skeletonVisibility = SkeletonVisibility.OnPortionEditing {
            didSet {
                if oldValue != skeletonVisibility {
                    RemoteController.setDefaults("skeleton-visibility", value: skeletonVisibility.rawValue)
                }
            }
        }
    }
    
    // MARK: - Motion
    
    struct Motion {
        static var enabled = true
    }
    
    // MARK: - Current surface
    
    static var currentSurface: Surface = Surface(degree: (n: 3, m: 3)) {
        didSet {
            RemoteController.setSurface(currentSurface)
        }
    }
    
    // MARK: - Save / Load
    
    static func save() {
        
        // Current surface
        var data = [String: AnyObject]()
        if var surfaces = NSUserDefaults.standardUserDefaults().dictionaryForKey("surfaces") {
            surfaces["current"] = currentSurface.toDisctionary()
            data["surfaces"] = surfaces
        } else {
            data = [
                "surfaces": [
                    "current": currentSurface.toDisctionary()
                ]
            ]
        }
        NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(data)
        
        // Network
        data = [
            "network": [
                "ip": Network.ip,
                "port": Int(Network.port)
            ],
            "appearance": [
                "skeleton-visibility": Appearance.skeletonVisibility.rawValue
            ]
        ]
        NSUserDefaults.standardUserDefaults().setValuesForKeysWithDictionary(data)
    }
    
    static func load() {
        
        // Current surface
        if let current = NSUserDefaults.standardUserDefaults().dictionaryForKey("surfaces")?["current"]
            as? [String: AnyObject] {
            currentSurface = Surface.fromDistionary(current)
        }
        
        // Network
        if let network = NSUserDefaults.standardUserDefaults().dictionaryForKey("network") {
            if let ip = network["ip"] as? String {
                Network.ip = ip
            }
            if let port = network["port"] as? Int {
                Network.port = UInt16(port)
            }
        }
        
        // Appearance
        if let appearance = NSUserDefaults.standardUserDefaults().dictionaryForKey("appearance") {
            if let skeletonVisibility = appearance["skeleton-visibility"] as? Int {
                Appearance.skeletonVisibility = Appearance.SkeletonVisibility(rawValue: skeletonVisibility) ?? .OnPortionEditing
            }
        }
    }
    
}