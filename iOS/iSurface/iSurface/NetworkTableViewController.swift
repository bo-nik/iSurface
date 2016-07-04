//
//  NetworkTableViewController.swift
//  iSurface
//
//  Created by iKing on 22.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class NetworkTableViewController: UITableViewController {

    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var connectLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ConnectionManager.addCallback(connectionStatusChanged, withTag: "NetworkTableViewController")
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
        ipLabel.text = Settings.Network.ip
        portLabel.text = "\(Settings.Network.port)"
    }
    
    func connectionStatusChanged(status: ConnectionManager.ConnectionStatus, message: String? = nil) {
        var connectionStatusLabelText = ""
        var connectLabelText = ""
        switch status {
        case .Connecting:
            connectionStatusLabelText = "Connecting..."
            connectLabelText = "Disconnect"
        case .Connected:
            connectionStatusLabelText = "Connected"
            connectLabelText = "Disconnect"
        case .Disconnected:
            connectionStatusLabelText = "Disconnected"
            connectLabelText = "Connect"
        }
        
        UIView.transitionWithView(connectionStatusLabel, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak label = self.connectionStatusLabel] in label!.text = connectionStatusLabelText },
            completion: nil)
        
        UIView.transitionWithView(connectLabel, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak label = self.connectLabel] in label!.text = connectLabelText },
            completion: nil)
        
        let state: Bool = status == .Disconnected
        for i in 0...1 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.userInteractionEnabled = state
            cell?.textLabel?.enabled = state
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

            switch ConnectionManager.connectionState {
            case .Disconnected:
                ConnectionManager.connect()
            case .Connected, .Connecting:
                ConnectionManager.disconnect()
            }
        }
    }
}
