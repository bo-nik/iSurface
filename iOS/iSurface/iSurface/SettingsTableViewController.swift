//
//  SettingsTableViewController.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var degreeDetailsLabel: UILabel!
    @IBOutlet weak var portionsDetailsLabel: UILabel!
    @IBOutlet weak var presetsDetailLabel: UILabel!
    @IBOutlet weak var constraintsDetailLabel: UILabel!
    @IBOutlet weak var skeletonVisibilityDetailLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        RemoteController.setEditingState(false)
        RemoteController.setConstraintEditingState(false)
        
        ConnectionManager.addCallback(connectionStatusChanged, withTag: "SettingsTableViewController")
        connectionStatusChanged(ConnectionManager.connectionState)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        updateDetailsLabels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ConnectionManager.removeCallbackWithTag("NetworkTableViewController")
    }
    
    func updateDetailsLabels() {
        let surface = Settings.currentSurface
        degreeDetailsLabel.text = "[\(surface.degree.n) x \(surface.degree.m)]"
        portionsDetailsLabel.text = "\(surface.portions.count)"
        presetsDetailLabel.text = "\(Settings.Presets.list().count)"
        constraintsDetailLabel.text = "\(Settings.currentSurface.constraints.count)"
        skeletonVisibilityDetailLabel.text = Settings.Appearance.skeletonVisibility.label
    }
    
    func connectionStatusChanged(status: ConnectionManager.ConnectionStatus, message: String? = nil) {
        
        var connectionStatusLabelText = ""
        switch status {
        case .Connecting:
            connectionStatusLabelText = "Connecting..."
        case .Connected:
            connectionStatusLabelText = "Connected"
        case .Disconnected:
            connectionStatusLabelText = "Disconnected"
        }
        
        UIView.transitionWithView(connectionStatusLabel, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak label = self.connectionStatusLabel] in label!.text = connectionStatusLabelText },
            completion: nil)
    }
    
    @IBAction func toggleGyroscope(sender: UISwitch) {
        Settings.Motion.enabled = sender.on
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 4 && indexPath.row == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            MotionManager.prepareForCalibration()
        }
    }
}
