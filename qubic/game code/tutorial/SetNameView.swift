//
//  SetNameView.swift
//  qubic
//
//  Created by Chris McElroy on 2/10/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

struct SetNameView: View {
	@ObservedObject var layout = TutorialLayout.main
	@State var continueOpacity: Opacity = .half
	@State var username: String = ""
	@State var color = Storage.int(.color)
	
	var body: some View {
		VStack(spacing: 0) {
			Blank(40)
			VStack(spacing: 5) {
				Text("username").modifier(Oligopoly(size: 18))
				Text("Choose your displayed name. It can include spaces, emojis, and other unicode characters, and it does not need to be unique.")
					.padding(.horizontal, 10)
				TextField("enter name", text: $username, onEditingChanged: { starting in
					if !starting && username != Storage.string(.name) {
						Storage.set(username, for: .name)
						FB.main.updateMyData()
						continueOpacity = .full
					}
				})
					.disableAutocorrection(true)
					.keyboardType(.alphabet) // stops predictive text/text suggestions
					.accentColor(.primary())
					.frame(width: 200, height: 20)
				Spacer()
			}
			.frame(height: 170)
			VStack(spacing: 5) {
				Text("color / app icon").modifier(Oligopoly(size: 18))
				Text("Choose the color for your moves, name, app menus, and app icon.")
					.padding(.horizontal, 10)
				HPicker(width: 60, height: 40, scaling: 0.675, selection: $color, labels: SettingsView.cubeImages(), onSelection: setColor)
				Spacer()
			}
			.frame(height: 150)
			Blank(30)
			Button("continue") { if continueOpacity == .full { layout.exitTutorial() } }
				.opacity(continueOpacity.rawValue)
				.buttonStyle(Standard())
			Spacer()
		}
		.multilineTextAlignment(.center)
	}
	
	func setColor(to v: Int) {
		Storage.set(v, for: .color)
		FB.main.updateMyData()
		let newIcon = ["orange", "red", "pink", "purple", nil, "cyan", "lime", "green", "gold"][v]
		if UIApplication.shared.alternateIconName != newIcon {
			UIApplication.shared.setAlternateIconName(newIcon)
		}
	}
}
