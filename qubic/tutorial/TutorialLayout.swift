//
//  TutorialLayout.swift
//  qubic
//
//  Created by Chris McElroy on 11/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

enum TutorialState: Int {
	case blank, welcome, tictactoe
}

class TutorialLayout: ObservableObject {
	static var main = TutorialLayout()
	
	@Published var current: TutorialState = .welcome
	var readyToContinue: Bool = false
	
	func advance() {
		readyToContinue = false
		let next = TutorialState(rawValue: current.rawValue + 1) ?? .welcome
		withAnimation { current = .blank }
		Timer.after(0.3) { withAnimation { self.current = next } }
	}
	
	func skip() {
		readyToContinue = false
		let next: TutorialState = [
			.welcome: .tictactoe,
			.tictactoe: .blank
		][current] ?? .welcome
		withAnimation { current = .blank }
		Timer.after(0.3) { withAnimation { self.current = next } }
	}
	
	func exitTutorial() {
		withAnimation {
			Layout.main.current = Storage.int(.playedTutorial) > 1 ? .tutorialMenu : .main
		}
	}
}
