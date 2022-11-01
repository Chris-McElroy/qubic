//
//  ShareView.swift
//  qubic
//
//  Created by Chris McElroy on 9/17/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct ShareView: View {
	@ObservedObject var game: Game = ReviewGame.main
	@ObservedObject var gameLayout: GameLayout = GameLayout.main
	@ObservedObject var layout: Layout = Layout.main
	
	let components = GameViewComponents.self
	
	// TODO change this to be like actually specific in any way
	
	var body: some View {
		ZStack {
			components.boardView
			components.popupFill
			components.optionsPopup
			components.gameEndPopup
			components.analysisPopup
			components.settingsPopup
			components.deepLinkPopup
			components.popupMasks
			components.names
			components.gameControls
		}
		.opacity(gameLayout.hideAll ? 0 : 1)
		.gesture(components.swipe)
		.modifier(BoundSize(min: .large, max: .extraExtraExtraLarge))
	}
}
