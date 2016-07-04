//
//  PresetsTableViewController.swift
//  iSurface
//
//  Created by iKing on 24.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class PresetsTableViewController: UITableViewController {
    
    var presetsNames = [String]()
    
    var addedPresetName: String?
    
    private var selectedCellIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
        
        tableView.allowsMultipleSelection = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let oldPresets = presetsNames
        presetsNames = Settings.Presets.list().sort()
        
        if let name = addedPresetName {
            let row = presetsNames.indexOf(name) ?? presetsNames.count
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            
            if !oldPresets.contains(name) {
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
            
            selectedCellIndexPath = indexPath
            addedPresetName = nil
        }
        
        if let indexPath = selectedCellIndexPath {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectedCellIndexPath = nil
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedCellIndexPath = indexPath
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetsNames.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.row == presetsNames.count {
            cell = tableView.dequeueReusableCellWithIdentifier("addPresetCell", forIndexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("presetCell", forIndexPath: indexPath)
            cell.textLabel?.text = presetsNames[indexPath.row]
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != presetsNames.count
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            Settings.Presets.removeWithName(presetsNames[indexPath.row])
            presetsNames.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != presetsNames.count {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let alert = UIAlertController(title: "Load preset?",
                message: "Preset will replace existing surface. Continue?",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Load", style: .Destructive, handler: {
                [unowned self, weak navigationController = navigationController] _ in
                Settings.currentSurface = Settings.Presets.load(self.presetsNames[indexPath.row])
                navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
