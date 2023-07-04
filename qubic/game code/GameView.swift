//
//  GameView.swift
//  qubic
//
//  Created by Chris McElroy on 8/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct GameView: View {
	@ObservedObject var gameLayout: GameLayout = GameLayout.main
	@ObservedObject var layout: Layout = Layout.main
	@State var forcedUpdate: Bool = false
	
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
		.alert(isPresented: $gameLayout.showDCAlert, content: { components.enableBadgesAlert })
		.alert(isPresented: $gameLayout.showCubistAlert, content: { components.cubistAlert })
		.modifier(BoundSize(min: .large, max: .extraExtraExtraLarge))
    }
}
