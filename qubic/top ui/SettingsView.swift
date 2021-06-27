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
    @State var selected1 = [UserDefaults.standard.integer(forKey: Key.arrowSide), UserDefaults.standard.integer(forKey: Key.premoves), UserDefaults.standard.integer(forKey: Key.notification)]
    @State var selected2 = [UserDefaults.standard.integer(forKey: Key.color)]
    @State var username = UserDefaults.standard.string(forKey: Key.name) ?? "me"
    @State var showNotificationAlert = false
//    @State var lineSize = lineWidth
    
    let picker1Content: [[Any]] = [[("left", false), ("right", false)], [("on", false), ("off", false)],  [("on", false), ("off", false)]]
    let picker2Content: [[Any]] = [cubeImages()]
//    static let boardStyleContent = [["spaces","blanks","cubes","spheres","points"].map { ($0, false) }]
    let notificationComp = 2
    let premovesComp = 1
    let arrowSideComp = 0
    let colorComp = 0
    
    static func cubeImages() -> [() -> UIView] {
        ["orangeCube", "redCube", "pinkCube", "purpleCube", "blueCube", "cyanCube", "limeCube", "greenCube", "goldCube"].map { name in
            {
                let image = UIImage(named: name)
                let view = UIImageView(image: image)
                view.frame.size.height = 27
                view.frame.size.width = 27
                view.transform = CGAffineTransform(rotationAngle: .pi/2)
                
                return view
            }
        }
    }
    
    var body: some View {
        ZStack {
            if layout.current == .settings {
                // HPickers
                VStack(spacing: 0) {
                    Fill(70)
                    HPicker(content: .constant(picker1Content), dim: (50,65), selected: $selected1, action: onSelection1)
                        .frame(height: 195)
                        .onAppear {
                            selected1[notificationComp] = UserDefaults.standard.integer(forKey: Key.notification)
                            Notifications.ifDenied {
                                selected1[notificationComp] = 1
                                UserDefaults.standard.setValue(1, forKey: Key.notification)
                            }
                        }
                    Fill(12)
                    HPicker(content: .constant(picker2Content), dim: (50,65), selected: $selected2, action: onSelection2)
                        .frame(height: 65)
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
                if layout.current == .settings {
                    VStack(spacing: 0) {
                        Fill(10)
                        VStack(spacing: 0) {
                            Text("notifications").frame(height: 20)
                            Blank(50)
                            Text("premoves").frame(height: 20)
                            Blank(50)
                            Text("arrow side").frame(height: 20)
                            Blank(50)
                            Text("color").frame(height: 20)
                            Blank(50)
                        }
                        Text("username").frame(height: 20)
                        Fill(7)
                        TextField("enter name", text: $username, onCommit: {
                            UserDefaults.standard.setValue(username, forKey: Key.name)
                            FB.main.updateMyData()
                        })
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .accentColor(.primary())
                            .frame(width: 200, height: 43, alignment: .top)
                    }.zIndex(3)
                }
                Spacer()
            }
            .alert(isPresented: $showNotificationAlert, content: { Notifications.notificationAlert })
        }
        .background(Fill().onTapGesture {
            hideKeyboard()
            if username != UserDefaults.standard.string(forKey: Key.name) {
                UserDefaults.standard.setValue(username, forKey: Key.name)
                FB.main.updateMyData()
            }
        })
    }
    
//    func setDots(row: Int, component: Int) -> Void {
//        UserDefaults.standard.setValue(row, forKey: Key.dot)
//    }
    
    func onSelection1(row: Int, component: Int) -> Void {
        if component == notificationComp {
            if row == 0 {
                Notifications.turnOn(callBack: notificationsAllowed)
            } else {
                Notifications.turnOff()
            }
        } else if component == premovesComp {
            UserDefaults.standard.setValue(row, forKey: Key.premoves)
        } else if component == arrowSideComp {
            UserDefaults.standard.setValue(row, forKey: Key.arrowSide)
            layout.leftArrows = row == 0
        }
    }
    
    func onSelection2(row: Int, component: Int) -> Void {
        if component == colorComp {
            UserDefaults.standard.setValue(row, forKey: Key.color)
            FB.main.updateMyData()
        }
    }
    
    func notificationsAllowed(success: Bool) {
        if !success {
            selected1[notificationComp] = 1
            showNotificationAlert = true
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView() {}
    }
}
