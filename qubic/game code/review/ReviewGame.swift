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
		mostRecentGame = (mode, game.setupNum, nil, game.hints, game.totalTime) // recording turn as nil so it's not always the same
		
		myTurn = game.myTurn
		gameID = game.gameID
		board = Board()
		BoardScene.main.reset()
		gameNum += 1
		GameLayout.main.loadGameOpacities()
		reviewingGame = true
		processingMove = false
		lastCheck = 0
		currentMove = nil
		moves = []
		totalTime = game.totalTime
		if totalTime != nil {
			times = game.getTimes()
			currentTimes = [Int(times[0].last ?? 0), Int(times[1].last ?? 0)]
//			lastStart = [0,0]
		}
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
		setupNum = game.setupNum
		preset = Array(game.orderedMoves().first(game.presetCount))
		solved = game.mode.solve ? game.hints : false
		hints = game.mode.solve ? game.hints : true
		
		let me = User(b: board, n: myTurn)
		let op = User(b: board, n: myTurn^1, id: opData.id, name: opData.name)
		op.color = opData.color
		player = myTurn == 0 ? [me, op] : [op, me]
		for p in game.orderedMoves() { loadMove(p) }
		GameLayout.main.refreshHints()
		GameLayout.main.animateIntro()
	}
	
	override func loadMove(_ p: Int) {
		super.loadMove(p)
		if let wins = board.getWinLines(for: p) {
			BoardScene.main.showWins(wins, color: player[turn^1].color, spin: false)
		}
	}
	
	override func startGame() {
		moveImpactGenerator.prepare()
		GameLayout.main.startGameOpacities()
	}
}
