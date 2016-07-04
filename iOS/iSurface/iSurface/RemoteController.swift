//
//  RemoteController.swift
//  iSurface
//
//  Created by iKing on 23.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

class RemoteController {
    
    static func setSurface(surface: Surface) {
        ConnectionManager.send("set_surface", data: [
            "surface": surface.toDisctionary()
            ]
        )
    }
    
    static func clearSurface() {
        ConnectionManager.send("clear_surface", data: [:])
    }
    
    static func updateAnchorPoint(point: Point) {
        ConnectionManager.send("update_anchor_point", data: [
            "point": point.toDisctionary(),
            "portion-id": point.portion!.id ?? -1,
            "row": point.row ?? -1,
            "column": point.column ?? -1
            ]
        )
    }
    
    static func updateAllAnchorPoints(surface: Surface) {
        Settings.Temp.enableChachingUpdates++
        for portion in surface.portions {
            for i in 0...portion.degree.n {
                for j in 0...portion.degree.m {
                    updateAnchorPoint(portion.anchorPoints[i][j])
                }
            }
        }
        Settings.Temp.enableChachingUpdates--
    }
    
    static func addPortion(portion: Portion) {
        ConnectionManager.send("add_portion", data: [
            "portion": portion.toDisctionary()
            ]
        )
    }

    static func removePortionWithId(id: Int) {
        ConnectionManager.send("remove_portion", data: [
            "portion-id": id
            ]
        )
    }
    
    static func rotate(roll roll: Double, pitch: Double, yaw: Double) {
        ConnectionManager.send("set_rotation", data: [
            "rotation": [
                "x": -pitch,
                "y": -yaw,
                "z": -roll
            ]]
        )
    }
    
    static func rotatePermanent(x x: Double, y: Double, z: Double) {
        ConnectionManager.send("set_permanent_rotation", data: [
            "rotation": [
                "x": x,
                "y": y,
                "z": z
            ]]
        )
    }
    
    static func translatePermanent(x x: Double, y: Double, z: Double) {
        ConnectionManager.send("set_permanent_translation", data: [
            "translation": [
                "x": x,
                "y": y,
                "z": z
            ]]
        )
    }
    
//    static func translate(dx dx: Double, dy: Double, dz: Double) {
//        ConnectionManager.send("translate", data: [
//            "translation": [
//                "dx": dx,
//                "dy": dy,
//                "dz": dz
//            ]]
//        )
//    }
    
    static func setCachingUpdates(enable: Bool) {
        ConnectionManager.send("set_caching_updates", data: [
            "enable": enable]
        )
    }
    
    static func setEditingState(editing: Bool, portionId: Int? = nil) {
        var  data: [String: AnyObject] = [
            "editing": editing
        ]
        if let portionId = portionId {
            data["portion-id"] = portionId
        }
        ConnectionManager.send("set_editing_state", data: data)
    }
    
    static func setConstraintEditingState(editing: Bool, firstPortionId: Int? = nil, secondPortionId: Int? = nil) {
        var  data: [String: AnyObject] = [
            "editing": editing
        ]
        data["first-portion-id"] = firstPortionId ?? -1
        data["second-portion-id"] = secondPortionId ?? -1
        ConnectionManager.send("set_constraint_editing_state", data: data)
    }
    
    static func setDefaults(name: String, value: AnyObject) {
        let  data: [String: AnyObject] = [
            "name": name,
            "value": value
        ]
        ConnectionManager.send("set_defaults", data: data)
    }
}