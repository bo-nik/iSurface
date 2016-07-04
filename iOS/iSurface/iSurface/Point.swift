//
//  Point.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

class Point: Hashable, CustomStringConvertible {
    
    var description: String {
        return "portion \(portion!.id), [\(row!), \(column!)]"
    }
    
    var x: Double = 0.0 {
        didSet {
            if oldValue != x {
                lastValue = (oldValue, y, z)
                valueChanged()
            }
        }
    }
    
    var y: Double = 0.0 {
        didSet {
            if oldValue != y {
                lastValue = (x, oldValue, z)
                valueChanged()
            }
        }
    }
    
    var z: Double = 0.0 {
        didSet {
            if oldValue != z {
                lastValue = (x, y, oldValue)
                valueChanged()
            }
        }
    }
    
    weak var portion: Portion? = nil
    var row: Int?
    var column: Int?
    
    private (set) var lastValue: (x: Double, y: Double, z: Double) = (0.0, 0.0, 0.0)
    
    func resetLastValue() {
        lastValue = (x, y, z)
    }
    
    init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0,
        parentPortion: (portion: Portion, row: Int, column: Int)? = nil, hash: Int? = nil) {
            self.x = x
            self.y = y
            self.z = z
            lastValue = (x, y, z)
            self.portion = parentPortion?.portion
            self.row = parentPortion?.row
            self.column = parentPortion?.column
            
            self.hash = hash ?? Point.hashCounter++
    }
    
    convenience init(_ another: Point) {
        self.init(x: another.x, y: another.y, z: another.z,
            parentPortion: another.portion == nil ? nil : (another.portion!, another.row!, another.column!), hash: another.hash)
        
    }
    
    private func valueChanged() {

        if !Settings.Temp.enablePointObserver {
            return
        }
        
        valueChangedCallback?()
        
        if Settings.currentSurface.portions.contains({ $0 === portion }) {
            if let _ = portion {
                var points: Set<Point> = []
                portion?.surface?.applyConstraintToPoint(self, ignorePoints: &points)
                RemoteController.updateAllAnchorPoints(Settings.currentSurface)
            }
        }
    }
    
    func toDisctionary() -> [String: AnyObject] {
        let data: [String: AnyObject] = [
            "x": x,
            "y": y,
            "z": z
        ]
        return data
    }
    
    static func fromDistionary(dictionary: [String: AnyObject]) -> Point {
        let point = Point()
        point.x = (dictionary["x"] as? Double) ?? 0.0
        point.y = (dictionary["y"] as? Double) ?? 0.0
        point.z = (dictionary["z"] as? Double) ?? 0.0
        point.resetLastValue()
        return point
    }
    
    var valueChangedCallback: (() -> Void)? = nil
    
    // MARK: - Hashable
    
    static private var hashCounter = 0
    private let hash: Int
    
    var hashValue: Int {
        return hash
    }
}

func ==(left: Point, right: Point) -> Bool {
    return left.hashValue == right.hashValue
}
