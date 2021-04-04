//
//  SettingsView.swift
//  qubic
//
//  Created by 4 on 7/30/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var view: ViewStates
    var mainButtonAction: () -> Void
    @State var style = [UserDefaults.standard.integer(forKey: Key.dot)]
    @State var notifications = [UserDefaults.standard.integer(forKey: Key.notification)]
    @State var username = UserDefaults.standard.string(forKey: Key.name) ?? "me"
    @State var showNotificationAlert = false
//    @State var lineSize = lineWidth
    
    static let notificationContent = [[("on", false),("off", false)]]
    static let boardStyleContent = [["spaces","blanks","cubes","spheres","points"].map { ($0, false) }]
    
    var body: some View {
        ZStack {
            if view == .settings {
                // HPickers
                VStack(spacing: 0) {
                    Fill(77)
                    HPicker(content: .constant(SettingsView.notificationContent),
                            dim: (50,30), selected: $notifications, action: setNotifications)
                        .frame(height: 40)
                        .onAppear { Notifications.ifDenied {
                            notifications = [1]
                            UserDefaults.standard.setValue(1, forKey: Key.notification)
                        }}
                    Fill(102)
                    HPicker(content: .constant(SettingsView.boardStyleContent),
                            dim: (80,30), selected: $style, action: setDots)
                        .frame(height: 40)
                    Spacer()
    //                Text("\(lineSize)")
    //                Slider(value: $lineSize, in: 0.005...0.020, onEditingChanged: { _ in lineWidth = lineSize })
                }
                // mask
                VStack(spacing: 0) {
                    Fill(77)
                    Blank(40)
                    Fill(103)
                    Blank(40)
                    Fill(100)
                    Spacer()
                }
            }
            // content
            VStack(spacing: 0) {
                ZStack {
                    Fill().frame(height: moreButtonHeight)
                    Button(action: mainButtonAction) {
                        Text("settings")
                    }
                    .buttonStyle(MoreStyle())
                }
                .zIndex(4)
                if view == .settings {
                    VStack(spacing: 0) {
                        Fill(10)
                        Text("notifications")
                        Blank(50)
                        Text("edit username")
                        Fill(7)
                        TextField("enter name", text: $username, onCommit: {
                            UserDefaults.standard.setValue(username, forKey: Key.name)
                            FB.main.updateMyData()
                        })
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .accentColor(.primary(0)) // TODO make this your color
                            .frame(width: 200, height: 43, alignment: .top)
                        Text("board style")
                    }.zIndex(3)
                }
                Spacer()
            }
            .alert(isPresented: $showNotificationAlert, content: { Notifications.notificationAlert })
        }
        .background(Fill())
    }
    
    func setDots(row: Int, component: Int) -> Void {
        UserDefaults.standard.setValue(row, forKey: Key.dot)
    }
    
    func setNotifications(row: Int, component: Int) -> Void {
        if row == 0 {
            Notifications.turnOn(callBack: notificationsAllowed)
        } else {
            Notifications.turnOff()
        }
    }
    
    func notificationsAllowed(success: Bool) {
        if !success {
            notifications = [1]
            showNotificationAlert = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(view: .constant(.settings)) {}
    }
}
