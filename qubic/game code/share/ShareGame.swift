//
//  ShareGame.swift
//  qubic
//
//  Created by Chris McElroy on 9/17/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

class ShareGame: Game {
	func load(from game: FB.GameData, opData: FB.PlayerData, movesIn: Int?) {
		print("loading", game, opData.name, movesIn)
		Game.main = self
		gameState = game.state
		mode = game.mode
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
		if let total = totalTime {
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
		let op = User(b: board, n: myTurn^1, name: opData.name)
		op.color = opData.color
		player = myTurn == 0 ? [me, op] : [op, me]
		let allMoves = game.orderedMoves()
		for p in allMoves.first(movesIn ?? allMoves.count) { loadMove(p) }
		for p in allMoves.dropFirst(movesIn ?? allMoves.count) { loadFutureMove(p) }
		GameLayout.main.refreshHints()
	}
	
	override func loadMove(_ p: Int) {
		super.loadMove(p)
		if let wins = board.getWinLines(for: p) {
			BoardScene.main.showWins(wins, color: player[turn^1].color, spin: false)
		}
	}
	
	func loadFutureMove(_ p: Int) {
		let move = Move(p)
		guard !moves.contains(move) && (0..<64).contains(move.p) else { return }
		moves.append(move)
		getHints(for: moves, loading: true)
		movesBack += 1
	}
	
	override func startGame() {
		moveImpactGenerator.prepare()
		GameLayout.main.startGameOpacities()
	}
}
