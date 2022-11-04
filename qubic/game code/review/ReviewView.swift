//
//  ReviewView.swift
//  qubic
//
//  Created by Chris McElroy on 6/30/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct ReviewView: View {
	@ObservedObject var game: Game = Game.main
	@ObservedObject var gameLayout: GameLayout = GameLayout.main
	@ObservedObject var layout: Layout = Layout.main
	
	let components = GameViewComponents.self
	
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
