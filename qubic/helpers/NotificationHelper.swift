//
//  NotificationHelper.swift
//  qubic
//
//  Created by 4 on 12/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct Notifications {
    static func ifAllowed(_ run: @escaping () -> Void) {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus == .authorized {
                run()
            }
        })
    }
    
    static func ifUndetermined(_ run: @escaping () -> Void) {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus == .notDetermined {
                run()
            }
        })
    }
    
    static func ifDenied(_ run: @escaping () -> Void) {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus == .denied {
                run()
            }
        })
    }
    
    static func turnOn(callBack: @escaping (Bool) -> Void = {_ in }) {
        UserDefaults.standard.setValue(0, forKey: notificationKey)
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { success, error in
            if let error = error { print(error.localizedDescription) }
            UserDefaults.standard.setValue(success ? 0 : 1, forKey: notificationKey)
            callBack(success)
        }
    }
    
    static func turnOff() {
        UserDefaults.standard.setValue(1, forKey: notificationKey)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [badgeKey])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [badgeKey])
    }
    
    static func setBadge(justSolved: Bool, dayInt: Int = Date().getInt()) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [badgeKey])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [badgeKey])
        var streak = UserDefaults.standard.integer(forKey: streakKey)
        var lastDC = UserDefaults.standard.integer(forKey: lastDCKey)
        if lastDC < dayInt - 1 { streak = 0 }
        if justSolved {
            UserDefaults.standard.setValue(dayInt, forKey: lastDCKey)
            streak += lastDC < dayInt ? 1 : 0
            lastDC = dayInt
        }
        UserDefaults.standard.setValue(streak, forKey: streakKey)
        if UserDefaults.standard.integer(forKey: notificationKey) == 0 {
            UIApplication.shared.applicationIconBadgeNumber = lastDC == Date().getInt() ? 0 : 1
            let content = UNMutableNotificationContent()
            content.badge = 1
            var tomorrow = DateComponents()
            tomorrow.hour = 0
            tomorrow.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrow, repeats: false)
            let request = UNNotificationRequest(identifier: badgeKey, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
