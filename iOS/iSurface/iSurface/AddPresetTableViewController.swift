//
//  AddPresetTableViewController.swift
//  iSurface
//
//  Created by iKing on 24.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class AddPresetTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var presetNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presetNameTextField.delegate = self
        
        presetNameTextField.text = Settings.currentSurface.name
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        presetNameTextField.becomeFirstResponder()
        presetNameTextField.selectAll(nil)
    }
    
    func addPreset() {
        presetNameTextField.resignFirstResponder()
        
        func goBackAndAddPresetWithName(name: String, replace: Bool = false) {
            Settings.currentSurface.name = name
            Settings.Presets.add(Settings.currentSurface)
            
            if let navigationController = navigationController {
                let vcCount = navigationController.viewControllers.count
                if vcCount > 1 {
                    if let vc = navigationController.viewControllers[vcCount - 2] as? PresetsTableViewController {
                        vc.addedPresetName = name
                    }
                }
                navigationController.popViewControllerAnimated(true)
            }
        }
        
        if let name = presetNameTextField.text?.trim() where !name.isEmpty {
            if Settings.Presets.list().contains(name) {
                let alert = UIAlertController(title: "Preset already exists",
                    message: "Preset with such name already exists. Replace it?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {
                    [weak textField = self.presetNameTextField] _ in
                    textField!.becomeFirstResponder()
                }))
                alert.addAction(UIAlertAction(title: "Replace", style: .Destructive, handler: { _ in
                    goBackAndAddPresetWithName(name, replace: true)
                }))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                goBackAndAddPresetWithName(name)
            }
        } else {
            let alert = UIAlertController(title: "Unable to svae preset",
                message: "Preset name cannot be empty. Provide a valid name to save preset.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
                [weak textField = self.presetNameTextField] _ in
                textField!.becomeFirstResponder()
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addPreset(sender: UIBarButtonItem) {
        addPreset()
    }
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addPreset()
        return false
    }
}
