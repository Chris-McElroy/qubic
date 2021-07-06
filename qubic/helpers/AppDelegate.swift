//
//  AppDelegate.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let defaultLastDC = 737764 // in de past
        UserDefaults.standard.register(defaults: [
            Key.streak.rawValue: 0,
            Key.lastDC.rawValue: defaultLastDC,
            Key.train.rawValue: [0,0,0,0,0,0,0],
            Key.lastTrainMenu.rawValue: [0,1,0],
            Key.lastPlayMenu.rawValue: [1,1,0,0],
            Key.simple.rawValue: [0],
            Key.common.rawValue: [0],
            Key.tricky.rawValue: [0],
            Key.name.rawValue: "new player",
            Key.color.rawValue: 4,
            Key.notification.rawValue: 1,
            Key.premoves.rawValue: 1,
            Key.arrowSide.rawValue: 1,
            Key.uuid.rawValue: "00000000000000000000000000000000"
        ])
        
        FirebaseApp.configure()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

