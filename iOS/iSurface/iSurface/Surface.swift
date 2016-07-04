//
//  Surface.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

class Surface {
    
    // MARK: - Constraint
    
    struct Constraint: Equatable {
        var first: (portionId: Int, edge: Portion.Edge)
        var second: (portionId: Int, edge: Portion.Edge)
        var smooth = true
        
        func toDisctionary() -> [String: AnyObject] {
            let data: [String: AnyObject] = [
                "first": [
                    "portion-id": first.portionId,
                    "edge": first.edge.rawValue
                ],
                "second": [
                    "portion-id": second.portionId,
                    "edge": second.edge.rawValue
                ],
                "smooth": smooth
            ]
            return data
        }
        
        static func fromDistionary(dictionary: [String: AnyObject]) -> Constraint! {
            if let first = dictionary["first"] as? [String: AnyObject],
                second = dictionary["second"] as? [String: AnyObject],
                smooth = dictionary["smooth"] as? Bool {
                if let firstPortionId = first["portion-id"] as? Int,
                    secondPortionId = second["portion-id"] as? Int,
                    firstEdge = first["edge"] as? Int,
                    secondEdge = second["edge"] as? Int {
                        return Constraint(
                            first: (firstPortionId, Portion.Edge(rawValue: firstEdge) ?? .Left),
                            second: (secondPortionId, Portion.Edge(rawValue: secondEdge) ?? .Left),
                            smooth: smooth)
                    }
            }
            return nil
        }
    }
    
    // MARK: - Surface
    
    var name: String
    let degree: (n: Int, m: Int)
    
    var portions: [Portion] = [] {
        didSet {
            // Set 'self' surface as parent for every portion in this surface
            for portion in portions {
                portion.surface = self
            }
            
            if self !== Settings.currentSurface {
                return
            }
            
            for portion in oldValue {
                if !portions.contains({ $0 === portion }) {
                    RemoteController.removePortionWithId(portion.id)
                    
                    // Remove extra constraints
                    for constraint in constraints {
                        if constraint.first.portionId == portion.id || constraint.second.portionId == portion.id {
                            constraints.removeAtIndex(constraints.indexOf(constraint)!)
                        }
                    }
                }
            }
            
            for portion in portions {
                if !oldValue.contains({ $0 === portion }) {
                    RemoteController.addPortion(portion)
                }
            }
        }
    }
    
    var constraints: [Constraint] = [] {
        didSet {
            for constraint in constraints {
                if !oldValue.contains({ $0 == constraint }) {
                    let portion = portionWithId(constraint.first.portionId)
                    
                    var ignoredOuterPoints: Set<Point> = []
                    for portion in portions {
                        if portion !== portionWithId(constraint.second.portionId) {
                            for i in 0...portion.degree.n {
                                for j in 0...portion.degree.m {
                                    ignoredOuterPoints.insert(portion.anchorPoints[i][j])
                                }
                            }
                        }
                    }
                    var ignoredPointsInner = ignoredOuterPoints
                    
                    // Edge points
                    for i in 0...portion!.degree.n {
                        for j in 0...portion!.degree.m {
                            if i == 0 || i == portion!.degree.n ||
                                j == 0 || j == portion?.degree.m {
                                    Settings.currentSurface.applyConstraintToPoint(portion!.anchorPoints[i][j], ignorePoints: &ignoredOuterPoints)
                            }
                        }
                    }
                    
                    // Inner points
                    for i in 1...(portion!.degree.n - 1) {
                        for j in 1...(portion!.degree.m - 1) {
                            Settings.currentSurface.applyConstraintToPoint(portion!.anchorPoints[i][j], ignorePoints: &ignoredPointsInner)
                        }
                    }
                    
                    RemoteController.updateAllAnchorPoints(Settings.currentSurface)
                }
            }
            
            
//            for constraint in constraints {
//                if !oldValue.contains({ $0 == constraint }) {
//                    let portion = portionWithId(constraint.first.portionId)
//                    
//                    var ignoredOuterPoints: Set<Point> = []
//                    for i in 0...portion!.degree.n {
//                        for j in 0...portion!.degree.m {
//                            ignoredOuterPoints.insert(portion!.anchorPoints[i][j])
//                        }
//                    }
//                    var ignoredPointsInner = ignoredOuterPoints
//                    
//                    // Edge points
//                    for i in 0...portion!.degree.n {
//                        for j in 0...portion!.degree.m {
//                            if i == 0 || i == portion!.degree.n ||
//                                j == 0 || j == portion?.degree.m {
//                                    Settings.currentSurface.applyConstraintToPoint(portion!.anchorPoints[i][j], ignorePoints: &ignoredOuterPoints)
//                            }
//                        }
//                    }
//                    
//                    // Inner points
//                    for i in 1...(portion!.degree.n - 1) {
//                        for j in 1...(portion!.degree.m - 1) {
//                            Settings.currentSurface.applyConstraintToPoint(portion!.anchorPoints[i][j], ignorePoints: &ignoredPointsInner)
//                        }
//                    }
//                    
//                    RemoteController.updateAllAnchorPoints(Settings.currentSurface)
//                }
//            }
        }
    }
    
    init(degree: (n: Int, m: Int), name: String = "[Unnamed]") {
        self.name = name
        self.degree = degree
    }
    
    func createPortion() -> Portion {
        let id = generatePortionId()
        return Portion(degree: degree, name: "Portion \(id)", id: id, surface: self)
    }
    
    func generatePortionId() -> Int {
        if let maxId = portions.maxElement({ $0.id < $1.id })?.id {
            return maxId + 1
        }
        return 0
    }
    
    func portionWithId(id: Int) -> Portion? {
        return portions.filter({ $0.id == id }).first
    }
    
    func toDisctionary() -> [String: AnyObject] {
        var data: [String: AnyObject] = [
            "name": name,
            "degree": [
                "n": degree.n,
                "m": degree.m
            ],
            "portions": portions.map({ $0.toDisctionary() })
        ]
        var constraintsDictionaries: [[String: AnyObject]] = []
        for constraint in constraints {
            constraintsDictionaries += [constraint.toDisctionary()]
        }
        data["constraints"] = constraintsDictionaries
        return data
    }
    
    static func fromDistionary(dictionary: [String: AnyObject]) -> Surface {
        let degree = (
            n: (dictionary["degree"]?["n"] as? Int) ?? 0,
            m: (dictionary["degree"]?["m"] as? Int) ?? 0)
        
        let surface = Surface(degree: degree)
        if let name = dictionary["name"] as? String {
            surface.name = name
        }
        if let portionsDictonary = dictionary["portions"] as? [[String: AnyObject]] {
            for portionDictonary in portionsDictonary {
                surface.portions += [Portion.fromDistionary(portionDictonary)]
            }
        }
        if let constraintsDictionaries = dictionary["constraints"] as? [[String: AnyObject]] {
            for constraintDictionary in constraintsDictionaries {
                surface.constraints += [Constraint.fromDistionary(constraintDictionary)]
            }
        }
        return surface
    }
    
    // MARK: - Apply constraints
    
    func applyConstraintToPoint(point: Point, inout ignorePoints: Set<Point>, initialPointLiesOnEdge: Bool? = nil) {
    
        if point.portion == nil {
            return
        }
        
        ignorePoints.insert(point)
        
        let firstCall = initialPointLiesOnEdge == nil
        var initialPointLiesOnEdgeForPointsToApply: [Bool] = []
        
        Settings.Temp.enablePointObserver = false
        
        let portion = point.portion!
        var pointsToApplyConstraints: [Point] = []
        
        // Find points for other part of constraint (for other edge)
        func constraintSecondPortionLinkedPoints(firstEdge firstEdge: Portion.Edge, secondEdge:
            Portion.Edge, secondPortion: Portion, index: Int) -> (edgePoint: Point, innerPoint: Point) {
                let inverse = (firstEdge.isInverted || secondEdge.isInverted) && (firstEdge.isInverted != secondEdge.isInverted)
                switch secondEdge {
                case .Left, .LeftInverted:
                    let i = inverse ? secondPortion.degree.n - index : index
                    return (
                        secondPortion.anchorPoints[i][0],
                        secondPortion.anchorPoints[i][1])
                case .Top, .TopInverted:
                    let j = inverse ? secondPortion.degree.m - index : index
                    return (
                        secondPortion.anchorPoints[0][j],
                        secondPortion.anchorPoints[1][j])
                case .Right, .RightInverted:
                    let i = inverse ? secondPortion.degree.n - index : index
                    return (
                        secondPortion.anchorPoints[i][secondPortion.degree.m],
                        secondPortion.anchorPoints[i][secondPortion.degree.m - 1])
                case .Bottom, .BottomInverted:
                    let j = inverse ? secondPortion.degree.m - index : index
                    return (
                        secondPortion.anchorPoints[secondPortion.degree.n][j],
                        secondPortion.anchorPoints[secondPortion.degree.n - 1][j])
                }
        }
        
        // Check if there are some constraints for this portion
        let constraints = self.constraints.filter({
            $0.first.portionId == portion.id || $0.second.portionId == portion.id
        })
        for constarint in constraints {
            var firstConstraintPart = constarint.first
            var secondConstraintPart = constarint.second
            if firstConstraintPart.portionId != portion.id {
                swap(&firstConstraintPart, &secondConstraintPart)
            }
            if let firstPortion = portionWithId(firstConstraintPart.portionId),
                secondPortion = portionWithId(secondConstraintPart.portionId) {
                    let firstEdge = firstConstraintPart.edge
                    let secondEdge = secondConstraintPart.edge
                    
                    var constraintPoints: (
                    first: (edgePoint: Point, innerPoint: Point),
                    second: (edgePoint: Point, innerPoint: Point))! = nil
                    
                    switch firstEdge {
                    case .Left, .LeftInverted:
                        if point.column == 0 || point.column == 1 {
                            constraintPoints = (
                                first: (
                                    edgePoint: firstPortion.anchorPoints[point.row!][0],
                                    innerPoint: firstPortion.anchorPoints[point.row!][1]
                                ),
                                second: constraintSecondPortionLinkedPoints(firstEdge: firstEdge, secondEdge: secondEdge,
                                    secondPortion: secondPortion, index: point.row!)
                            )
                        }
                    case .Top, .TopInverted:
                        if point.row == 0 || point.row == 1 {
                            constraintPoints = (
                                first: (
                                    edgePoint: firstPortion.anchorPoints[0][point.column!],
                                    innerPoint: firstPortion.anchorPoints[1][point.column!]
                                ),
                                second: constraintSecondPortionLinkedPoints(firstEdge: firstEdge, secondEdge: secondEdge,
                                    secondPortion: secondPortion, index: point.column!)
                            )
                        }
                    case .Right, .RightInverted:
                        if point.column == portion.degree.m || point.column == portion.degree.m - 1 {
                            constraintPoints = (
                                first: (
                                    edgePoint: firstPortion.anchorPoints[point.row!][firstPortion.degree.m],
                                    innerPoint: firstPortion.anchorPoints[point.row!][firstPortion.degree.m - 1]
                                ),
                                second: constraintSecondPortionLinkedPoints(firstEdge: firstEdge, secondEdge: secondEdge,
                                    secondPortion: secondPortion, index: point.row!)
                            )
                        }
                    case .Bottom, .BottomInverted:
                        if point.row == portion.degree.n || point.row == portion.degree.n - 1 {
                            constraintPoints = (
                                first: (
                                    edgePoint: firstPortion.anchorPoints[secondPortion.degree.n][point.column!],
                                    innerPoint: firstPortion.anchorPoints[secondPortion.degree.n - 1][point.column!]
                                ),
                                second: constraintSecondPortionLinkedPoints(firstEdge: firstEdge, secondEdge: secondEdge,
                                    secondPortion: secondPortion, index: point.column!)
                            )
                        }
                    }
                    
                    // Apply constraint
                    if let constraintPoints = constraintPoints {
                        
                        // Edge point was moved
                        if constraintPoints.first.edgePoint === point {
                            if !ignorePoints.contains(constraintPoints.second.edgePoint) {
                                constraintPoints.second.edgePoint.x = constraintPoints.first.edgePoint.x
                                constraintPoints.second.edgePoint.y = constraintPoints.first.edgePoint.y
                                constraintPoints.second.edgePoint.z = constraintPoints.first.edgePoint.z
                                ignorePoints.insert(constraintPoints.second.edgePoint)
                                pointsToApplyConstraints += [constraintPoints.second.edgePoint]
                                initialPointLiesOnEdgeForPointsToApply += [true]
                            }
                            
                            if constarint.smooth {
                                let dx = constraintPoints.first.edgePoint.x - constraintPoints.first.edgePoint.lastValue.x
                                let dy = constraintPoints.first.edgePoint.y - constraintPoints.first.edgePoint.lastValue.y
                                let dz = constraintPoints.first.edgePoint.z - constraintPoints.first.edgePoint.lastValue.z
                                
                                if !ignorePoints.contains(constraintPoints.first.innerPoint) {
                                    constraintPoints.first.innerPoint.x += dx
                                    constraintPoints.first.innerPoint.y += dy
                                    constraintPoints.first.innerPoint.z += dz
                                    ignorePoints.insert(constraintPoints.first.innerPoint)
                                    pointsToApplyConstraints += [constraintPoints.first.innerPoint]
                                    initialPointLiesOnEdgeForPointsToApply += [true]
                                }
                                
                                if !ignorePoints.contains(constraintPoints.second.innerPoint) {
                                    constraintPoints.second.innerPoint.x += dx
                                    constraintPoints.second.innerPoint.y += dy
                                    constraintPoints.second.innerPoint.z += dz
                                    ignorePoints.insert(constraintPoints.second.innerPoint)
                                    pointsToApplyConstraints += [constraintPoints.second.innerPoint]
                                    initialPointLiesOnEdgeForPointsToApply += [true]
                                }
                            }
                        }  else { // Inner point was moved
                            if constarint.smooth && !(initialPointLiesOnEdge ?? false) {
                                if constarint.smooth {
                                    if !ignorePoints.contains(constraintPoints.second.innerPoint) {
                                        let origin = (
                                            x: constraintPoints.first.edgePoint.x,
                                            y: constraintPoints.first.edgePoint.y,
                                            z: constraintPoints.first.edgePoint.z)
                                        let firstInnerPoint = (
                                            x: constraintPoints.first.innerPoint.x - origin.x,
                                            y: constraintPoints.first.innerPoint.y - origin.y,
                                            z: constraintPoints.first.innerPoint.z - origin.z)
                                        let secondInnerPoint = (
                                            x: constraintPoints.second.innerPoint.x - origin.x,
                                            y: constraintPoints.second.innerPoint.y - origin.y,
                                            z: constraintPoints.second.innerPoint.z - origin.z)

                                        let r1 = sqrt(pow(firstInnerPoint.x, 2) + pow(firstInnerPoint.y, 2) + pow(firstInnerPoint.z, 2))
                                        let r2 = sqrt(pow(secondInnerPoint.x, 2) + pow(secondInnerPoint.y, 2) + pow(secondInnerPoint.z, 2))
                                        let r3 = sqrt(
                                            pow(secondInnerPoint.x - firstInnerPoint.x, 2) +
                                            pow(secondInnerPoint.y - firstInnerPoint.y, 2) +
                                            pow(secondInnerPoint.z - firstInnerPoint.z, 2))
                                        let p = (r1 + r2 + r3) / 2
                                        let S = sqrt(p * (p - r1) * (p - r2) * (p - r3))
                                        
                                        if S > 0.01 {
                                            let theta = atan2(sqrt(pow(firstInnerPoint.x, 2) + pow(firstInnerPoint.y, 2)), firstInnerPoint.z) - M_PI
                                            let phi = atan2(firstInnerPoint.y, firstInnerPoint.x)
                                            
                                            constraintPoints.second.innerPoint.x = origin.x + r1 * sin(theta) * cos(phi)
                                            constraintPoints.second.innerPoint.y = origin.y + r1 * sin(theta) * sin(phi)
                                            constraintPoints.second.innerPoint.z = origin.z + r1 * cos(theta)
                                        }
                                        ignorePoints.insert(constraintPoints.second.innerPoint)
                                        pointsToApplyConstraints += [constraintPoints.second.innerPoint]
                                        initialPointLiesOnEdgeForPointsToApply += [false]
                                    }
                                }
                            }
                        }
                    }
                    
            }
        }
        
        for (i, point) in pointsToApplyConstraints.enumerate() {
            if firstCall {
                applyConstraintToPoint(point, ignorePoints: &ignorePoints,
                    initialPointLiesOnEdge: initialPointLiesOnEdgeForPointsToApply[i])
            } else {
                applyConstraintToPoint(point, ignorePoints: &ignorePoints,
                    initialPointLiesOnEdge: initialPointLiesOnEdge)
            }
        }
        
        Settings.Temp.enablePointObserver = true
    }
}

func == (left: Surface.Constraint, right: Surface.Constraint) -> Bool {
    if left.first.portionId == right.first.portionId &&
        left.first.edge == right.first.edge &&
        left.second.portionId == right.second.portionId &&
        left.second.edge == right.second.edge {
            return true
    }
    if right.first.portionId == left.first.portionId &&
        right.first.edge == left.first.edge &&
        right.second.portionId == left.second.portionId &&
        right.second.edge == left.second.edge {
            return true
    }
    return false
}
