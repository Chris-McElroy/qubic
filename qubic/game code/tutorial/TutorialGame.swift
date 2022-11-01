//
//  TutorialGame.swift
//  qubic
//
//  Created by Chris McElroy on 4/5/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

class TutorialGame: Game {	
	func load() {
		gameState = .new
		self.mode = mode
		board = Board()
		BoardScene.main.reset()
		gameNum += 1
		GameLayout.main.loadGameOpacities()
		reviewingGame = false
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
		setupNum = 0
		preset = []
		solved = false
		myTurn = 0
		hints = true
		let name = Storage.string(.name) == "new player" ? "your name" : Storage.string(.name) ?? "your name"
		let me = TutorialPlayer(b: board, n: 0, name: name, color: Storage.int(.color))
		let op = TutorialPlayer(b: board, n: 1, name: "opponent", color: 6)

		player = [me, op]
		let futureMoves = [42, 63, 51, 12, 22, 62, 25]
		for p in futureMoves { loadFutureMove(p) }
		GameLayout.main.refreshHints()
		GameLayout.main.animateIntro()
	}
	
	func loadFutureMove(_ p: Int) {
		// Assumes no wins and an empty board
		let move = Move(p)
		guard !moves.contains(move) && (0..<64).contains(move.p) else { return }
		moves.append(move)
		currentMove = move // TODO i think i can get rid of this??
		getHints(for: moves, loading: true)
		
		movesBack += 1
		currentMove = nil
	}
	
	override func checkAndProcessMove(_ p: Int, for turn: Int, setup: [Int], time: Double? = nil) {
		let move = Move(p)
		if processingMove { return }
		guard gameState == .active else { return }
		guard turn == realTurn else { print("Invalid turn!"); return }
		guard setup == moves.map({ $0.p }) else { print("Invalid setup!"); return }
		guard !moves.contains(move) && (0..<64).contains(move.p) else { print("Invalid move!"); return }
		guard movesBack == 0 else { return }
		processingMove = true
		board.addMove(p)
		moveImpactGenerator.impactOccurred()
		BoardScene.main.showMove(p, color: player[turn].color, wins: board.getWinLines(for: move.p))
		
		if board.hasW2(myTurn^1, depth: 6, time: 1.0, valid: { true }) == false {
			confirmMove()
		} else {
			cancelMove()
		}
		
		func confirmMove() {
			moves.append(move)
			getHints(for: moves, time: time)
			currentMove = move
			GameLayout.main.refreshHints()
			processingMove = false
			GameLayout.main.newMoveOpacities()
			
			Timer.after(0.3) {
				self.endGame(with: .opResign)
			}
		}
		
		func cancelMove() {
			timers.append(Timer.after(0.3) {
				self.lastCheck = self.board.numMoves()
				self.board.undoMove(for: turn)
				BoardScene.main.undoMove(move.p)
				self.notificationGenerator.notificationOccurred(.error)
				self.premoves = []
				BoardScene.main.spinMoves()
				self.player[0].cancelMove()
				self.player[1].cancelMove()
				self.processingMove = false
			})
		}
	}
	
	override func undoMove() {
		if PracticeGameController.main.step == .undo {
			super.undoMove()
			PracticeGameController.main.step = .swipe3
			GameLayout.main.setPopups(to: .settings)
		}
	}
	
	override func prevMove() {
		super.prevMove()
		if PracticeGameController.main.step == .block && movesBack == 1 {
			PracticeGameController.main.nextAction()
		}
	}
	
	override func nextMove() {
		if GameLayout.main.popup == .settings && PracticeGameController.main.step == .adv1 {
			GameLayout.main.setPopups(to: .none)
		}
		super.nextMove()
		if PracticeGameController.main.step == .adv1 && movesBack == 0 {
			PracticeGameController.main.nextAction()
		}
		if PracticeGameController.main.step == .adv2 && movesBack == 0 {
			PracticeGameController.main.step = .undo
		}
	}
}
