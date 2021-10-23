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
	
	@Published var beatCubist = false
	@Published var hintSelection = [1,2]
	@Published var settingsSelection1 = [Storage.int(.moveChecker), Storage.int(.premoves), Storage.int(.confirmMoves)]
	@Published var settingsSelection2 = [Storage.int(.arrowSide)]
	
	var currentHintMoves: Set<Int>? {
		guard let winsFor = showWinsFor else { return nil }
		return showAllHints ? Game.main.currentMove?.allMoves[winsFor] : Game.main.currentMove?.bestMoves[winsFor]
	}
	
	func animateIntro() {
		hideAll = true
		hideBoard = true
		centerNames = true
		hintSelection = [1,2]
		updateSettings()
		
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
		hintSelection = [1,2]
		updateSettings()
		
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
				Game.main.premoves = []
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
				Game.main.premoves = []
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
