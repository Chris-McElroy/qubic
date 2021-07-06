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
        Storage.set(0, for: .notification)
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { success, error in
            if let error = error { print(error.localizedDescription) }
            Storage.set(success ? 0 : 1, for: .notification)
            callBack(success)
            DispatchQueue.main.async {
                setBadge(justSolved: false)
            }
        }
    }
    
    static func turnOff() {
        Storage.set(1, for: .notification)
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [Key.badge.rawValue])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Key.badge.rawValue])
    }
    
    static func setBadge(justSolved: Bool, dayInt: Int = Date().getInt()) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [Key.badge.rawValue])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Key.badge.rawValue])
        var streak = Storage.int(.streak)
        var lastDC = Storage.int(.lastDC)
        if lastDC < dayInt - 1 { streak = 0 }
        if justSolved {
            Storage.set(dayInt, for: .lastDC)
            streak += lastDC < dayInt ? 1 : 0
            lastDC = dayInt
        }
        Storage.set(streak, for: .streak)
        if Storage.int(.notification) == 0 {
            UIApplication.shared.applicationIconBadgeNumber = lastDC == Date().getInt() ? 0 : 1
            let content = UNMutableNotificationContent()
            content.badge = 1
            var tomorrow = DateComponents()
            tomorrow.hour = 0
            tomorrow.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrow, repeats: false)
            let request = UNNotificationRequest(identifier: Key.badge.rawValue, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
