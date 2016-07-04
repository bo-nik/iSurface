//
//  ConstraintsTableViewController.swift
//  iSurface
//
//  Created by iKing on 26.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class ConstraintsTableViewController: UITableViewController {
    
    private var surface = Settings.currentSurface

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        RemoteController.setConstraintEditingState(false)
        
        surface = Settings.currentSurface
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surface.constraints.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.row == surface.constraints.count {
            cell = tableView.dequeueReusableCellWithIdentifier("addConstraintCell", forIndexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("constraintCell", forIndexPath: indexPath)
            let constraint = surface.constraints[indexPath.row]
            if let firstPortionName = surface.portionWithId(constraint.first.portionId)?.name,
                secondPortionName = surface.portionWithId(constraint.second.portionId)?.name {
                    cell.textLabel?.text = firstPortionName + " - " + secondPortionName
            }
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != surface.constraints.count
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            surface.constraints.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewConstraint" {
            if let dvc = segue.destinationViewController as? AddConstraintTableViewController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
                dvc.readOnly = true
                if let indexPath = tableView.indexPathForSelectedRow {
                    let constraint = surface.constraints[indexPath.row]
                    dvc.smooth = constraint.smooth
                    dvc.selectedFirstPortionIndex = surface.portions.indexOf({ $0.id == constraint.first.portionId })
                    dvc.selectedFirstPortionEdge = constraint.first.edge
                    dvc.selectedSecondPortionIndex = surface.portions.indexOf({ $0.id == constraint.second.portionId })
                    dvc.selectedSecondPortionEdge = constraint.second.edge
                }
            }
        } else if segue.identifier == "addConstraint" {
            if let dvc = segue.destinationViewController as? AddConstraintTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
                    dvc.constraintAddedCallback = { [weak tableView = self.tableView] added in
                        if added {
                            UIView.setAnimationsEnabled(false)
                            tableView?.beginUpdates()
                            tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                            tableView?.endUpdates()
                            UIView.setAnimationsEnabled(true)
                            tableView?.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                        }
                    }
                }
            }
        }
    }
}
