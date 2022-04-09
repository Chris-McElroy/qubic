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
	@State var selected1 = [Storage.int(.moveChecker), Storage.int(.premoves), Storage.int(.confirmMoves)]
	@State var selected2 = [Storage.int(.color), Storage.int(.notification), Storage.int(.arrowSide)]
    @State var username = Storage.string(.name) ?? "me"
    @State var showNotificationAlert = false
	@State var beatCubist = false
	@State var showInfo: Bool = false
	@State var infoFor: Int = 0
//    @State var lineSize = lineWidth
    
    let picker1Content: [[Any]] = [["all", "checks", "off"], ["on", "off"], ["on", "off"]]
    let picker2Content: [[Any]] = [cubeImages(), ["on", "off"], ["left", "right"]]
	
	let info: [[String]] = [
		["confirm moves", "Tap once to select a move and a second time to confirm it. Tap any other move to cancel. Incompatible with premoves."],
		["premoves", "Intended for advanced players. Tap moves during your opponent’s move to preselect them. As soon as it’s your turn, these moves are made automatically in the order you tapped, unless you have a 3 in a row open elsewhere. You can premove checkmates by preselecting both possible wins. Incompatible with confirm moves."],
		["move checker", "Unlocks when you have beaten cubist in challenge mode. If analysis is enabled, once per turn the move checker verifies that your move didn’t miss any immediate wins for either player. If you did miss something, the move is automatically undone and you have the opportunity to try again (or check the analysis to see what you missed). In \"checks\" mode this works for first order wins and checks. In \"all\" mode this works for second order wins and checks as well (this occasionally takes some time)."],
		["arrow side", "Controls which side the previous and next arrows appear on in game. Setting this to the same side you hold your device from can make usage easier."],
		["notifications", "Displays a badge on the app icon for qubic whenever there are daily puzzles you haven’t solved yet."],
		["color / app icon", "Sets the color for your moves, name, app menus, and app icon."],
		["username", "Sets your displayed name. It can include spaces, emojis, and other unicode characters, and it does not need to be unique."]
	]
	
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
                    Fill(73)
                    HPicker(content: .constant(picker1Content), dim: (60,55), selected: $selected1, action: onSelection1)
                        .frame(height: 165)
                        .onAppear {
							updateSelections()
                        }
						.onAppear { TipStatus.main.updateTip(for: .settings) }
                    Fill(15)
                    HPicker(content: .constant(picker2Content), dim: (60,55), selected: $selected2, action: onSelection2)
                        .frame(height: 165)
						.zIndex(-1)
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
                    Fill()
                    Button(action: {
						layout.change(to: .settings)
					}) {
                        ZStack {
                            Text("settings")
                            Circle().frame(width: 12, height: 12).foregroundColor(.primary()).offset(x: 53, y: 2)
                                .opacity(Layout.main.updateAvailable ? 1 : 0)
                        }
                    }
                    .buttonStyle(MoreStyle())
                }
				.frame(height: moreButtonHeight)
                .zIndex(4)
                if layout.current == .settings {
                    VStack(spacing: 0) {
                        Fill(5)
                        VStack(spacing: 0) {
							getSettingTitle(name: "confirm moves", number: 0)
							Blank(40)
							getSettingTitle(name: "premoves", number: 1)
							Blank(40)
							getSettingTitle(name: "move checker", number: 2)
							if beatCubist {
								Blank(40)
							} else {
								Text("beat cubist in challenge mode to unlock!")
									.foregroundColor(.secondary)
									.frame(width: layout.width, height: 40)
									.background(Fill())
									.environment(\.sizeCategory, .large)
							}
						}
						VStack(spacing: 0) {
							getSettingTitle(name: "arrow side", number: 3)
							Blank(40)
							getSettingTitle(name: "notifications", number: 4)
							Blank(40)
							getSettingTitle(name: "color / app icon", number: 5)
							Blank(40)
						}
						getSettingTitle(name: "username", number: 6)
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
							.buttonStyle(DefaultButtonStyle())
							.frame(height: 20)
                        }
                    }
					.zIndex(3)
					.modifier(BoundSize(min: .medium, max: .extraLarge))
                }
                Spacer()
            }
            .alert(isPresented: $showNotificationAlert, content: { Notifications.notificationAlert })
			if layout.current == .settings {
				VStack(spacing: 0) {
					Fill().opacity(showInfo ? 0.015 : 0).onTapGesture { withAnimation { showInfo = false } }
					VStack(spacing: 0) {
						Text(info[infoFor][0]).bold()
							.modifier(BoundSize(min: .medium, max: .extraLarge))
						Blank(4)
//						ScrollView(.vertical, showsIndicators: false) {
						Text(info[infoFor][1])
							.environment(\.sizeCategory, .large)
					}
					.multilineTextAlignment(.center)
					.padding(.horizontal, 25)
					.padding(.top, 15)
					.frame(width: layout.width)
					.fixedSize() // means that other views can't resize it, its spacers get priority
					.background(Fill().frame(width: Layout.main.width + 100).shadow(radius: 20))
					.offset(y: showInfo ? 0 : 500)
					.onDisappear {
						showInfo = false
					}
				}
			}
        }
		.buttonStyle(Solid())
        .background(Fill().onTapGesture { hideKeyboard() })
    }
    
//    func setDots(row: Int, component: Int) -> Void {
//        Storage.set(row, for: .dot)
//    }
    
	func getSettingTitle(name: String, number: Int) -> some View {
		Button(action: {
			infoFor = number
			withAnimation { showInfo = true }
		}, label: {
			HStack(spacing: 6) {
				Text("ⓘ").opacity(0)
				Text(name).bold()
				Text("ⓘ")
			}
			.frame(height: 20)
			.padding(.horizontal, 40)
			.background(Fill())
		})
	}
	
    func onSelection1(row: Int, component: Int) {
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
    
    func onSelection2(row: Int, component: Int) {
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
	
	func updateSelections() {
		selected1 = [Storage.int(.moveChecker), Storage.int(.premoves), Storage.int(.confirmMoves)]
		selected2 = [Storage.int(.color), Storage.int(.notification), Storage.int(.arrowSide)]
		if let trainArray = Storage.array(.train) as? [Int] {
			beatCubist = trainArray[5] == 1
			selected1[0] = Storage.int(.moveChecker) // handles if they fucked it up
		}
		Notifications.ifDenied {
			setNotifications(to: 1)
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
        SettingsView()
    }
}
