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
	@ObservedObject var tipStatus = TipStatus.main
	
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
					Storage.set(TipStatus.main.tipsOn ? 0 : 1, for: .tipsOn)
					TipStatus.main.tipsOn.toggle()
				}) {
					Text("turn \(tipStatus.tipsOn ? "off" : "on") tips")
				}
				
				Blank(20)
				
				Button(action: {
					Storage.set([0,0,0,0, 0,0], for: .tipsShown)
					TipStatus.main.updateRemainingTips()
				}) {
					Text("reset tips")
				}
			}
			Spacer()
		}
	}
}

