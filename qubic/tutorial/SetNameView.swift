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
	@State var selected = [Storage.int(.color)]
	
	let pickerContent: [[Any]] = [cubeImages()]
	
	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				Spacer()
				Blank(240)
				HPicker(content: .constant(pickerContent), dim: (60,55), selected: $selected, action: onSelection)
					.frame(height: 55)
				Spacer()
				Spacer()
			}
			VStack(spacing: 0) {
				Blank(40) // TODO this layout doesn't work on smallest
				VStack(spacing: 5) {
					Text("username").modifier(Oligopoly(size: 18))
					Text("Choose your displayed name. It can include spaces, emojis, and other unicode characters, and it does not need to be unique.")
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
				}
				Blank(40)
				VStack(spacing: 5) {
					Text("color / app icon").modifier(Oligopoly(size: 18))
					Text("Choose the color for your moves, name, app menus, and app icon.")
					Blank(55)
				}
				Blank(30)
				Button("continue") { if continueOpacity == .full { layout.exitTutorial() } }
					.opacity(continueOpacity.rawValue)
					.buttonStyle(Solid())
					.modifier(Oligopoly(size: 16))
				Spacer()
			}
		}
		.multilineTextAlignment(.center)
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
	
	func onSelection(row: Int, component: Int) {
		Storage.set(row, for: .color)
		FB.main.updateMyData()
		let newIcon = ["orange", "red", "pink", "purple", nil, "cyan", "lime", "green", "gold"][row]
		if UIApplication.shared.alternateIconName != newIcon {
			UIApplication.shared.setAlternateIconName(newIcon)
		}
	}
}
