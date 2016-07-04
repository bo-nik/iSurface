//
//  PortionSelectionTableViewController.swift
//  iSurface
//
//  Created by iKing on 26.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class PortionSelectionTableViewController: UITableViewController {
    
    var currentSelectedPortionIndex: Int? = nil
    var alreadySelectedPortionIndex: Int? = nil
    
    private var portions = Settings.currentSurface.portions
    
    var portionSelectedCallback: ((Int) -> ())? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = alreadySelectedPortionIndex {
            portions.removeAtIndex(index)
            if let currentIndex = currentSelectedPortionIndex {
                if index <= currentIndex {
                    currentSelectedPortionIndex = currentIndex - 1
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
//        if let index = currentSelectedPortionIndex {
//            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
//            cell?.accessoryType = .Checkmark
//        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("portionCell", forIndexPath: indexPath)
        let mutableString = NSMutableAttributedString(string: "◉")
        mutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(24), range: NSMakeRange(0, 1))
        
        let color = UIColor(hex: portions[indexPath.row].color)
        mutableString.addAttribute(NSStrokeColorAttributeName, value: color, range: NSMakeRange(0, 1))
        mutableString.addAttribute(NSStrokeWidthAttributeName, value: -3.0, range: NSMakeRange(0, 1))
        if currentSelectedPortionIndex == indexPath.row {
             mutableString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, 1))
        } else {
             mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: NSMakeRange(0, 1))
        }
        
        cell.textLabel?.text = portions[indexPath.row].name
        cell.detailTextLabel?.attributedText = mutableString
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let index = alreadySelectedPortionIndex where index <= indexPath.row {
            portionSelectedCallback?(indexPath.row + 1)
        } else {
            portionSelectedCallback?(indexPath.row)
        }
        navigationController?.popViewControllerAnimated(true)
    }
}
