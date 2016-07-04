//
//  AddConstraintTableViewController.swift
//  iSurface
//
//  Created by iKing on 26.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class AddConstraintTableViewController: UITableViewController {
    
    var readOnly = false
    
    var constraintAddedCallback: ((Bool) -> ())? = nil
    
    private let portions = Settings.currentSurface.portions
    
    var smooth = true
    
    var selectedFirstPortionIndex: Int? = nil
    var selectedFirstPortionEdge: Portion.Edge? = nil
    var selectedSecondPortionIndex: Int? = nil
    var selectedSecondPortionEdge: Portion.Edge? = nil
    
    @IBOutlet weak var firstPortionNameLabel: UILabel!
    @IBOutlet weak var firstPortionColorLabel: UILabel!
    @IBOutlet weak var firstPortionEdgeColorsLabel: UILabel!
    @IBOutlet weak var secondPortionNameLabel: UILabel!
    @IBOutlet weak var secondPortionColorLabel: UILabel!
    @IBOutlet weak var secondPortionEdgeColorsLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private let defaultLabelsColor = UIColor(hex: 0x8E8E93)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        
        if readOnly {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if let index = selectedFirstPortionIndex {
            firstPortionNameLabel.text = portions[index].name
            firstPortionColorLabel.textColor = UIColor(hex: portions[index].color)
        }
        
        if let index = selectedSecondPortionIndex {
            secondPortionNameLabel.text = portions[index].name
            secondPortionColorLabel.textColor = UIColor(hex: portions[index].color)
        }
        
        func setColorsForLabel(label: UILabel, forEdge edge: Portion.Edge) {
            let mutableString = NSMutableAttributedString(string: "◉  ◉")
            var firstColor = UIColor.blackColor()
            var secondColor = UIColor.blackColor()
            let edgesCount = Portion.Edge.count
            if edge.rawValue % 2 == 0 {
                firstColor = UIColor(hex: Settings.Defaults.portionCornerColors[(edge.rawValue / 2) % (edgesCount / 2)])
                secondColor = UIColor(hex: Settings.Defaults.portionCornerColors[(edge.rawValue / 2 + 1) % (edgesCount / 2)])
            } else {
                firstColor = UIColor(hex: Settings.Defaults.portionCornerColors[(edge.rawValue / 2 + 1) % (edgesCount / 2)])
                secondColor = UIColor(hex: Settings.Defaults.portionCornerColors[(edge.rawValue / 2) % (edgesCount / 2)])
            }
            mutableString.addAttribute(NSForegroundColorAttributeName, value: firstColor, range: NSMakeRange(0, 1))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: secondColor, range: NSMakeRange(3, 1))
            label.attributedText = mutableString
        }
        
        if let edge = selectedFirstPortionEdge {
            setColorsForLabel(firstPortionEdgeColorsLabel, forEdge: edge)
        }
        
        if let edge = selectedSecondPortionEdge {
            setColorsForLabel(secondPortionEdgeColorsLabel, forEdge: edge)
        }
        
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))?.accessoryView =
            UIImageView(image: UIImage(named: (smooth ? "accessory-checkmark" : "accessory-x")))
        
        if readOnly {
            for section in 0...2 {
                for row in 0...1 {
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section))
                    cell?.selectionStyle = .None
                }
            }
        }
        
        let firstPortionId: Int? = selectedFirstPortionIndex == nil ? nil : portions[selectedFirstPortionIndex!].id
        let secondPortionId: Int? = selectedSecondPortionIndex == nil ? nil : portions[selectedSecondPortionIndex!].id
        
        RemoteController.setConstraintEditingState(true, firstPortionId: firstPortionId, secondPortionId: secondPortionId)
    }

    @IBAction func addConstraint(sender: UIBarButtonItem) {
        if selectedFirstPortionIndex == nil || selectedFirstPortionEdge == nil ||
            selectedSecondPortionIndex == nil || selectedSecondPortionEdge == nil {
                let alert = UIAlertController(title: "Unable to add constrain", message: "Setup all parameters.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                return
        }
        if addConstraint() {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func addConstraint() -> Bool {
        let constraint = Surface.Constraint(
            first: (selectedFirstPortionIndex!, selectedFirstPortionEdge!),
            second: (selectedSecondPortionIndex!, selectedSecondPortionEdge!),
            smooth: smooth)
        
        if Settings.currentSurface.constraints.contains({ $0 == constraint }) {
            let alert = UIAlertController(title: "Unable to add constrain", message: "Such constraint already exists.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return false
        }
        
        let degree = Settings.currentSurface.degree
        if degree.n != degree.m {
            var canAddConstraint = false
            switch constraint.first.edge {
            case .Left, .LeftInverted, .Right, .RightInverted:
                switch constraint.second.edge {
                case .Left, .LeftInverted, .Right, .RightInverted:
                    canAddConstraint = true
                case .Top, .TopInverted, .Bottom, .BottomInverted:
                    canAddConstraint = false
                }
            case .Top, .TopInverted, .Bottom, .BottomInverted:
                switch constraint.second.edge {
                case .Left, .LeftInverted, .Right, .RightInverted:
                    canAddConstraint = false
                case .Top, .TopInverted, .Bottom, .BottomInverted:
                    canAddConstraint = true
                }
            }
            if !canAddConstraint {
                let alert = UIAlertController(title: "Unable to add constrain", message: "Attempting to create constraint between edges with different amount of anchor points.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                return false
            }
        }
        
        Settings.currentSurface.constraints += [constraint]
        constraintAddedCallback?(true)
        return true
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !readOnly {
            switch indexPath.section {
            case 0, 1:
                if indexPath.row == 0 {
                    performSegueWithIdentifier("portionSelectionSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
                } else if indexPath.row == 1 {
                    performSegueWithIdentifier("edgeSelectionSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
                }
            case 2:
                smooth = !smooth
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))?.accessoryView =
                    UIImageView(image: UIImage(named: (smooth ? "accessory-checkmark.png" : "accessory-x.png")))
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "portionSelectionSegue" {
            if let dvc = segue.destinationViewController as? PortionSelectionTableViewController,
                cell = sender as? UITableViewCell {
                    if cell.tag == 0 {
                        dvc.currentSelectedPortionIndex = selectedFirstPortionIndex
                        dvc.alreadySelectedPortionIndex = selectedSecondPortionIndex
                        dvc.portionSelectedCallback = { [unowned self] index in
                            self.selectedFirstPortionIndex = index
                        }
                    } else if cell.tag == 1 {
                        dvc.currentSelectedPortionIndex = selectedSecondPortionIndex
                        dvc.alreadySelectedPortionIndex = selectedFirstPortionIndex
                        dvc.portionSelectedCallback = { [unowned self] index in
                            self.selectedSecondPortionIndex = index
                        }
                    }
                    
            }
        } else if segue.identifier == "edgeSelectionSegue" {
            if let dvc = segue.destinationViewController as? EdgeSelectionTableViewController,
                cell = sender as? UITableViewCell {
                    if cell.tag == 0 {
                        dvc.currentSelectedEdge = selectedFirstPortionEdge
                        dvc.edgeSelectedCallback = { [unowned self] edge in
                            self.selectedFirstPortionEdge = edge
                        }
                    } else if cell.tag == 1 {
                        dvc.currentSelectedEdge = selectedSecondPortionEdge
                        dvc.edgeSelectedCallback = { [unowned self] edge in
                            self.selectedSecondPortionEdge = edge
                        }
                    }
            }
        }
    }
}
