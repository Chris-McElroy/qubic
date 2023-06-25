//
//  AppDelegate.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UserDefaults.standard.register(defaults: [
			Key.train.rawValue: [0,0,0,0,0,0],
			Key.lastTrainMenu.rawValue: [0,1,0],
			Key.lastPlayMenu.rawValue: [1,1,2,0],
            Key.streak.rawValue: 0,
            Key.lastDC.rawValue: 0,
			Key.currentDaily.rawValue: 0,
			Key.dailyHistory.rawValue: [], // TODO do it like https://stackoverflow.com/questions/39489211/empty-collection-literal-requires-an-explicit-type-error-on-swift3
            Key.daily.rawValue: [],
            Key.simple.rawValue: [],
            Key.common.rawValue: [],
            Key.tricky.rawValue: [],
			Key.solveBoardsVersion.rawValue: 0,
            Key.name.rawValue: "new player",
            Key.color.rawValue: 4,
            Key.notification.rawValue: 1,
            Key.premoves.rawValue: 1,
            Key.arrowSide.rawValue: 1,
			Key.moveChecker.rawValue: 2,
			Key.confirmMoves.rawValue: 1,
            Key.uuid.rawValue: "00000000000000000000000000000000",
			Key.playedTutorial.rawValue: 0,
			Key.tipsShown.rawValue: [0, 0, 0, 0, 0, 0],
			Key.tipsOn.rawValue: 1,
			Key.myBotSkill.rawValue: 5
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

