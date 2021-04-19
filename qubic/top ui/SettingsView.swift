//
//  SettingsView.swift
//  qubic
//
//  Created by 4 on 7/30/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var layout = Layout.main
    var mainButtonAction: () -> Void
    @State var selected = [0, UserDefaults.standard.integer(forKey: Key.arrowSide), UserDefaults.standard.integer(forKey: Key.notification)]
    @State var username = UserDefaults.standard.string(forKey: Key.name) ?? "me"
    @State var showNotificationAlert = false
//    @State var lineSize = lineWidth
    
    let pickerContent: [[Any]] = [[cubeImage(0)], [("left", false), ("right", false)], [("on", false), ("off", false)]]
//    static let boardStyleContent = [["spaces","blanks","cubes","spheres","points"].map { ($0, false) }]
    
    static func cubeImage(_ color: Int) -> () -> UIView {
        {
            let image = UIImage(named: "blueCube")
            let view = UIImageView(image: image)
            view.frame.size.height = 27
            view.frame.size.width = 27
            view.transform = CGAffineTransform(rotationAngle: .pi/2)
            
            return view
        }
    }
    
    var body: some View {
        ZStack {
            if layout.view == .settings {
                // HPickers
                VStack(spacing: 0) {
                    Fill(77)
                    HPicker(content: .constant(pickerContent), dim: (50,55), selected: $selected, action: onSelection)
                        .frame(height: 165)
                        .onAppear {
                            Notifications.ifDenied {
                                selected[2] = 1
                                UserDefaults.standard.setValue(1, forKey: Key.notification)
                            }
                        }
//                    Fill(102)
//                    HPicker(content: .constant(SettingsView.boardStyleContent),
//                            dim: (80,30), selected: $style, action: setDots)
//                        .frame(height: 40)
                    Spacer()
    //                Text("\(lineSize)")
    //                Slider(value: $lineSize, in: 0.005...0.020, onEditingChanged: { _ in lineWidth = lineSize })
                }
                // mask
//                VStack(spacing: 0) {
//                    Fill(77)
//                    Blank(400)
//                    Fill(30)
//                    Blank(40)
//                    Fill(100)
//                    Spacer()
//                }
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
                if layout.view == .settings {
                    VStack(spacing: 0) {
                        Fill(10)
                        Text("notifications").frame(height: 20)
                        Blank(40)
                        Text("arrow side").frame(height: 20)
                        Blank(40)
                        Text("color").frame(height: 20)
                        Blank(40)
                        Text("username").frame(height: 20)
                        Fill(7)
                        TextField("enter name", text: $username, onCommit: {
                            UserDefaults.standard.setValue(username, forKey: Key.name)
                            FB.main.updateMyData()
                        })
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .accentColor(.primary(0)) // TODO make this your color
                            .frame(width: 200, height: 43, alignment: .top)
                    }.zIndex(3)
                }
                Spacer()
            }
            .alert(isPresented: $showNotificationAlert, content: { Notifications.notificationAlert })
        }
        .background(Fill())
    }
    
//    func setDots(row: Int, component: Int) -> Void {
//        UserDefaults.standard.setValue(row, forKey: Key.dot)
//    }
    
    func onSelection(row: Int, component: Int) -> Void {
        if component == 2 {
            if row == 0 {
                Notifications.turnOn(callBack: notificationsAllowed)
            } else {
                Notifications.turnOff()
            }
        } else if component == 1 {
            UserDefaults.standard.setValue(row, forKey: Key.arrowSide)
            layout.leftArrows = row == 0
        } else {
            // color stuff
        }
    }
    
    func notificationsAllowed(success: Bool) {
        if !success {
            selected[2] = 1
            showNotificationAlert = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView() {}
    }
}
