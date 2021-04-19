//
//  NotificationHelper.swift
//  qubic
//
//  Created by 4 on 12/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct Notifications {
    static let notificationAlert = Alert(title: Text("Notifications Disabled"),
                                  message: Text("Notifications must be enabled in your phone’s settings before you can turn them on in-app."),
                                  primaryButton: .default(Text("Settings"), action: { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }),
                                  secondaryButton: .cancel())
    
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
        UserDefaults.standard.setValue(0, forKey: Key.notification)
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { success, error in
            if let error = error { print(error.localizedDescription) }
            UserDefaults.standard.setValue(success ? 0 : 1, forKey: Key.notification)
            callBack(success)
            DispatchQueue.main.async {
                setBadge(justSolved: false)
            }
        }
    }
    
    static func turnOff() {
        UserDefaults.standard.setValue(1, forKey: Key.notification)
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [Key.badge])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Key.badge])
    }
    
    static func setBadge(justSolved: Bool, dayInt: Int = Date().getInt()) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [Key.badge])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Key.badge])
        var streak = UserDefaults.standard.integer(forKey: Key.streak)
        var lastDC = UserDefaults.standard.integer(forKey: Key.lastDC)
        if lastDC < dayInt - 1 { streak = 0 }
        if justSolved {
            UserDefaults.standard.setValue(dayInt, forKey: Key.lastDC)
            streak += lastDC < dayInt ? 1 : 0
            lastDC = dayInt
        }
        UserDefaults.standard.setValue(streak, forKey: Key.streak)
        if UserDefaults.standard.integer(forKey: Key.notification) == 0 {
            UIApplication.shared.applicationIconBadgeNumber = lastDC == Date().getInt() ? 0 : 1
            let content = UNMutableNotificationContent()
            content.badge = 1
            var tomorrow = DateComponents()
            tomorrow.hour = 0
            tomorrow.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrow, repeats: false)
            let request = UNNotificationRequest(identifier: Key.badge, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
