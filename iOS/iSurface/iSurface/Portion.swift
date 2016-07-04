//
//  Portion.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

class Portion {

    // MARK: - Edge
    // Order matters. Clockwise.
    enum Edge: Int {
        case Top = 0
        case TopInverted
        case Right
        case RightInverted
        case BottomInverted
        case Bottom
        case LeftInverted
        case Left
        
        static var count: Int {
            return Edge.Left.hashValue + 1
        }
        
        var isInverted: Bool {
            switch self {
            case .LeftInverted, .TopInverted, .RightInverted, .BottomInverted:
                return true;
            default:
                return false;
            }
        }
    }
    
    // MARK: - Portion

    let id: Int
    var name: String
    let degree: (n: Int, m: Int)
    let anchorPoints: [[Point]]
    weak var surface: Surface? = nil
    
    var color: UInt {
        return Settings.Defaults.globalColors[id % Settings.Defaults.globalColors.count]
    }
    
    init(degree: (n: Int, m: Int), name: String = "[Unnamed]", id: Int = 0,
        anchorPoints: [[Point]]? = nil, surface: Surface? = nil) {
        // TODO: n, m >= 3
        self.name = name
        self.degree = degree
        self.id = id
        self.surface = surface
        
        var points: [[Point]] = []
        for i in 0...degree.n {
            points += [[]]
            for j in 0...degree.m {
                // TODO: Fix!
                let point = anchorPoints?[i][j] ?? Point(x: -6.0 + Double(j) * 4.0, y: 0.0, z: 6 - Double(i) * 4.0)
                points[i] += [point]
            }
        }
        self.anchorPoints = points
        
        // Set parent portion to every point
        for i in 0...degree.n {
            for j in 0...degree.m {
                self.anchorPoints[i][j].portion = self
                self.anchorPoints[i][j].row = i
                self.anchorPoints[i][j].column = j
            }
        }

    }
    
    func toDisctionary() -> [String: AnyObject] {
        let data: [String: AnyObject] = [
            "id": id,
            "name": name,
            "degree": [
                "n": degree.n,
                "m": degree.m
            ],
            "anchor-points": anchorPoints.map({ $0.map( { $0.toDisctionary() }) })
        ]
        
        return data
    }
    
    static func fromDistionary(dictionary: [String: AnyObject]) -> Portion {
        let degree = (
            n: (dictionary["degree"]?["n"] as? Int) ?? 0,
            m: (dictionary["degree"]?["m"] as? Int) ?? 0)
        let id = (dictionary["id"] as? Int) ?? 0
        
        var anchorPoints: [[Point]]? = nil
        if let points = dictionary["anchor-points"] as? [[[String: AnyObject]]] {
            anchorPoints = []
            for i in 0...degree.n {
                anchorPoints! += [[]]
                for j in 0...degree.m {
                    anchorPoints![i] += [Point.fromDistionary(points[i][j])]
                }
            }
        }
        
        let portion = Portion(degree: degree, id: id, anchorPoints: anchorPoints)
        if let name = dictionary["name"] as? String {
            portion.name = name
        }
        return portion
    }
}