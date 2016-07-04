//
//  EditPointViewController.swift
//  iSurface
//
//  Created by iKing on 21.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class EditPointViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private var initialPoint: Point!
    private let valuesRange = Settings.Defaults.valuesRange
    private var widthForComponent: [CGFloat] = [0.0, 0.0, 0.0]
    private let widthPercentageForComponent: [CGFloat] = [0.55, 0.05, 0.4]
    
    @IBOutlet weak var xCoordinatePicker: UIPickerView!
    @IBOutlet weak var yCoordinatePicker: UIPickerView!
    @IBOutlet weak var zCoordinatePicker: UIPickerView!
    
    private let dotLabelTag = 10
    
    var point: Point!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        xCoordinatePicker.dataSource = self
        xCoordinatePicker.delegate = self
        yCoordinatePicker.dataSource = self
        yCoordinatePicker.delegate = self
        zCoordinatePicker.dataSource = self
        zCoordinatePicker.delegate = self
        
        initialPoint = Point(point)
        
        resetPoint()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let portion = point.portion {
            RemoteController.setEditingState(true, portionId: portion.id)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        point.x = valueInPickerView(xCoordinatePicker)
        point.y = valueInPickerView(yCoordinatePicker)
        point.z = valueInPickerView(zCoordinatePicker)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pickerViewWidth = xCoordinatePicker.frame.size.width
        let pickerViewHeight = xCoordinatePicker.frame.size.height
        widthForComponent[0] = pickerViewWidth * widthPercentageForComponent[0]
        widthForComponent[1] = pickerViewWidth * widthPercentageForComponent[1]
        widthForComponent[2] = pickerViewWidth * widthPercentageForComponent[2]
        
        let dotLabelWidth = widthForComponent[1]
        let dotLabelHeight = CGFloat(44)
        func createDotLabelForPickerWithColor(color: UIColor = UIColor.blackColor()) -> UILabel {
            let dotLabel = UILabel(frame: CGRect(
                x: widthForComponent[0] + widthForComponent[1] - dotLabelWidth / 4,
                y: (pickerViewHeight - dotLabelHeight) / 2,
                width: dotLabelWidth, height: dotLabelHeight))
            dotLabel.font = UIFont.systemFontOfSize(22)
            dotLabel.textColor = color
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
        
        removeDotsFromPickerView(xCoordinatePicker)
        removeDotsFromPickerView(yCoordinatePicker)
        removeDotsFromPickerView(zCoordinatePicker)
        
        xCoordinatePicker.addSubview(createDotLabelForPickerWithColor(xCoordinatePicker.tintColor))
        yCoordinatePicker.addSubview(createDotLabelForPickerWithColor(yCoordinatePicker.tintColor))
        zCoordinatePicker.addSubview(createDotLabelForPickerWithColor(zCoordinatePicker.tintColor))
    }

    @IBAction func resetPoint(sender: UIBarButtonItem) {
        resetPoint()
    }
    
    func resetPoint() {
        point.x = initialPoint.x
        point.y = initialPoint.y
        point.z = initialPoint.z
        
        xCoordinatePicker.selectRow(Int(initialPoint.x) + valuesRange.maxElement()!, inComponent: 0, animated: true)
        yCoordinatePicker.selectRow(Int(initialPoint.y) + valuesRange.maxElement()!, inComponent: 0, animated: true)
        zCoordinatePicker.selectRow(Int(initialPoint.z) + valuesRange.maxElement()!, inComponent: 0, animated: true)
        
        xCoordinatePicker.selectRow(Int(abs(initialPoint.x) % 1.0 * 10), inComponent: 2, animated: true)
        yCoordinatePicker.selectRow(Int(abs(initialPoint.y) % 1.0 * 10), inComponent: 2, animated: true)
        zCoordinatePicker.selectRow(Int(abs(initialPoint.z) % 1.0 * 10), inComponent: 2, animated: true)
    }
    
    private func valueInPickerView(pickerView: UIPickerView) -> Double {
        let integer = pickerView.selectedRowInComponent(0) - valuesRange.maxElement()!
        let fraction = Double(pickerView.selectedRowInComponent(2)) / 10.0
        return Double(integer) + (integer < 0 ? -fraction : fraction)
    }
    
    // MARK: - Picker view data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return valuesRange.count
        case 1:
            return 0
        case 2:
            return 10
        default:
            return 0
        }
    }
    
    // MARK: - Picker view delegate
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return widthForComponent[component]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case xCoordinatePicker:
            point.x = valueInPickerView(xCoordinatePicker)
        case yCoordinatePicker:
            point.y = valueInPickerView(yCoordinatePicker)
        case zCoordinatePicker:
            point.z = valueInPickerView(zCoordinatePicker)
        default:
            break
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(22)
        
        switch pickerView {
        case xCoordinatePicker:
            label.textColor = xCoordinatePicker.tintColor
        case yCoordinatePicker:
            label.textColor = yCoordinatePicker.tintColor
        case zCoordinatePicker:
            label.textColor = zCoordinatePicker.tintColor
        default:
            break
        }

        label.frame = CGRect(x: 0, y: 0, width: widthForComponent[component], height: 44)
        switch component {
        case 0:
            label.textAlignment = .Right
            label.text = "\(row - valuesRange.maxElement()!)"
        case 2:
            label.textAlignment = .Left
            label.text = "\(row)"
        default:
            break
        }
        return label
    }
}
