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
		solveBoard = 0
		preset = game.orderedMoves()
		solved = false
		hints = game.hints // TODO does this handle solve boards?? when is game.hints updated?
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

// TODO how are the preview moves being loaded?
// TODO change which person is highlighted
// TODO the arrows don't work?
// TODO the menu should not include settings when reviewing the game
// TODO why doesn't analyis appear
// TODO get rid of new online game and rematch game
// TODO do i want to add friending and rematch to the expand thing?
// TODO the preview board just doesn't show up when i exit?
