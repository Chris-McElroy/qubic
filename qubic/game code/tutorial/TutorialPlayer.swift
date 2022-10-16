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
		super.init(b: b, n: n, id: name, name: name, color: color)
	}
	
	override func move() {}
	
	func move(at p: Int) {
		if Game.main.reviewingGame {
			Game.main.processGhostMove(p)
		} else if Game.main.gameState == .active {
			Game.main.checkAndProcessMove(p, for: n, setup: b.getSetup())
		}
	}
}
