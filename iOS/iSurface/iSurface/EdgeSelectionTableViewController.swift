//
//  EdgeSelectionTableViewController.swift
//  iSurface
//
//  Created by iKing on 26.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class EdgeSelectionTableViewController: UITableViewController {
    
    var currentSelectedEdge: Portion.Edge? = nil
    
    var edgeSelectedCallback: ((Portion.Edge) -> ())? = nil

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Portion.Edge.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("edgeCell", forIndexPath: indexPath)

        let mutableString = NSMutableAttributedString(string: "◉    ◉")
        var firstColor = UIColor.blackColor()
        var secondColor = UIColor.blackColor()
        let edgesCount = Portion.Edge.count
        if indexPath.row % 2 == 0 {
            firstColor = UIColor(hex: Settings.Defaults.portionCornerColors[(indexPath.row / 2) % (edgesCount / 2)])
            secondColor = UIColor(hex: Settings.Defaults.portionCornerColors[(indexPath.row / 2 + 1) % (edgesCount / 2)])
        } else {
            firstColor = UIColor(hex: Settings.Defaults.portionCornerColors[(indexPath.row / 2 + 1) % (edgesCount / 2)])
            secondColor = UIColor(hex: Settings.Defaults.portionCornerColors[(indexPath.row / 2) % (edgesCount / 2)])
        }
        
        mutableString.addAttribute(NSStrokeColorAttributeName, value: firstColor, range: NSMakeRange(0, 1))
        mutableString.addAttribute(NSStrokeColorAttributeName, value: secondColor, range: NSMakeRange(5, 1))
        if currentSelectedEdge?.rawValue != indexPath.row {
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: NSMakeRange(0, 6))
        } else {
            mutableString.addAttribute(NSForegroundColorAttributeName, value: firstColor, range: NSMakeRange(0, 1))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: secondColor, range: NSMakeRange(5, 1))
        }
//        let shadow = NSShadow()
//        shadow.shadowBlurRadius = 5.0
//        mutableString.addAttribute(NSShadowAttributeName, value: shadow, range: NSMakeRange(0, 6))
        mutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(24), range: NSMakeRange(0, 6))
        mutableString.addAttribute(NSStrokeWidthAttributeName, value: -3.0, range: NSMakeRange(0, 6))
        cell.textLabel?.attributedText = mutableString

        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        edgeSelectedCallback?(Portion.Edge(rawValue: indexPath.row)!)
        navigationController?.popViewControllerAnimated(true)
    }
}
