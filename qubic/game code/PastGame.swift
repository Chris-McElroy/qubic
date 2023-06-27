//
//  PastGame.swift
//  qubic
//
//  Created by Chris McElroy on 9/17/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

struct PastGameSetup {
	let gameData: GameData
	let myData: PlayerData
	let opData: PlayerData
	let movesIn: Int?
	
	init(gameData: GameData, myData: PlayerData, opData: PlayerData, movesIn: Int? = nil) {
		self.gameData = gameData
		self.myData = myData
		self.opData = opData
		self.movesIn = movesIn
	}
}

class PastGame: Game {
	func load(setup: PastGameSetup) {
		let allMoves = setup.gameData.orderedMoves()
		let movesIn = (setup.movesIn ?? allMoves.count) <= allMoves.count ? setup.movesIn ?? allMoves.count : allMoves.count
		Game.main.turnOff()
		Game.main = self
		gameState = setup.gameData.state
		mode = setup.gameData.mode
		gameSetup = GameSetup(mode: setup.gameData.mode, setupNum: setup.gameData.setupNum, turn: nil, hints: setup.gameData.hints, time: setup.gameData.totalTime, preset: nil) // recording turn as nil so it's not always the same in rematches
		
		myTurn = setup.gameData.myTurn
		gameID = setup.gameData.gameID
		board = Board()
		BoardScene.main.reset()
		gameNum += 1
		GameLayout.main.loadGameOpacities()
		reviewingGame = true
		processingMove = false
		lastCheck = 0
		currentMove = nil
		moves = []
		totalTime = setup.gameData.totalTime
		if totalTime != nil {
			times = setup.gameData.getTimes()
			currentTimes = [Int(times[0][(movesIn + 1)/2]), Int(times[1][movesIn/2])]
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
		setupNum = setup.gameData.setupNum
		preset = Array(allMoves.first(setup.gameData.presetCount))
		solved = setup.gameData.mode.solve ? setup.gameData.hints : false
		hints = setup.gameData.mode.solve ? setup.gameData.hints : true
		
		let me = User(b: board, n: myTurn, id: setup.myData.id, name: setup.myData.name)
		me.color = setup.myData.color
		let op = User(b: board, n: myTurn^1, id: setup.opData.id, name: setup.opData.name)
		op.color = setup.opData.color
		if me.color == op.color {
			op.color = [4, 4, 4, 8, 6, 7, 4, 5, 3][me.color]
		}
		player = myTurn == 0 ? [me, op] : [op, me]
		for p in allMoves.first(movesIn) { loadMove(p) }
		for p in allMoves.dropFirst(movesIn) { loadFutureMove(p) }
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
