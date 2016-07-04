//
//  AppDelegate.swift
//  iSurface
//
//  Created by iKing on 19.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        ConnectionManager.addCallback({
            [weak window = self.window] status, reason in
                if status == .Disconnected && reason != nil {
                    let alert = UIAlertController(title: "Connection failed", message: reason, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                }
            }, withTag: "ConnectionLost")
        
        ConnectionManager.addCallback({ status, _ in
            if status == .Connected {
                RemoteController.setSurface(Settings.currentSurface)
            }
            }, withTag: "SendSurfaceAfterConnection")
        
        ConnectionManager.addCallback({ status, _ in
            if status == .Connected {
                RemoteController.setDefaults("skeleton-visibility", value: Settings.Appearance.skeletonVisibility.rawValue)
                RemoteController.setDefaults("default-colors", value: Settings.Defaults.globalColors)
                Settings.Temp.permanentRotation = (0.0, 0.0, 0.0)
                Settings.Temp.permanentTanslation = (0.0, 0.0, 0.0)
            }
            }, withTag: "SetDefaultsAfterConnection")
        
        ConnectionManager.addCallback({ status, _ in
            if status == .Connected {
                MotionManager.start()
            } else {
                MotionManager.stop()
            }
            }, withTag: "ToggleMotion")
        
        MotionManager.prepareForCalibrationCallback = { [weak window = self.window] in
            let alert = UIAlertController(title: "Calibrating...",
                message: "To calibrate your device place it like the surface on the screen and press 'OK'. It will set current device position as initial.",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Calibrate", style: .Default, handler: { _ in
                MotionManager.calibrate()
            }))
            window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
        
        Settings.load()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Settings.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Settings.save()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Settings.load()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
         Settings.save()
    }


}

