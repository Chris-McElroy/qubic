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
	
	@Published var beatCubist = false
	@Published var hintSelection = [1,2]
	@Published var settingsSelection1 = [Storage.int(.moveChecker), Storage.int(.premoves), Storage.int(.confirmMoves)]
	@Published var settingsSelection2 = [Storage.int(.arrowSide)]
	
	var currentHintMoves: Set<Int>? {
		guard let winsFor = showWinsFor else { return nil }
		return showAllHints ? game.currentMove?.allMoves[winsFor] : game.currentMove?.bestMoves[winsFor]
	}
	
	func animateIntro(for game: Game) {
		self.game = game
		hideAll = true
		hideBoard = true
		centerNames = true
		hintSelection = [1,2] // TODO this doesn't update the name rotations for tutorial games
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
		hintSelection = [1,2]
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
		settingsSelection1 = [Storage.int(.moveChecker), Storage.int(.premoves), Storage.int(.confirmMoves)]
		settingsSelection2 = [Storage.int(.arrowSide)]
		if let trainArray = Storage.array(.train) as? [Int] {
			beatCubist = trainArray[5] == 1
			settingsSelection1[0] = Storage.int(.moveChecker) // handles if they fucked it up
		}
	}
	
	func onSettingsSelection1(row: Int, component: Int) -> Void {
		if component == 2 {
			Storage.set(row, for: .confirmMoves)
			if row == 0 {
				Storage.set(1, for: .premoves)
				settingsSelection1[1] = 1
				game.premoves = []
			} else {
				BoardScene.main.potentialMove = nil
			}
			BoardScene.main.spinMoves()
		} else if component == 1 {
			Storage.set(row, for: .premoves)
			if row == 0 {
				Storage.set(1, for: .confirmMoves)
				settingsSelection1[2] = 1
				BoardScene.main.potentialMove = nil
			} else {
				game.premoves = []
			}
			BoardScene.main.spinMoves()
		} else if component == 0 {
			if beatCubist {
				Storage.set(row, for: .moveChecker)
			}
		}
	}
	
	func onSettingsSelection2(row: Int, component: Int) -> Void {
		Storage.set(row, for: .arrowSide)
		withAnimation { Layout.main.leftArrows = row == 0 }
	}
}
