//
//  GameLayout.swift
//  qubic
//
//  Created by Chris McElroy on 10/17/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

enum GamePopup {
	case none, analysis, options, gameEnd, gameEndPending, settings
	
	var up: Bool {
		!(self == .none || self == .gameEndPending)
	}
}

class GameLayout: ObservableObject {
	static let main = GameLayout()
	var game = Game.main
	
	@Published var undoOpacity: Opacity = .clear
	@Published var prevOpacity: Opacity = .clear
	@Published var nextOpacity: Opacity = .clear
	@Published var optionsOpacity: Opacity = .clear
	
	@Published var popup: GamePopup = .none
	@Published var delayPopups: Bool = true
	@Published var showWinsFor: Int? = nil
	@Published var showAllHints: Bool = true
	
	@Published var hideAll: Bool = true
	@Published var hideBoard: Bool = true
	@Published var centerNames: Bool = true
	
	@Published var showDCAlert: Bool = false
	@Published var showCubistAlert: Bool = false
	
	@Published var analysisMode = 2
	@Published var analysisTurn = 1
	@Published var currentSolveType: SolveType? = nil
	@Published var currentPriority: Int = 0
	@Published var beatCubist = false
	@Published var confirmMoves = Storage.int(.confirmMoves)
	@Published var premoves = Storage.int(.premoves)
	@Published var moveChecker = Storage.int(.moveChecker)
	@Published var arrowSide = Storage.int(.arrowSide)
	
	var currentHintMoves: Set<Int>? {
		guard let winsFor = showWinsFor else { return nil }
		guard let currentMove = game.currentMove else {
			if winsFor == 1 { return nil }
			return Set(Board.positionDict[[0,0]]?.1 ?? [])
		}
		return showAllHints ? currentMove.allMoves[winsFor] : currentMove.bestMoves[winsFor]
	}
	
	func animateIntro(for game: Game) {
		self.game = game
		hideAll = true
		hideBoard = true
		centerNames = true
		showWinsFor = nil
		analysisMode = 2
		analysisTurn = 1
		updateSettings()
		
//        BoardScene.main.rotate(right: true) // this created a race condition
		game.timers.append(Timer.after(0.1) {
			withAnimation {
				self.hideAll = false
			}
		})
		
		game.timers.append(Timer.after(1) {
			withAnimation {
				self.centerNames = false
			}
		})
		
		game.timers.append(Timer.after(1.1) {
			withAnimation {
				self.hideBoard = false
			}
			BoardScene.main.rotate(right: false)
		})
		
		game.timers.append(Timer.after(1.5) {
			self.game.startGame()
		})
	}
	
	func animateGameChange(rematch: Bool) {
		hidePopups()
		analysisMode = 2
		analysisTurn = 1
		updateSettings()
		
		withAnimation {
			undoOpacity = .clear
			prevOpacity = .clear
			nextOpacity = .clear
			optionsOpacity = .clear
		}
		
		game.timers.append(Timer.after(0.3) {
			withAnimation {
				self.hideBoard = true
			}
			BoardScene.main.rotate(right: false)
		})
		
		game.timers.append(Timer.after(0.6) {
			withAnimation { self.showWinsFor = nil }
			self.game.turnOff()
			if rematch { self.game.loadRematch() }
			else { self.game.loadNextGame() }
			
			// inside this one so they don't get cancled when the game turns off
			self.game.timers.append(Timer.after(0.2) {
				withAnimation {
					self.hideBoard = false
				}
				BoardScene.main.rotate(right: false)
			})
			
			self.game.timers.append(Timer.after(0.6) {
				self.game.startGame()
			})
		})
	}
	
	
	func loadGameOpacities() {
		undoOpacity = .clear
		prevOpacity = .clear
		nextOpacity = .clear
		optionsOpacity = .clear
	}
	
	func startGameOpacities() {
		withAnimation {
			undoOpacity = game.hints || game.mode.solve ? .half : .clear
			prevOpacity = .half
			nextOpacity = game.movesBack > 0 ? .full : .half // for tutorial
			optionsOpacity = .full
		}
	}
	
	func newMoveOpacities() {
		if undoOpacity == .half { withAnimation { undoOpacity = .full } }
		withAnimation { prevOpacity = .full }
	}
	
	
	func newGhostMoveOpacities() {
		withAnimation {
			prevOpacity = .full
			nextOpacity = .half
		}
	}
	
	func undoMoveOpacities() {
		if game.moves.count == game.preset.count {
			withAnimation {
				undoOpacity = .half
				prevOpacity = .half
			}
		}
	}
	
	func prevMoveOpacities() {
		withAnimation {
			nextOpacity = game.movesBack > 0 ? .full : .half
			if undoOpacity == .full { undoOpacity = .half }
			var minMoves = 0
			if game.mode.solve && (game.gameState == .active || !game.hints) {
				minMoves = game.preset.count
			}
			if game.moves.count - game.movesBack == minMoves { prevOpacity = .half }
		}
	}
	
	func nextMoveOpacities() {
		withAnimation {
			prevOpacity = .full
			if game.movesBack == 0 {
				if undoOpacity == .half { undoOpacity = .full }
				nextOpacity = .half
			}
		}
	}
	
	func flashNextArrow() {
		for delay in stride(from: 0.0, to: 0.4, by: 0.3) {
			game.timers.append(Timer.after(delay, run: { self.nextOpacity = .half }))
			game.timers.append(Timer.after(delay + 0.15, run: { self.nextOpacity = .full }))
		}
	}
	
	func flashPrevArrow() {
		for delay in stride(from: 0.0, to: 0.4, by: 0.3) {
			game.timers.append(Timer.after(delay, run: { self.prevOpacity = .half }))
			game.timers.append(Timer.after(delay + 0.15, run: { self.prevOpacity = .full }))
		}
	}
	
	func hidePopups() {
		if popup == .gameEnd {
			game.reviewingGame = true
			FB.main.cancelOnlineSearch?()
		}
		if popup == .none { return }
		withAnimation {
			popup = .none
		}
	}
	
	func setPopups(to newSetting: GamePopup) {
		withAnimation {
			popup = newSetting
			delayPopups = true
		}
		Timer.after(0.1) {
			withAnimation { self.delayPopups = false }
		}
	}
	
	func updateSettings() {
		confirmMoves = Storage.int(.confirmMoves)
		premoves = Storage.int(.premoves)
		moveChecker = Storage.int(.moveChecker)
		arrowSide = Storage.int(.arrowSide)
		if let trainArray = Storage.array(.train) as? [Int] {
			beatCubist = trainArray[5] == 1
		}
	}
	
	func setConfirmMoves(to v: Int) {
		confirmMoves = v
		Storage.set(v, for: .confirmMoves)
		if v == 0 {
			setPremoves(to: 1)
		} else {
			BoardScene.main.potentialMove = nil
		}
		BoardScene.main.spinMoves()
	}
	
	func setPremoves(to v: Int) {
		premoves = v
		Storage.set(v, for: .premoves)
		if v == 0 {
			setConfirmMoves(to: 1)
			BoardScene.main.potentialMove = nil
		} else {
			game.premoves = []
		}
		BoardScene.main.spinMoves()
	}
	
	func setMoveChecker(to v: Int) {
		if beatCubist {
			moveChecker = v
			Storage.set(v, for: .moveChecker)
		}
	}
	
	func setArrowSide(to v: Int) {
		withAnimation { Layout.main.leftArrows = v == 0 }
		arrowSide = v
		Storage.set(v, for: .arrowSide)
	}
	
	func onAnalysisModeSelection(to v: Int) {
		if v < 2 {
			if analysisTurn == 1 {
				showWinsFor = currentPriority
			} else {
				showWinsFor = analysisTurn == 0 ? 0 : 1
			}
			showAllHints = v == 0
			game.timers.append(Timer.after(0.4) {
				self.hidePopups()
			})
		} else {
			showWinsFor = nil
		}
		BoardScene.main.spinMoves()
	}
	
	func onAnalysisTurnSelection(v: Int) {
		withAnimation {
			analysisMode = 2
			showWinsFor = nil
		}
		BoardScene.main.spinMoves()
	}
}
