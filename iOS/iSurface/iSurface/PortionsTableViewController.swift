//
//  PortionsTableViewController.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class PortionsTableViewController: UITableViewController {
    
    private let surface = Settings.currentSurface
    
    // Not elegant solution
    private var portionToInsertIndexPath: NSIndexPath?
    private var currentEditingPortionIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        RemoteController.setEditingState(true, portionId: -1)
        
        if let indexPath = currentEditingPortionIndexPath {
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text = surface.portions[indexPath.row].name
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            currentEditingPortionIndexPath = nil
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        if let indexPath = portionToInsertIndexPath {
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            portionToInsertIndexPath = nil
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surface.portions.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
                
        if indexPath.row == surface.portions.count {
            cell = tableView.dequeueReusableCellWithIdentifier("addPortionCell", forIndexPath: indexPath)
//            cell.textLabel?.text = "Add portion..."
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("portionCell", forIndexPath: indexPath)
            
            let mutableString = NSMutableAttributedString(string: "◉")
            mutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(24), range: NSMakeRange(0, 1))
            
            let color = UIColor(hex: surface.portions[indexPath.row].color)
            mutableString.addAttribute(NSStrokeColorAttributeName, value: color, range: NSMakeRange(0, 1))
            mutableString.addAttribute(NSStrokeWidthAttributeName, value: -3.0, range: NSMakeRange(0, 1))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: NSMakeRange(0, 1))
            cell.detailTextLabel?.attributedText = mutableString
            
            cell.textLabel?.text = surface.portions[indexPath.row].name        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row < surface.portions.count
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            surface.portions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            surface.portions.insert(surface.createPortion(), atIndex: indexPath.row)
            tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        surface.portions.insert(surface.portions[fromIndexPath.row], atIndex: toIndexPath.row)
        surface.portions.removeAtIndex(fromIndexPath.row + (fromIndexPath.row > toIndexPath.row ? 1 : 0))
    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.row == surface.portions.count {
            return NSIndexPath(
                forRow: proposedDestinationIndexPath.row - 1,
                inSection: proposedDestinationIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row < surface.portions.count
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == surface.portions.count {
            surface.portions += [surface.createPortion()]
            portionToInsertIndexPath = indexPath
            performSegueWithIdentifier("portionDetailsSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
        }
        currentEditingPortionIndexPath = indexPath
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "portionDetailsSegue" {
            if let dvc = segue.destinationViewController as? PortionDetailsViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    dvc.portion = surface.portions[indexPath.row]
                }
            }
        }
    }
}
