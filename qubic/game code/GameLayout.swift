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
	
	var currentHintMoves: Set<Int>? {
		guard let winsFor = showWinsFor else { return nil }
		return showAllHints ? Game.main.currentMove?.allMoves[winsFor] : Game.main.currentMove?.bestMoves[winsFor]
	}
	
	func animateIntro() {
		hideAll = true
		hideBoard = true
		centerNames = true
//        BoardScene.main.rotate(right: true) // this created a race condition
		Game.main.timers.append(Timer.after(0.1) {
			withAnimation {
				self.hideAll = false
			}
		})
		
		Game.main.timers.append(Timer.after(1) {
			withAnimation {
				self.centerNames = false
			}
		})
		
		Game.main.timers.append(Timer.after(1.1) {
			withAnimation {
				self.hideBoard = false
			}
			BoardScene.main.rotate(right: false)
		})
		
		Game.main.timers.append(Timer.after(1.5) {
			Game.main.startGame()
		})
	}
	
	func animateGameChange(rematch: Bool) {
		hidePopups()
		withAnimation {
			undoOpacity = .clear
			prevOpacity = .clear
			nextOpacity = .clear
			optionsOpacity = .clear
		}
		
		Game.main.timers.append(Timer.after(0.3) {
			withAnimation {
				self.hideBoard = true
			}
			BoardScene.main.rotate(right: false)
		})
		
		Game.main.timers.append(Timer.after(0.6) {
			withAnimation { self.showWinsFor = nil }
			Game.main.turnOff()
			if rematch { Game.main.loadRematch() }
			else { Game.main.loadNextGame() }
			
			// inside this one so they don't get cancled when the game turns off
			Game.main.timers.append(Timer.after(0.2) {
				withAnimation {
					self.hideBoard = false
				}
				BoardScene.main.rotate(right: false)
			})
			
			Game.main.timers.append(Timer.after(0.6) {
				Game.main.startGame()
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
			undoOpacity = Game.main.hints || Game.main.mode.solve ? .half : .clear
			prevOpacity = .half
			nextOpacity = .half
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
		if Game.main.moves.count == Game.main.preset.count {
			withAnimation {
				undoOpacity = .half
				prevOpacity = .half
			}
		}
	}
	
	func prevMoveOpacities() {
		withAnimation {
			nextOpacity = Game.main.movesBack > 0 ? .full : .half
			if undoOpacity == .full { undoOpacity = .half }
			var minMoves = 0
			if Game.main.mode.solve && (Game.main.gameState == .active || !Game.main.hints) {
				minMoves = Game.main.preset.count
			}
			if Game.main.moves.count - Game.main.movesBack == minMoves { prevOpacity = .half }
		}
	}
	
	func nextMoveOpacities() {
		withAnimation {
			prevOpacity = .full
			if Game.main.movesBack == 0 {
				if undoOpacity == .half { undoOpacity = .full }
				nextOpacity = .half
			}
		}
	}
	
	func flashNextArrow() {
		for delay in stride(from: 0.0, to: 0.4, by: 0.3) {
			Game.main.timers.append(Timer.after(delay, run: { self.nextOpacity = .half }))
			Game.main.timers.append(Timer.after(delay + 0.15, run: { self.nextOpacity = .full }))
		}
	}
	
	func flashPrevArrow() {
		for delay in stride(from: 0.0, to: 0.4, by: 0.3) {
			Game.main.timers.append(Timer.after(delay, run: { self.prevOpacity = .half }))
			Game.main.timers.append(Timer.after(delay + 0.15, run: { self.prevOpacity = .full }))
		}
	}
	
	@discardableResult func hidePopups() -> Bool {
		if GameLayout.main.popup == .gameEnd {
			Game.main.reviewingGame = true
			FB.main.cancelOnlineSearch?()
		}
		if GameLayout.main.popup == .none { return false }
		withAnimation {
			GameLayout.main.popup = .none
		}
		return true
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
}
