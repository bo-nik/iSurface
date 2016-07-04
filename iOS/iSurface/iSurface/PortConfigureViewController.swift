//
//  PortConfigureViewController.swift
//  iSurface
//
//  Created by iKing on 22.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class PortConfigureViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var initialPort: UInt16!
    
    private var componentsWidth: CGFloat = 0.0
    private var strechingComponentsWidth: CGFloat = 0.0
    private let componentsWidthPercentage: CGFloat = 1 / 12
    private let strechingComponentsWidthPercentage: CGFloat = 1 / 7

    @IBOutlet weak var portPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portPicker.dataSource = self
        portPicker.delegate = self

        initialPort = Settings.Network.port
        
        resetPort()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let newPort =
            portPicker.selectedRowInComponent(1) * 10000 +
            portPicker.selectedRowInComponent(2) * 1000 +
            portPicker.selectedRowInComponent(3) * 100 +
            portPicker.selectedRowInComponent(4) * 10 +
            portPicker.selectedRowInComponent(5)
        Settings.Network.port = UInt16(min(newPort, 65535))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        componentsWidth = portPicker.frame.size.width * componentsWidthPercentage
        strechingComponentsWidth = portPicker.frame.size.width * strechingComponentsWidthPercentage
    }
    
    @IBAction func resetPort(sender: UIBarButtonItem) {
        resetPort()
    }
    
    func resetPort() {
        var number = Int(initialPort)
        portPicker.selectRow(number / 10000, inComponent: 1, animated: true)
        number = number % 10000
        portPicker.selectRow(number / 1000, inComponent: 2, animated: true)
        number = number % 1000
        portPicker.selectRow(number / 100, inComponent: 3, animated: true)
        number = number % 100
        portPicker.selectRow(number / 10, inComponent: 4, animated: true)
        number = number % 10
        portPicker.selectRow(number, inComponent: 5, animated: true)
    }
    
    // MARK: - Picker view data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 7
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 || component == 6 {
            return 0
        }
        return 10
    }
    
    // MARK: - Picker view delegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 || component == 6 {
            return strechingComponentsWidth
        }
        return componentsWidth
    }
}
