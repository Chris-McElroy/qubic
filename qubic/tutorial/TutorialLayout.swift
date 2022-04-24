//
//  TutorialLayout.swift
//  qubic
//
//  Created by Chris McElroy on 11/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

enum TutorialState: Int {
	case blank, welcome, tictactoe, practiceGame, setName
}

class TutorialLayout: ObservableObject {
	static var main = TutorialLayout()
	
	@Published var current: TutorialState = .welcome
	@Published var readyToContinue: Bool = false
	@Published var readyToAdvance: Bool = false
	var tttLinesTimers: [Timer] = []
	var tttTimers: [Timer] = []
	var next: () -> Void = {}
	
	func advance(to next: TutorialState, while still: TutorialState) {
		guard current == still else { return }
		withAnimation { current = .blank }
		Timer.after(0.3) { withAnimation { self.current = next } }
	}
	
	// not using this anywhere
//	func skip() {
//		readyToContinue = false
//		let next: TutorialState = [
//			.welcome: .tictactoe,
//			.tictactoe: .blank
//		][current] ?? .welcome
//		withAnimation { current = .blank }
//		Timer.after(0.3) { withAnimation { self.current = next } }
//	}
	
	func exitTutorial() {
		TutorialGame.tutorialMain.gameState = .off
		if Storage.string(.name) == "new player" && current != .setName {
			advance(to: .setName, while: current)
			return
		}
		withAnimation {
			Layout.main.current = Storage.int(.playedTutorial) > 1 ? .tutorialMenu : .main
		}
	}
	
	func resetTTTLinesTimers() {
		for timer in tttLinesTimers {
			timer.invalidate()
		}
		
		tttLinesTimers = []
	}
	
	func resetTTTTimers() {
		for timer in tttTimers {
			timer.invalidate()
		}
		
		tttTimers = []
	}
	
	func reset() {
		TutorialGame.tutorialMain.gameState = .off
		TutorialBoardScene.tutorialMain.reset()
		resetTTTLinesTimers()
	}
}
