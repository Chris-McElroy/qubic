//
//  PracticeGameController.swift
//  qubic
//
//  Created by Chris McElroy on 5/2/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

class PracticeGameController: ObservableObject {
	static var main: PracticeGameController = PracticeGameController()
	let tutorialLayout: TutorialLayout = TutorialLayout.main
	let gameLayout: GameLayout = GameLayout.main
	var lastAnalysisMode: Int = 2
	
	@Published var step: Step = .left
	
	enum Step {
		case left, adv1, swipe1, analysis1, block, swipe2, analysis2, adv2, undo, swipe3, show, tap, great, post, options
	}
	
	///  triggers when you hit next or continue
	///  action is based on what step currently is
	///  if step is .options it exits the tutorial
	func nextAction() {
		guard gameLayout.optionsOpacity == .full else { return }
		if step != .left { tutorialLayout.readyToContinue = false }
		switch step {
		case .left:
			withAnimation { step = .adv1 }
			tutorialLayout.readyToContinue = game.movesBack == 0
			gameLayout.setPopups(to: .settings)
		case .adv1:
			advIfNecessary1()
		case .swipe1:
			step = .analysis1
			tutorialLayout.readyToContinue = true
			gameLayout.setPopups(to: .analysis)
		case .analysis1:
			step = .block
			gameLayout.setPopups(to: .settings)
		case .block:
			if game.movesBack == 0 {
				game.prevMove()
			}
			withAnimation { step = .swipe2 }
			gameLayout.setPopups(to: .settings)
		case .swipe2:
			step = .analysis2
			tutorialLayout.readyToContinue = true
			gameLayout.setPopups(to: .analysis)
		case .analysis2:
			step = .adv2
			gameLayout.setPopups(to: .settings)
		case .adv2:
			advIfNecessary2()
		case .undo:
			game.undoMove()
			withAnimation { step = .swipe3 }
			gameLayout.setPopups(to: .settings)
		case .swipe3:
			step = .show
			gameLayout.setPopups(to: .analysis)
		case .show:
			if gameLayout.popup == .analysis {
				gameLayout.analysisMode = 1
				gameLayout.analysisTurn = 1
				gameLayout.refreshHints()
				step = .tap
				Timer.after(0.8) {
					self.gameLayout.setPopups(to: .settings)
				}
			} else {
				gameLayout.setPopups(to: .analysis)
				Timer.after(0.8) {
					self.gameLayout.analysisMode = 1
					self.gameLayout.analysisTurn = 1
					self.gameLayout.refreshHints()
					self.step = .tap
					Timer.after(3.0) {
						self.gameLayout.setPopups(to: .settings)
					}
				}
			}
		case .tap:
			if game.processingMove { break }
			else if gameLayout.popup == .gameEnd {
				game.reviewingGame = true
				tutorialLayout.readyToContinue = true
				step = .post
				gameLayout.setPopups(to: .settings)
			} else if game.movesBack == 0 && game.moves.count == 6 {
				guard let p = gameLayout.currentHintMoves?.randomElement() else { break }
				game.checkAndProcessMove(p, for: game.myTurn, setup: game.moves.map({ $0.p }))
				step = .great
			} else {
				game.endGame(with: .opResign)
				step = .great
			}
		case .great:
			game.reviewingGame = true
			tutorialLayout.readyToContinue = true
			step = .post
			gameLayout.setPopups(to: .settings)
		case .post:
			game.reviewingGame = true // just in case
			step = .options
			gameLayout.setPopups(to: .settings)
		case .options:
			tutorialLayout.exitTutorial()
		}
		
		func advIfNecessary1() {
			if game.movesBack != 0 {
				if gameLayout.popup != .none {
					gameLayout.setPopups(to: .none)
				} else {
					game.nextMove()
				}
				Timer.after(0.4) {
					advIfNecessary1()
				}
			} else {
				step = .swipe1
				Timer.after(0.4) {
					self.gameLayout.setPopups(to: .settings)
				}
			}
		}
		
		func advIfNecessary2() {
			if game.movesBack == 0 && game.moves.last?.p == 25 {
				game.undoMove()
				step = .swipe3
				gameLayout.setPopups(to: .settings)
			} else {
				game.nextMove()
				if game.moves.count == 7 && game.movesBack == 0 && step == .undo {
					Timer.after(0.4) {
						advIfNecessary2()
					}
				} else {
					step = .swipe3
				}
			}
		}
	}
	
	var tutorialText: String {
		switch step {
		case .left:
			return "player one is on the left, so you moved first in this game"
		case .adv1:
			return "this game already has some moves down, so you can’t move until you’re caught up\nuse the → button to see what moves have been played"
		case .swipe1, .analysis1:
			return "this game is being played in sandbox mode, so you can analyze the board as you play!\nswipe down to see the current board’s analysis"
		case .block:
			return "oh no! your opponent has a win!\nmaybe you could have blocked it with your previous move\nuse the ← button to go back a move"
		case .swipe2, .analysis2:
			return "now check the analysis again to see if you could have stopped them!"
		case .adv2, .undo:
			return "looks like you could have stopped their win!\nyou need to go back to the current board to undo your move\npress → and then undo"
		case .swipe3, .show:
			return "show moves lets you see how you can block their win\nopen analysis and switch show moves to “best” or “all” to see your options"
		case .tap, .great:
			return "the spinning moves are the ones that block their win\ntap one of them to stop them!"
		case .post:
			return "you can now place hypothetical moves and use the analysis even if it wasn’t available in game"
		case .options:
			return "use the ∙∙∙ button or swipe up for in-game options\ntap menu to leave the game"
		}
	}
	
	func onAnalysisModeChange(_ newMode: Int) {
		if lastAnalysisMode == 2 && newMode != 2 {
			if step == .show {
				step = .tap
				Timer.after(1.0) {
					self.gameLayout.setPopups(to: .settings)
				}
			}
		}
		lastAnalysisMode = newMode
	}
}
