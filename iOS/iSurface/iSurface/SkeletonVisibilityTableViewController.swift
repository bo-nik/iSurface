//
//  skeletonVisibilityTableViewController.swift
//  iSurface
//
//  Created by iKing on 28.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class SkeletonVisibilityTableViewController: UITableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCheckmarkPosition()
    }
    
    private func updateCheckmarkPosition() {
        for i in 0..<Settings.Appearance.SkeletonVisibility.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType =
                i == Settings.Appearance.skeletonVisibility.hashValue ? .Checkmark : .None
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.Appearance.SkeletonVisibility.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("skeletonVisibilityCaseCell", forIndexPath: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = Settings.Appearance.SkeletonVisibility.Always.label
        case 1:
            cell.textLabel?.text = Settings.Appearance.SkeletonVisibility.OnPortionEditing.label
        case 2:
            cell.textLabel?.text = Settings.Appearance.SkeletonVisibility.Never.label
        default:
            break
        }

        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            Settings.Appearance.skeletonVisibility = Settings.Appearance.SkeletonVisibility.Always
        case 1:
            Settings.Appearance.skeletonVisibility = Settings.Appearance.SkeletonVisibility.OnPortionEditing
        case 2:
            Settings.Appearance.skeletonVisibility = Settings.Appearance.SkeletonVisibility.Never
        default:
            break
        }
        
        updateCheckmarkPosition()
        navigationController?.popViewControllerAnimated(true)
    }
}
