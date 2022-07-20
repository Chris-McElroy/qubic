//
//  ReviewGame.swift
//  qubic
//
//  Created by Chris McElroy on 6/30/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

class ReviewGame: Game {
	func load(from game: FB.GameData, opData: FB.PlayerData) {
		Game.main = self
		gameState = game.state
		mode = game.mode
		myTurn = game.myTurn
		board = Board()
		BoardScene.main.reset()
		gameNum += 1
		GameLayout.main.loadGameOpacities()
		reviewingGame = true
		processingMove = false
		lastCheck = 0
		currentMove = nil
		moves = []
		totalTime = nil
		movesBack = 0
		ghostMoveStart = 0
		ghostMoveCount = 0
		premoves = []
		GameLayout.main.showWinsFor = nil
		GameLayout.main.analysisMode = 2 // otherwise newHints keeps the old one
		GameLayout.main.analysisTurn = 1
		GameLayout.main.showAllHints = true
		GameLayout.main.popup = .none
		dayInt = Date.int
		lastDC = Storage.int(.lastDC)
		solveBoard = game.mode.solve ? (Int(opData.name.components(separatedBy: " ").last ?? "1") ?? 1) - 1 : 0
		preset = game.orderedMoves()
		solved = game.mode.solve ? game.state.myWin : false
		hints = game.mode.solve ? solved : true
		
		let me = User(b: board, n: myTurn)
		let op = User(b: board, n: myTurn^1, name: opData.name)
		op.color = opData.color
		player = myTurn == 0 ? [me, op] : [op, me]
		for p in preset { loadMove(p) }
		GameLayout.main.refreshHints()
	}
	
	override func loadMove(_ p: Int) {
		super.loadMove(p)
		if let wins = board.getWinLines(for: p) {
			BoardScene.main.showWins(wins, color: .of(n: player[turn^1].color), spin: false)
		}
	}
	
	override func startGame() {
		moveImpactGenerator.prepare()
		GameLayout.main.startGameOpacities()
	}
}

// TODO the arrows don't work? - done?
// TODO why doesn't analyis appear - done?
// TODO games with invalid game.orderedMoves crash when review is clicked
// TODO change solve game text for review games—"you can’t analyze solve boards until they are solved" stuff
