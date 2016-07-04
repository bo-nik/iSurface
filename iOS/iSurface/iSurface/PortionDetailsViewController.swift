//
//  PortionDetailsViewController.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class PortionDetailsViewController: UITableViewController, UITextFieldDelegate {
    
    var portion: Portion!
    
    private var pointSelectionView: UIView!
    
    @IBOutlet weak var portionNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        portionNameTextField.text = portion.name
        portionNameTextField.delegate = self
        
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        
//        let controlsHeight = UIApplication.sharedApplication().statusBarFrame.size.height +
//            (navigationController?.navigationBar.frame.size.height ?? 0) +
//            (tabBarController?.tabBar.frame.size.height ?? 0)
        
        let controlsHeight = (navigationController?.navigationBar.frame.size.height ?? 0) +
            (tabBarController?.tabBar.frame.size.height ?? 0) + 20
        
        let otherSectionsHeight = tableView.rectForSection(0).size.height + tableView.rectForSection(2).size.height
        
        let pointSelectionViewHeight = tableView.frame.height - controlsHeight -
            otherSectionsHeight - tableView.rectForSection(0).origin.y * CGFloat(2)
        let pointSelectionViewWidth = tableView.frame.size.width
        
        pointSelectionView = UIView(frame: CGRect(x: 0, y: 0,
            width: pointSelectionViewWidth, height: pointSelectionViewHeight))
        pointSelectionView.backgroundColor = UIColor.clearColor()
        
        let rows = portion.degree.n + 1
        let columns = portion.degree.m + 1
        
        let spaceBetweenPoints =
            min(pointSelectionViewHeight / CGFloat(rows + 1), pointSelectionViewWidth / CGFloat(columns + 1))
        
        let pointSize = CGSize(width: 40, height: 40)
        let defaultXPosition = spaceBetweenPoints - pointSize.width / 2 +
            (pointSelectionViewWidth - spaceBetweenPoints * CGFloat(columns + 1)) / 2
        let defaultYPosition = spaceBetweenPoints - pointSize.height / 2 +
            (pointSelectionViewHeight - spaceBetweenPoints * CGFloat(rows + 1)) / 2
        var pointPosition = CGPoint(x: defaultXPosition, y: defaultYPosition)
        
        for i in 0..<rows {
            for j in 0..<columns {
                let button = UIButton(type: .System)
                button.addTarget(self, action: "pointTapped:", forControlEvents: .TouchUpInside)
                button.frame = CGRect(origin: pointPosition, size: pointSize)
                button.setTitle("⦿", forState: .Normal)
                button.titleLabel!.font = UIFont.systemFontOfSize(18)
                button.tag = i * columns + j
                pointSelectionView.addSubview(button)
                pointPosition.x += spaceBetweenPoints
            }
            pointPosition.x -= spaceBetweenPoints * CGFloat(columns)
            pointPosition.y += spaceBetweenPoints
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        RemoteController.setEditingState(true, portionId: portion.id)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let trimmedPortionName = portionNameTextField.text?.trim()
        if let name = trimmedPortionName where !name.isEmpty {
            portion.name = name
        }
    }
    

    func pointTapped(sender: UIButton) {
        performSegueWithIdentifier("editPointSegue", sender: sender)
    }
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return pointSelectionView
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return pointSelectionView?.frame.size.height ?? UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editPointSegue" {
            if let dvc = segue.destinationViewController as? EditPointViewController {
                if let button = sender as? UIButton  {
                    let row = button.tag / (portion.degree.m + 1)
                    let column = button.tag % (portion.degree.m + 1)
                    dvc.point = portion.anchorPoints[row][column]
                }
            }
        } else if segue.identifier == "editPortionOriginSegue" {
            if let dvc = segue.destinationViewController as? EditPointViewController {
                var initialAnchorPoints: [[Point]] = []
                for i in 0...portion.degree.n {
                    initialAnchorPoints += [[]]
                    for j in 0...portion.degree.m {
                        initialAnchorPoints[i] += [Point(portion.anchorPoints[i][j])]
                    }
                }
                let origin = Point()
                origin.valueChangedCallback = { [weak portion = self.portion] in
                    
                    
                    // TODO: Move to portion class
                    Settings.Temp.enablePointObserver = false
                    for i in 0...portion!.degree.n {
                        for j in 0...portion!.degree.m {
                            portion!.anchorPoints[i][j].x = initialAnchorPoints[i][j].x + origin.x
                            portion!.anchorPoints[i][j].y = initialAnchorPoints[i][j].y + origin.y
                            portion!.anchorPoints[i][j].z = initialAnchorPoints[i][j].z + origin.z
                        }
                    }
                    Settings.Temp.enablePointObserver = true
                    
                    var ignoredOuterPoints: Set<Point> = []
                    for i in 0...portion!.degree.n {
                        for j in 0...portion!.degree.m {
                            ignoredOuterPoints.insert(portion!.anchorPoints[i][j])
                        }
                    }
                    
                    // Edge points
                    for i in 0...portion!.degree.n {
                        for j in 0...portion!.degree.m {
                            if i == 0 || i == portion!.degree.n ||
                                j == 0 || j == portion?.degree.m {
                                    Settings.currentSurface.applyConstraintToPoint(portion!.anchorPoints[i][j], ignorePoints: &ignoredOuterPoints)
                            }
                        }
                    }
                    
                    RemoteController.updateAllAnchorPoints(Settings.currentSurface)
                    //
                }
                dvc.point = origin
                dvc.navigationItem.title = "Move portion"
            }
        }
    }
}
