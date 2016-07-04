//
//  AboutTableViewController.swift
//  iSurface
//
//  Created by Borys Pedos on 28.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
    }
}
