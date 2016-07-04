//
//  SurfaceDegreeViewController.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class SurfaceDegreeTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let pickerData = [["3", "4", "5", "6"], ["3", "4", "5", "6"]]
    
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        
        picker.selectRow(pickerData[0].indexOf("\(Settings.currentSurface.degree.n)") ?? 0,
            inComponent: 0, animated: false)
        picker.selectRow(pickerData[1].indexOf("\(Settings.currentSurface.degree.m)") ?? 0,
            inComponent: 1, animated: false)
        
        let controlsHeight = UIApplication.sharedApplication().statusBarFrame.size.height +
            (navigationController?.navigationBar.frame.size.height ?? 0) +
            (tabBarController?.tabBar.frame.size.height ?? 0)

        pickerContainerView.frame.size.height = tableView.frame.size.height -
            tableView.rectForFooterInSection(0).size.height -
            tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).size.height * 1.5 - controlsHeight
    }
    
    // MARK: - Picker view data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let newDegree = (
                n: Int(pickerData[0][picker.selectedRowInComponent(0)])!,
                m: Int(pickerData[1][picker.selectedRowInComponent(1)])!)
            let oldDegree = Settings.currentSurface.degree
            if newDegree.n != oldDegree.n || newDegree.m != oldDegree.m {
                let alert = UIAlertController(title: "Apply new degree?",
                    message: "You will lose your surface after changing its degree. Continue?",
                    preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Apply", style: .Destructive,
                    handler: { [weak navigationController = self.navigationController] _ in
                        Settings.currentSurface =
                            Surface(degree: newDegree, name: Settings.currentSurface.name)
                        navigationController?.popViewControllerAnimated(true)
                    }))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return pickerContainerView
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return pickerContainerView.frame.size.height
        }
        return UITableViewAutomaticDimension
    }
    
    
}
