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
	@State var confirmMoves = Storage.int(.confirmMoves)
	@State var premoves = Storage.int(.premoves)
	@State var moveChecker = Storage.int(.moveChecker)
	@State var arrowSide = Storage.int(.arrowSide)
	@State var notification = Storage.int(.notification)
	@State var color = Storage.int(.color)
    @State var username = Storage.string(.name) ?? "me"
    @State var showNotificationAlert = false
	@State var beatCubist = false
	@State var showInfo: Bool = false
	@State var infoFor: Int = 0
//    @State var lineSize = lineWidth
	
	let info: [[String]] = [
		["confirm moves", "Tap once to select a move and a second time to confirm it. Tap any other move to cancel. Incompatible with premoves."],
		["premoves", "Intended for advanced players. Tap moves during your opponent’s move to preselect them. As soon as it’s your turn, these moves are made automatically in the order you tapped, unless you have a 3 in a row open elsewhere. You can premove checkmates by preselecting both possible wins. Incompatible with confirm moves."],
		["move checker", "Unlocks when you have beaten cubist in challenge mode. If analysis is enabled, once per turn the move checker verifies that your move didn’t miss any immediate wins for either player. If you did miss something, the move is automatically undone and you have the opportunity to try again (or check the analysis to see what you missed). In \"checks\" mode this works for first order wins and checks. In \"all\" mode this works for second order wins and checks as well (this occasionally takes some time)."],
		["arrow side", "Controls which side the previous and next arrows appear on in game. Setting this to the same side you hold your device from can make usage easier."],
		["notifications", "Displays a badge on the app icon for qubic whenever there are daily puzzles you haven’t solved yet."],
		["color / app icon", "Sets the color for your moves, name, app menus, and app icon."],
		["username", "Sets your displayed name. It can include spaces, emojis, and other unicode characters, and it does not need to be unique."]
	]
	
	func setConfirmMoves(to v: Int) {
		confirmMoves = v
		Storage.set(v, for: .confirmMoves)
		if v == 0 {
			setPremoves(to: 1)
		}
	}
	
	func setPremoves(to v: Int) {
		premoves = v
		Storage.set(v, for: .premoves)
		if v == 0 {
			setConfirmMoves(to: 1)
		}
	}
	
	func setMoveChecker(to v: Int) {
		if beatCubist {
			moveChecker = v
			Storage.set(v, for: .moveChecker)
		}
	}
	
	func setArrowSide(to v: Int) {
		layout.leftArrows = v == 0
		arrowSide = v
		Storage.set(v, for: .arrowSide)
	}
	
	func setNotifications(to v: Int) {
		if v == 0 {
			Notifications.turnOn(callBack: notificationsAllowed)
		} else {
			Notifications.turnOff()
		}
		notification = v
		Storage.set(v, for: .notification)
	}
	
	func setColor(to v: Int) {
		let newIcon = ["orange", "red", "pink", "purple", nil, "cyan", "lime", "green", "gold"][v]
		if UIApplication.shared.alternateIconName != newIcon {
			UIApplication.shared.setAlternateIconName(newIcon)
		}
		color = v
		Storage.set(v, for: .color)
		FB.main.updateMyData()
	}
    
    static func cubeImages() -> [Any] {
        ["orangeCube", "redCube", "pinkCube", "purpleCube", "blueCube", "cyanCube", "limeCube", "greenCube", "goldCube"].map { name in Image(name) }
    }
    
    var body: some View {
        ZStack {
            if layout.current == .settings {
                VStack(spacing: 0) {
					Fill(73)
						.onAppear {
							updateSelections()
							TipStatus.main.updateTip(for: .settings)
						}
					VStack(spacing: 0) {
						getSettingTitle(name: "confirm moves", number: 0)
						HPicker(width: 60, height: 40, selection: $confirmMoves, labels: ["on", "off"], onSelection: setConfirmMoves)
						getSettingTitle(name: "premoves", number: 1)
						HPicker(width: 60, height: 40, selection: $premoves, labels: ["on", "off"], onSelection: setPremoves)
						getSettingTitle(name: "move checker", number: 2)
						if beatCubist {
							HPicker(width: 60, height: 40, selection: $moveChecker, labels: ["all", "checks", "off"], onSelection: setMoveChecker)
						} else {
							Text("beat cubist in challenge mode to unlock!")
								.foregroundColor(.secondary)
								.frame(width: layout.width, height: 40)
								.background(Fill())
								.environment(\.sizeCategory, .large)
						}
						getSettingTitle(name: "arrow side", number: 3)
						HPicker(width: 60, height: 40, selection: $arrowSide, labels: ["left", "right"], onSelection: setArrowSide)
					}
					VStack(spacing: 0) {
						getSettingTitle(name: "notifications", number: 4)
						HPicker(width: 60, height: 40, selection: $notification, labels: ["on", "off"], onSelection: setNotifications)
						getSettingTitle(name: "color / app icon", number: 5)
						HPicker(width: 60, height: 40, scaling: 0.675, selection: $color, labels: SettingsView.cubeImages(), onSelection: setColor)
//							.frame(width: 200)
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
                    Spacer()
    //                Text("\(lineSize)")
    //                Slider(value: $lineSize, in: 0.005...0.020, onEditingChanged: { _ in lineWidth = lineSize })
                }
				.modifier(BoundSize(min: .medium, max: .extraLarge))
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
			VStack(spacing: 0) {
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
				.zIndex(10)
				Spacer()
			}
        }
		.buttonStyle(Solid())
		.background(Fill().onTapGesture { hideKeyboard() })
		.alert(isPresented: $showNotificationAlert, content: { Notifications.notificationAlert })
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
	
	func updateSelections() {
		confirmMoves = Storage.int(.confirmMoves)
		premoves = Storage.int(.premoves)
		moveChecker = Storage.int(.moveChecker)
		arrowSide = Storage.int(.arrowSide)
		notification = Storage.int(.notification)
		color = Storage.int(.color)
		if let trainArray = Storage.array(.train) as? [Int] {
			beatCubist = trainArray[5] == 1
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
