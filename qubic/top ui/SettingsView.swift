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
	@State var selected1 = [Storage.int(.moveChecker), Storage.int(.premoves), Storage.int(.confirmMoves)]
	@State var selected2 = [Storage.int(.color), Storage.int(.notification), Storage.int(.arrowSide)]
    @State var username = Storage.string(.name) ?? "me"
    @State var showNotificationAlert = false
	@State var beatCubist = false
//    @State var lineSize = lineWidth
    
    let picker1Content: [[Any]] = [["all", "checks", "off"], ["on", "off"], ["on", "off"]]
    let picker2Content: [[Any]] = [cubeImages(), ["on", "off"], ["left", "right"]]
	
	var confirmMovesSetting: Int { selected1[2] }
	func setConfirmMoves(to v: Int) {
		selected1[2] = v
		Storage.set(v, for: .confirmMoves)
	}
	
	var premovesSetting: Int { selected1[1] }
	func setPremoves(to v: Int) {
		selected1[1] = v
		Storage.set(v, for: .premoves)
	}
	
	var moveCheckerSetting: Int { selected1[0] }
	func setMoveChecker(to v: Int) {
		selected1[0] = v
		Storage.set(v, for: .moveChecker)
	}
	
	var arrowSideSetting: Int { selected2[2] }
	func setArrowSide(to v: Int) {
		selected2[2] = v
		Storage.set(v, for: .arrowSide)
	}
	
	var notificationsSetting: Int { selected2[1] }
	func setNotifications(to v: Int) {
		selected2[1] = v
		Storage.set(v, for: .notification)
	}
	
	var colorSetting: Int { selected2[0] }
	func setColor(to v: Int) {
		selected2[0] = v
		Storage.set(v, for: .color)
	}
    
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
                    HPicker(content: .constant(picker1Content), dim: (60,55), selected: $selected1, action: onSelection1)
                        .frame(height: 165)
                        .onAppear {
							if let trainArray = Storage.array(.train) as? [Int] {
								beatCubist = trainArray[5] == 1
								setMoveChecker(to: Storage.int(.moveChecker)) // handles if they fucked it up
							}
                        }
                    Fill(16)
                    HPicker(content: .constant(picker2Content), dim: (60,55), selected: $selected2, action: onSelection2)
                        .frame(height: 165)
						.zIndex(-1)
						.onAppear {
							Notifications.ifDenied {
								setNotifications(to: 1)
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
                        ZStack {
                            Text("settings")
                            Circle().frame(width: 12, height: 12).foregroundColor(.primary()).offset(x: 53, y: 2)
                                .opacity(Layout.main.updateAvailable ? 1 : 0)
                        }
                    }
                    .buttonStyle(MoreStyle())
                }
                .zIndex(4)
                if layout.current == .settings {
                    VStack(spacing: 0) {
                        Fill(5)
                        VStack(spacing: 0) {
							Text("confirm moves").bold().frame(height: 20)
							Blank(40)
							Text("premoves").bold().frame(height: 20)
							Blank(40)
							Text("move checker").bold().frame(height: 20)
							if beatCubist {
								Blank(40)
							} else {
								Text("beat cubist in challenge mode to unlock!")
									.foregroundColor(.secondary)
									.frame(width: layout.width, height: 40)
									.background(Fill())
							}
						}
						VStack(spacing: 0) {
							Text("arrow side").bold().frame(height: 20)
                            Blank(40)
							Text("notifications").bold().frame(height: 20)
							Blank(40)
							Text("color / app icon").bold().frame(height: 20)
                            Blank(40)
						}
						Text("username").bold().frame(height: 20)
                        Fill(7)
                        TextField("enter name", text: $username, onEditingChanged: { starting in
                            if !starting && username != Storage.string(.name) {
                                Storage.set(username, for: .name)
                                FB.main.updateMyData()
                            }
                        })
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .accentColor(.primary())
                            .frame(width: 200, height: 20)
                        if Layout.main.updateAvailable {
							Blank(5)
                            Button("update available!") {
								let urlString = "itms-\(versionType == .appStore ? "apps" : "beta")://itunes.apple.com/app/1480301899"
								guard let url = URL(string: urlString) else { return }
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
							.frame(height: 20)
                        }
                    }.zIndex(3)
                }
                Spacer()
            }
            .alert(isPresented: $showNotificationAlert, content: { Notifications.notificationAlert })
        }
        .background(Fill().onTapGesture { hideKeyboard() })
    }
    
//    func setDots(row: Int, component: Int) -> Void {
//        Storage.set(row, for: .dot)
//    }
    
    func onSelection1(row: Int, component: Int) -> Void {
		if component == 2 {
			Storage.set(row, for: .confirmMoves)
			if row == 0 {
				setPremoves(to: 1)
			}
		} else if component == 1 {
			Storage.set(row, for: .premoves)
			if row == 0 {
				setConfirmMoves(to: 1)
			}
		} else if component == 0 {
			if beatCubist {
				Storage.set(row, for: .moveChecker)
			}
        }
    }
    
    func onSelection2(row: Int, component: Int) -> Void {
		if component == 2 {
			Storage.set(row, for: .arrowSide)
			layout.leftArrows = row == 0
		} else if component == 1 {
			if row == 0 {
				Notifications.turnOn(callBack: notificationsAllowed)
			} else {
				Notifications.turnOff()
			}
		} else if component == 0 {
            Storage.set(row, for: .color)
            FB.main.updateMyData()
			let newIcon = ["orange", "red", "pink", "purple", nil, "cyan", "lime", "green", "gold"][row]
			if UIApplication.shared.alternateIconName != newIcon {
				UIApplication.shared.setAlternateIconName(newIcon)
			}
        }
    }
    
    func notificationsAllowed(success: Bool) {
        guard success else {
            setNotifications(to: 1)
            showNotificationAlert = true
			return
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
