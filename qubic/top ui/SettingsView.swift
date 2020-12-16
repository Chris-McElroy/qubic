//
//  SettingsView.swift
//  qubic
//
//  Created by 4 on 7/30/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var mainButtonAction: () -> Void
    @State var style = [UserDefaults.standard.integer(forKey: dotKey)]
    @State var notifications = [UserDefaults.standard.integer(forKey: notificationKey)]
    @State var username = UserDefaults.standard.string(forKey: usernameKey) ?? "me"
    @State var showNotificationAlert = false
    @State var notificationChecker: (Int,Timer?) = (0,nil)
//    @State var lineSize = lineWidth
    
    static let notificationContent = [[("on", false),("off", false)]]
    static let boardStyleContent = [["spaces","blanks","cubes","spheres","points"].map { ($0, false) }]
    
    var body: some View {
        ZStack {
            // HPickers
            VStack(spacing: 0) {
                Fill(75)
                HPicker(use: .notifications, content: SettingsView.notificationContent,
                        dim: (50,30), selected: $notifications, action: setNotifications)
                    .frame(height: 40)
                    .onAppear { Notifications.ifDenied {
                        notifications = [1]
                        UserDefaults.standard.setValue(1, forKey: notificationKey)
                    }}
                Fill(102)
                HPicker(use: .boardStyle, content: SettingsView.boardStyleContent,
                        dim: (80,30), selected: $style, action: setDots)
                    .frame(height: 40)
                Spacer()
//                Text("\(lineSize)")
//                Slider(value: $lineSize, in: 0.005...0.020, onEditingChanged: { _ in lineWidth = lineSize })
            }
            // mask
            VStack(spacing: 0) {
                Fill(75)
                Blank(40)
                Fill(103)
                Blank(40)
                Fill(100)
                Spacer()
            }
            // content
            VStack(spacing: 0) {
                Button(action: mainButtonAction) {
                    Text("settings")
                }
                .buttonStyle(MoreStyle())
                Fill(10)
                Text("notifications")
                Blank(50)
                Text("edit username")
                Fill(7)
                TextField("enter name", text: $username, onCommit: {
                    UserDefaults.standard.setValue(username, forKey: usernameKey)
                })
                    .multilineTextAlignment(.center)
                    .disableAutocorrection(true)
                    .accentColor(.primary(0)) // TODO make this your color
                    .frame(width: 200, height: 43, alignment: .top)
                Text("board style")
                Spacer()
            }
            .alert(isPresented: $showNotificationAlert, content: { notificationAlert })
        }
        .background(Fill())
    }
    
    func setDots(row: Int, component: Int) -> Void {
        UserDefaults.standard.setValue(row, forKey: dotKey)
    }
    
    func setNotifications(row: Int, component: Int) -> Void {
        if row == 0 {
            Notifications.turnOn()
            notificationChecker = (0, Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                notificationChecker.0 += 1
                Notifications.ifDenied {
                    notifications = [1]
                    showNotificationAlert = true
                    notificationChecker.1?.invalidate()
                }
                Notifications.ifAllowed {
                    notificationChecker.1?.invalidate()
                }
                if notificationChecker.0 > 120 {
                    notificationChecker.1?.invalidate()
                }
            }))
        }
        else {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [badgeKey])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [badgeKey])
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView() {}
    }
}
