//
//  TutorialPlayer.swift
//  qubic
//
//  Created by Chris McElroy on 1/28/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

class TutorialPlayer: Player {
	init(b: Board, n: Int, name: String, color: Int) {
		super.init(b: b, n: n, name: name, color: color)
	}
	
	override func move() {}
	
	func move(at p: Int) {
		if TutorialGame.tutorialMain.reviewingGame {
			TutorialGame.tutorialMain.processGhostMove(p)
		} else if TutorialGame.tutorialMain.gameState == .active {
			TutorialGame.tutorialMain.checkAndProcessMove(p, for: n, setup: b.getSetup())
		}
	}
}
