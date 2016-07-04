//
//  HomeViewController.swift
//  iSurface
//
//  Created by iKing on 25.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var rotationGestureRecognizer: UIRotationGestureRecognizer!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    @IBOutlet weak var gesturesPlaceholderLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var calibrateButton: UIButton!
    @IBOutlet weak var connectionSetupButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinchGestureRecognizer.delegate = self
        rotationGestureRecognizer.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ConnectionManager.addCallback(connectionStatusChanged, withTag: "HomeViewController")
        connectionStatusChanged(ConnectionManager.connectionState)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ConnectionManager.removeCallbackWithTag("HomeViewController")
    }
    
    @IBAction func panGestureRecognizerHandler(sender: UIPanGestureRecognizer) {
        if sender.state == .Changed {
            let translation = sender.translationInView(view)
            let dx = Double(translation.x) * 0.15
            let dy = Double(-translation.y) * 0.15
            Settings.Temp.permanentTanslation.x += dx
            Settings.Temp.permanentTanslation.y += dy
            sender.setTranslation(CGPointZero, inView: view)
        }
    }
    
    @IBAction func pinchGestureRecognizerHandler(sender: UIPinchGestureRecognizer) {
        if sender.state == .Changed {
            let dz = -Double(sender.scale - 1) * 20
            Settings.Temp.permanentTanslation.z += dz
            sender.scale = 1
        }
    }
    
    @IBAction func rotationGestureRecognizerHandler(sender: UIRotationGestureRecognizer) {
        if sender.state == .Changed {
            let rad2deg = 180.0 / M_PI
            Settings.Temp.permanentRotation.y += Double(sender.rotation * 1.2) * rad2deg
            sender.rotation = 0
        }
    }
    
    @IBAction func longPressGestureRecognizerHandler(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            Settings.Temp.permanentRotation = (0.0, 0.0, 0.0)
            Settings.Temp.permanentTanslation = (0.0, 0.0, 0.0)
        }
    }
    
    @IBAction func calibrate(sender: UIButton) {
        MotionManager.prepareForCalibration()
    }
    
    @IBAction func connect(sender: UIButton) {
        ConnectionManager.connect()
    }
    
    private(set) var gestureRecogniziresEnabled: Bool = false {
        didSet {
            pinchGestureRecognizer.enabled = gestureRecogniziresEnabled
            panGestureRecognizer.enabled = gestureRecogniziresEnabled
            rotationGestureRecognizer.enabled = gestureRecogniziresEnabled
            longPressGestureRecognizer.enabled = gestureRecogniziresEnabled
        }
    }
    
    func connectionStatusChanged(status: ConnectionManager.ConnectionStatus, message: String? = nil) {
        var connectionStatusLabelHidden = false
        var connectButtonEnable = false
        var connectionStatusLabelText = ""
        var detailsLabelText = ""
        switch status {
        case .Connecting:
            connectionStatusLabelText = "Connecting..."
            detailsLabelText = "\(Settings.Network.ip):\(Settings.Network.port)"
            connectionStatusLabelHidden = false
            connectButtonEnable = false
            gestureRecogniziresEnabled = false
        case .Connected:
            connectionStatusLabelText = "Connected"
            detailsLabelText = "Long press to to reset"
            connectionStatusLabelHidden = true
            connectButtonEnable = false
            gestureRecogniziresEnabled = true
        case .Disconnected:
            connectionStatusLabelText = "Disconnected"
            detailsLabelText = "Tap to connect (\(Settings.Network.ip):\(Settings.Network.port))"
            connectionStatusLabelHidden = false
            connectButtonEnable = true
            gestureRecogniziresEnabled = false
        }
        
        connectButton.userInteractionEnabled = connectButtonEnable
        
        UIView.transitionWithView(connectionStatusLabel, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak label = self.connectionStatusLabel] in
                label?.text = connectionStatusLabelText
                label?.hidden = connectionStatusLabelHidden
            },
            completion: nil)
        
        UIView.transitionWithView(detailsLabel, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak label = self.detailsLabel] in
                label?.text = detailsLabelText
            },
            completion: nil)
        
        UIView.transitionWithView(gesturesPlaceholderLabel, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak label = self.gesturesPlaceholderLabel] in
                label?.hidden = !connectionStatusLabelHidden
            },
            completion: nil)
        
        UIView.transitionWithView(connectionSetupButton, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak button = self.connectionSetupButton] in
                button?.hidden = connectionStatusLabelHidden
            },
            completion: nil)
        
        UIView.transitionWithView(calibrateButton, duration: 0.2,
            options: .TransitionCrossDissolve,
            animations: { [weak button = self.calibrateButton] in
                button?.hidden = !connectionStatusLabelHidden
            },
            completion: nil)
    }
    
    // MARK: - Gesture recognizer delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
