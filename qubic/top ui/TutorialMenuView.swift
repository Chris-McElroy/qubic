//
//  TutorialMenuView.swift
//  qubic
//
//  Created by Chris McElroy on 10/18/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct TutorialMenuView: View {
	@ObservedObject var layout = Layout.main
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				Fill().frame(height: moreButtonHeight)
				Button("tutorial") {
					layout.change(to: .tutorialMenu)
				}
				.buttonStyle(MoreStyle())
			}
			.zIndex(4)
			if layout.current == .tutorialMenu {
				Blank(20)
				
				Button(action: {
					TutorialLayout.main.current = .tictactoe
					layout.change(to: .tutorial)
				}) {
					Text((Storage.int(.playedTutorial) > 0 ? "re" : "") + "play tutorial")
				}
				
				Blank(20)
				
				Button(action: {
					print("ending tips")
					// end tips
				}) {
					Text("turn off tips")
				}
				
				Blank(20)
				
				Button(action: {
					print("resetting tips!")
					// reset tips
				}) {
					Text("reset tips")
				}
			}
			Spacer()
		}
	}
}

