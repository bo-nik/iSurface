//
//  IpConfigureViewController.swift
//  iSurface
//
//  Created by iKing on 22.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class IpConfigureViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var initialIP: String!

    private var componentsWidth: CGFloat = 0.0
    private var strechingComponentsWidth: CGFloat = 0.0
    private let componentsWidthPercentage: CGFloat = 1 / 6
    private let strechingComponentsWidthPercentage: CGFloat = 1 / 6
    
    private let dotLabelTag = 10
    
    @IBOutlet weak var ipPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ipPicker.dataSource = self
        ipPicker.delegate = self
        
        initialIP = Settings.Network.ip
        
        resetIP()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        Settings.Network.ip =
            "\(ipPicker.selectedRowInComponent(1))." +
            "\(ipPicker.selectedRowInComponent(2))." +
            "\(ipPicker.selectedRowInComponent(3))." +
            "\(ipPicker.selectedRowInComponent(4))"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pickerViewWidth = ipPicker.frame.size.width
        let pickerViewHeight = ipPicker.frame.size.height
        componentsWidth = pickerViewWidth * componentsWidthPercentage
        strechingComponentsWidth = pickerViewWidth * strechingComponentsWidthPercentage
        
        let dotLabelWidth = CGFloat(10)
        let dotLabelHeight = CGFloat(44)
        func createDotLabelForComponent(component: Int = 1) -> UILabel {
            var xPosition = pickerViewWidth / 2 - dotLabelWidth / 2
            switch component {
            case 1:
                xPosition -= componentsWidth + dotLabelWidth / 2
            case 3:
                xPosition += componentsWidth + dotLabelWidth / 2
            default:
                break
            }
            let dotLabel = UILabel(frame: CGRect(
                x: xPosition,
                y: (pickerViewHeight - dotLabelHeight) / 2,
                width: dotLabelWidth, height: dotLabelHeight))
            dotLabel.font = UIFont.systemFontOfSize(22)
            dotLabel.textAlignment = .Center
            dotLabel.text = "."
            dotLabel.tag = dotLabelTag
            return dotLabel
        }
        
        func removeDotsFromPickerView(pickerView: UIPickerView) {
            for subview in pickerView.subviews {
                if subview.tag == dotLabelTag {
                    subview.removeFromSuperview()
                }
            }
        }
        
        removeDotsFromPickerView(ipPicker)
        
        ipPicker.addSubview(createDotLabelForComponent(1))
        ipPicker.addSubview(createDotLabelForComponent(2))
        ipPicker.addSubview(createDotLabelForComponent(3))
    }
    
    @IBAction func resetIP(sender: UIBarButtonItem) {
        resetIP()
    }
    
    func resetIP() {
        var ipComponents = initialIP.characters.split(".").map({ Int(String($0)) ?? 0 })
        if ipComponents.count != 4 {
            ipComponents = [0, 0, 0, 0]
        }
        ipPicker.selectRow(ipComponents[0], inComponent: 1, animated: true)
        ipPicker.selectRow(ipComponents[1], inComponent: 2, animated: true)
        ipPicker.selectRow(ipComponents[2], inComponent: 3, animated: true)
        ipPicker.selectRow(ipComponents[3], inComponent: 4, animated: true)
    }

    // MARK: - Picker view data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 6
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 || component == 5 {
            return 0
        }
        return 256
    }
    
    // MARK: - Picker view delegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 || component == 5 {
            return strechingComponentsWidthPercentage
        }
        return componentsWidth
    }
}
