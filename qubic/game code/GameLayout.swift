//
//  GameLayout.swift
//  qubic
//
//  Created by Chris McElroy on 10/17/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

enum GamePopup {
	case none, analysis, options, gameEnd, gameEndPending, settings, deepLink
	
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
	
	@Published var analysisMode = 2
	@Published var analysisTurn = 1
	@Published var analysisText: [[String]?] = [nil, nil, nil]
	@Published var winAvailable: [Bool] = [false, false, false]
	@Published var currentSolveType: SolveType? = nil
	@Published var currentPriority: Int = 0
	@Published var beatCubist = false
	@Published var confirmMoves = Storage.int(.confirmMoves)
	@Published var premoves = Storage.int(.premoves)
	@Published var moveChecker = Storage.int(.moveChecker)
	@Published var arrowSide = Storage.int(.arrowSide)
	
	let nameSpace: CGFloat = 65
	var gameControlSpace: CGFloat { Layout.main.hasBottomGap ? 45 : 60 }
	let gameControlHeight: CGFloat = 40
	var gameEndText: [String] = [""]
	var deepLinkAction: () -> Void = {}
	
	var currentHintMoves: Set<Int>? {
		guard let winsFor = showWinsFor else { return nil }
		guard let currentMove = game.currentMove else {
			if winsFor == 1 { return nil }
			return Set(Board.positionDict[[0,0]]?.1 ?? [])
		}
		return showAllHints ? currentMove.allMoves[winsFor] : currentMove.bestMoves[winsFor]
	}
	
	func animateIntro() {
		hideAll = true
		hideBoard = true
		centerNames = true
		showWinsFor = nil
		analysisMode = 2
		analysisTurn = 1
		gameEndText = [""]
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
			game.startGame()
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
		
		print("a", centerNames)
		
		// TODO it's doing animateIntro as part of loading and that's bad
		// TODO reinstitute sharegame stuff and figure out how to have it do that transition seamlessly if possiible. i think i should consider having it fade out and i should consider making shareView and reviewView just be gameView bc they seem like they're all exactly the same
		// yeah i don't really have cause to make them different i don't think
		// still glad i separated out the components for future proofing but here it doesn't seem necessary and is actively getting in the way
		
//		if game as? ShareGame != nil || game as? ReviewGame != nil {
//			let nextGame = Game()
//			nextGame.mostRecentGame = game.mostRecentGame
//			Game.main = nextGame
//			Layout.main.currentGame = .active
//		}
		
		game.timers.append(Timer.after(0.3) {
			withAnimation {
				self.hideBoard = true
			}
			BoardScene.main.rotate(right: false)
			print("b", self.centerNames)
		})
		
		game.timers.append(Timer.after(0.6) {
			withAnimation { self.showWinsFor = nil }
			game.turnOff()
			if rematch { game.loadRematch() }
			else { game.loadNextGame() }
			
			self.gameEndText = [""]
			print("c", self.centerNames)
			
			// inside this one so they don't get cancled when the game turns off
			game.timers.append(Timer.after(0.2) {
				withAnimation {
					self.hideBoard = false
				}
				BoardScene.main.rotate(right: false)
				print("d", self.centerNames)
			})
			
			game.timers.append(Timer.after(0.6) {
				game.startGame()
				print("e", self.centerNames)
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
			if game.reviewingGame {
				undoOpacity = .clear
				prevOpacity = (game.moves.count - game.movesBack) > 0 ? .full : .half
				nextOpacity = game.movesBack > 0 ? .full : .half
			} else {
				undoOpacity = game.hints || game.mode.solve ? .half : .clear
				prevOpacity = game.moves.count - game.movesBack > 0 ? .full : .half
				nextOpacity = game.movesBack > 0 ? .full : .half // for tutorial
			}
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
//			var minMoves = 0
//			if game.mode.solve && (game.gameState == .active || !game.hints) {
//				minMoves = game.preset.count
//			}
			if game.moves.count == game.movesBack { prevOpacity = .half }
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
		withAnimation(.easeIn(duration: 0.5)) { TipStatus.main.displayed = false }
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
		if popup == .gameEnd {
			game.reviewingGame = true
			FB.main.cancelOnlineSearch?()
		}
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
		analysisMode = v
		withAnimation {
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
		}
		BoardScene.main.spinMoves()
	}
	
	func onAnalysisTurnSelection(v: Int) {
		analysisTurn = v
		withAnimation {
			analysisMode = 2
			showWinsFor = nil
		}
		BoardScene.main.spinMoves()
	}
	
	func refreshHints() {
		let firstHint: HintValue?
		let secondHint: HintValue?
		let priorityHint: HintValue?
		if game.currentMove == nil {
			firstHint = .dw
			secondHint = .noW
		} else {
			firstHint = game.currentMove?.hints[0]
			secondHint = game.currentMove?.hints[1]
		}
		
		currentSolveType = game.currentMove?.solveType
		
		let opText: [String]?
		let myText: [String]?
		let priorityText: [String]?
		switch (game.myTurn == 1 ? firstHint : secondHint) {
		case .dw:	opText = ["forced win",			"Your opponent can reach a second order checkmate in \(game.currentMove?.winLen ?? 9) moves!"]
		case .dl:	opText = ["strong defense",		"Your opponent can force you to take up to \(game.currentMove?.winLen ?? 9) moves to reach a second order checkmate!"]
		case .w0:   opText = ["4 in a row", 		"Your opponent won the game, better luck next time!"]
		case .w1:   opText = ["3 in a row",			"Your opponent has 3 in a row, so now they can fill in the last move in that line and win!"]
		case .w2d1: opText = ["checkmate", 			"Your opponent can get two checks with their next move, and you can’t block both!"]
		case .w2:   opText = ["2nd order win", 		"Your opponent can get to a checkmate using a series of checks! They can win in \(game.currentMove?.winLen ?? 0) moves!"]
		case .c1:   opText = ["check", 				"Your opponent has 3 in a row, so you should block their line to prevent them from winning!"]
		case .cm1:  opText = ["checkmate", 			"Your opponent has more than one check, and you can’t block them all!"]
		case .cm2:  opText = ["2nd order checkmate","Your opponent has more than one second order check, and you can’t block them all!"]
		case .c2d1: opText = ["2nd order check", 	"Your opponent can get checkmate next move if you don’t stop them!"]
		case .c2:   opText = ["2nd order check", 	"Your opponent can get checkmate through a series of checks if you don’t stop them!"]
		case .noW:  opText = ["no wins", 			"Your opponent doesn’t have any forced wins right now, keep it up!"]
		case nil:   opText = nil
		}
		
		switch (game.myTurn == 0 ? firstHint : secondHint) {
		case .dw:	myText = ["forced win",			"You can reach a second order checkmate in \(game.currentMove?.winLen ?? 9) moves!"]
		case .dl:	myText = ["strong defense",		"You can force your oppoennt to take up to \(game.currentMove?.winLen ?? 9) moves to reach a second order checkmate!"]
		case .w0:   myText = ["4 in a row", 		"You won the game, great job!"]
		case .w1:   myText = ["3 in a row",			"You have 3 in a row, so now you can fill in the last move in that line and win!"]
		case .w2d1: myText = ["checkmate", 			"You can get two checks with your next move, and your opponent can’t block both!"]
		case .w2:   myText = ["2nd order win", 		"You can get to a checkmate using a series of checks! You can win in \(game.currentMove?.winLen ?? 0) moves!"]
		case .c1:   myText = ["check", 				"You have 3 in a row, so you can win next turn unless it’s blocked!"]
		case .cm1:  myText = ["checkmate", 			"You have more than one check, and your opponent can’t block them all!"]
		case .cm2:  myText = ["2nd order checkmate","You have more than one second order check, and your opponent can’t block them all!"]
		case .c2d1: myText = ["2nd order check", 	"You can get checkmate next move if your opponent doesn’t stop you!"]
		case .c2:   myText = ["2nd order check", 	"You can get checkmate through a series of checks if your opponent doesn’t stop you!"]
		case .noW:  myText = ["no wins", 			"You don’t have any forced wins right now, keep working to set one up!"]
		case nil:   myText = nil
		}
		
		if firstHint == nil || secondHint == nil {
			priorityHint = nil
			priorityText = nil
			currentPriority = showWinsFor ?? game.myTurn
		} else if firstHint == .noW && secondHint == .noW {
			priorityHint = .noW
			priorityText = myText
			currentPriority = game.myTurn
		} else if firstHint ?? .noW > secondHint ?? .noW {
			priorityHint = firstHint
			priorityText = game.myTurn == 0 ? myText : opText
			currentPriority = 0
		} else {
			priorityHint = secondHint
			priorityText = game.myTurn == 1 ? myText : opText
			currentPriority = 1
		}
		
		winAvailable = [firstHint ?? .noW != .noW, priorityHint ?? .noW != .noW, secondHint ?? .noW != .noW]
		
		Timer.after(0.05) {
			self.analysisText = game.myTurn == 0 ? [myText, priorityText,  opText] : [opText, priorityText, myText]
		}
		
		if analysisMode != 2 && analysisTurn == 1 {
			Timer.after(0.06) {
				withAnimation {
					self.showWinsFor = self.currentPriority
				}
				BoardScene.main.spinMoves()
			}
		}
	}
	
	func getGameEndText() -> [String] {
		guard gameEndText == [""] else { return gameEndText }
		
		let myTurn = game.myTurn
		let opTurn = game.myTurn^1
		switch game.gameState {
		case .myWin:
			if game.mode.solve {
				if game.mode == .daily && Storage.int(.lastDC) > game.lastDC {
					gameEndText = ["\(Storage.int(.streak)) day streak!", "qubic tracks how many days in a row you have completed all 4 daily puzzles. you currently have a \(Storage.int(.streak)) day streak, nice job!"]
					return gameEndText
				}
				
				// avoids crashes when game data is invalid
				if game.moves.isEmpty || game.moves.count < game.preset.count { return [""] }
				
				var checksOnly = true
				let presetCount = max(1, game.preset.count) // avoids crashes when preset is somehow 0
				var i = game.preset.count
				while i < game.moves.count - 1 {
					if game.moves[i].hints[myTurn].noneOf(.c1, .cm1) { checksOnly = false }
					i += 2
				}
				if checksOnly {
					if game.moves[presetCount - 1].hints[myTurn] == .w1 && game.moves.count == presetCount + 1 {
						gameEndText = ["you found the fastest win!", "you had an open 3 in a row, and you found it! can’t get any faster than that!"]
						return gameEndText
					} else if game.moves[presetCount - 1].hints[myTurn] == .cm1 && game.moves.count == presetCount + 3 {
						gameEndText = ["you found the fastest win!", "you had a checkmate available, and you found it! that was the fastest win available, since there were no 3 in a rows."]
						return gameEndText
					} else if game.moves.count == presetCount + 2*game.moves[presetCount - 1].winLen - 1 {
						gameEndText = ["you found the fastest second order win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). you just found a \(game.moves[presetCount - 1].winLen) move second order win, and there was no faster second order win available!"]
						return gameEndText
					} else {
						gameEndText = ["though there is a faster win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). you just found a \(game.moves[presetCount - 1].winLen) move second order win. there’s at least one second order win available that uses fewer total moves."]
						return gameEndText
					}
				} else {
					if game.moves.count < presetCount + 2*game.moves[presetCount - 1].winLen - 1 {
						gameEndText = ["faster than the fastest second order win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). solve boards always have a first or second order win as a solution. you found an alternate solution that’s faster than the intended one! well done!"]
						return gameEndText
					} else {
						gameEndText = ["nice creative solution!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). solve boards always have a first or second order win as a solution. you found an alternate solution that allowed your opponent more freedom, but still led to a win!"]
						return gameEndText
					}
				}
			} else {
				guard game.moves.count >= 7 else {
					print("error")
					gameEndText = ["great job pulling that off!", "you managed to get 4 in a row in less than 4 moves... how’d you do that?"]
					return gameEndText
				}
				if game.moves[game.moves.count - 3].hints[myTurn] == .c1 {
					gameEndText = ["they didn’t see that coming!", "you had a check that they didn’t see, well done!"]
					return gameEndText
				}
				
				var hadW2 = false
				var fastestW2 = 0
				var W2len = 0
				var checkedFromFirstChance = false
				var winFromMistake = false
				var unbeatable = true
				var successfulW3D1 = false
				for (i, move) in game.moves.enumerated() {
					if i % 2 == opTurn {
						if move.hints[myTurn] == .w2 {
							if !hadW2 {
								checkedFromFirstChance = true
							}
							if W2len == 0 {
								fastestW2 = move.winLen
							}
							hadW2 = true
						}
						if move.hints[myTurn] == .w1 && i > 0 && game.moves[i - 1].hints[myTurn] != .cm1 {
							W2len = 0
							successfulW3D1 = false
						}
					} else {
						if move.hints[myTurn]?.oneOf(.c1, .cm1, .w0) == true {
							W2len += 1
						} else {
							if move.hints[myTurn] != .dw {
								unbeatable = false
							}
							checkedFromFirstChance = false
//							winFromMistake = false
							W2len = 0
							fastestW2 = 0
							if move.hints[opTurn]?.oneOf(.w2, .w2d1, .w1) == true {
								winFromMistake = true
							}
						}
						if move.hints[myTurn] == .cm2 {
							successfulW3D1 = true
						} else if move.hints[myTurn]?.noneOf(.cm1, .c1, .w0) == true {
							successfulW3D1 = false
						}
					}
				}
				
				if unbeatable {
					gameEndText = ["your moves were unbeatable!", "your opening moves were all in line with Patashnik’s dictionary of unbeatable moves, and you took all available opportunities to win afterwards! your opponent might have been able to win some other way, but all of your moves were in line with proven unbeatable play."]
					return gameEndText
				}
				
				var comments: [[String]] = []
				if checkedFromFirstChance {
					comments.append(["you started forcing at the first opportunity!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). you started checking (forcing) from the first move a second order win was available. discerning when it’s the right time to start forcing a win can be hard to do, so well done!"])
				}
				if W2len > 2 {
					comments.append(["you found a \(W2len) move win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). you found a second order win that involved \(W2len > 3 ? "\(W2len - 2) check moves" : "a check move"), a checkmate move, and a winning move! good job!"])
					if W2len == fastestW2 {
						comments.append(["you found the fastest second order win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). you found a second order win that involved \(W2len > 3 ? "\(W2len - 2) check moves" : "a check move"), a checkmate move, and a winning move! when you started forcing, this was the most efficient second order win. well spotted!"])
					}
				}
				if successfulW3D1 {
					comments.append(["nice second order checkmate!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). you created a situation where you had multiple potential second order wins, and your opponent couldn’t block them all. just like multiple first order checks are called a first order checkmate, mutually unblockable second order checks are called a second order checkmate. you created a second order checkmate, and then won with an unblocked second order win. very well done!"])
				}
				if winFromMistake {
					comments.append(["you capitalized on their mistake!", "your opponent had a first or second order win available, but didn’t take it. you took that opportunity and won the game instead!"])
				} else if myTurn == 0 {
					comments.append(["they never had an opening!", "your opponent never had a first or second order win available, and since you moved first, they may have never had a chance to win at all!"])
				}
				if W2len == 2 {
					comments.append(["nice checkmate!", "you set up two checks with one move, so your opponent couldn’t block both of them!"])
				}
				
				if let comment = comments.randomElement() {
					gameEndText = comment
					return gameEndText
				}
				
				gameEndText = [["great job!", "keep it up!", "they didn’t see that coming!"].randomElement() ?? ""]
				return gameEndText
				// laterDO once I have stats, add "your first win!", "your longest second order win!", and "4 wins in a row—meta!"
				// laterDO once I can see 3rd order wins, add those in as well
			}
		case .opTimeout:
			gameEndText = [["nice time managment!", "they ran out of time!", "you must have stumped them!"].randomElement() ?? ""]
			return gameEndText
		case .opResign:
			gameEndText = ["your opponent resigned!"] // got to keep this clear so they know what happened
			return gameEndText
		case .opWin:
			if game.moves.count > 4 && game.moves[game.moves.count - 3].hints[opTurn] == .c1 && game.moves[game.moves.count - 3].hints[myTurn] != .w1 && game.moves[game.moves.count - 4].hints[myTurn] == .c1 {
				if game.mode.solve {
					gameEndText = [["their block created a check!", "watch out for that one!"].randomElement() ?? "", "your check forced a checkback, where the block of your check puts you in check. if you want to use this check in a second order win, you’ll either need to make it the checkmate move, or have your block of their checkback create yet another check."]
					return gameEndText
				}
				gameEndText = ["their block created a check!", "you put your opponent in check. when they blocked your check, their move created a check on a different line. these checkbacks are easy to miss, but essential to watch out for."]
				return gameEndText
			}
			if game.mode.solve {
				var checksOnly = true
				var i = game.preset.count
				while i < game.moves.count - 1 {
					if game.moves[i].hints[myTurn].noneOf(.c1, .cm1) { checksOnly = false }
					i += 2
				}
				if checksOnly {
					// this should only trigger on daily 1's or if i put some nasty ass daily's that start with a required check but i don't think there are any
					gameEndText = ["watch out for that one!"]
					return gameEndText
				} else {
					gameEndText = [["you can win with only checks!", "you’ll get it soon!", "you’re nearly there!"].randomElement() ?? "", "you can always win solve boards with a first or second order win. first order wins are 4 in a rows. second order wins are wins that use first order checks and checkmates to force a first order win. this means that you can win every solve board by only making checks and winning moves, though you can often win in other ways, too."]
					return gameEndText
				}
			} else {
				var W2len = 0
				var blockableW2 = false
				var myOpening = false
				var myMistake = false
				var unbeatable = true
				var successfulW3D1 = false
				var earlyForce = false
				
				for (i, move) in game.moves.enumerated() {
					if i % 2 == myTurn {
						if move.hints[myTurn] == .c1 {
							if i > 0 && game.moves[i-1].hints[opTurn].oneOf(.noW, .dl) && game.moves[i - 1].hints[myTurn].oneOf(.c2, .c2d1, .w1) {
								earlyForce = true
							}
						}
						if move.hints[opTurn] == .w1 && i > 0 && game.moves[i - 1].hints[opTurn] != .cm1 {
							W2len = 0
						}
					} else {
						if move.hints[opTurn]?.oneOf(.c1, .cm1, .w0) == true {
							W2len += 1
						} else {
							if move.hints[opTurn] != .dw {
								unbeatable = false
							}
							blockableW2 = move.hints[opTurn] == .c2
							W2len = 0
							switch move.hints[myTurn] {
							case .w2, .w2d1, .w1:
								myOpening = true
								myMistake = true
							case .dw:
								myOpening = true
							default: break
							}
						}
						if move.hints[opTurn] == .cm2 {
							successfulW3D1 = true
						} else if move.hints[opTurn].noneOf(.cm1, .c1, .w0) {
							successfulW3D1 = false
						}
					}
				}
				
				if unbeatable {
					gameEndText = ["their moves were unbeatable!"]
					return gameEndText
				}
				
				var comments: [[String]] = []
				
				if game.moves.count > 2 && game.moves[game.moves.count - 3].hints[opTurn] == .c1 {
					comments.append(["watch out for that one!", "your opponent had 3 in a row, and you didn't block it. always watch out for checks your opponent might be lining up!"])
				}
				
				if W2len > 2 {
					comments.append(["they found a \(W2len) move win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). your opponent found a second order win that involved \(W2len > 3 ? "\(W2len - 2) check moves" : "a check move"), a checkmate move, and a winning move."])
					if blockableW2 {
						comments.append(["you could have blocked that win!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). your opponent found a second order win that involved \(W2len > 3 ? "\(W2len - 2) check moves" : "a check move"), a checkmate move, and a winning move. there was at least one place you could have moved before they started forcing that would have stopped them from having a second order win."])
					}
				}
				if successfulW3D1 {
					comments.append(["they found a second order checkmate!", "second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). your opponent created a situation where they had multiple potential second order wins, and you couldn’t block them all. just like multiple first order checks are called a first order checkmate, mutually unblockable second order checks are called a second order checkmate. your opponent created a second order checkmate, and then won with an unblocked second order win."])
				}
				if myOpening {
					if myMistake {
						comments.append(["you let a win slip through your fingers!", "you had a first or second order win available. if you review the game, you can look at the analysis to see where your win was, and see how close you were!"])
					}
				} else {
					comments.append(["you never had an opening!", "the in-game analysis never saw a winning opportunity for you. you may have had one, but it’s too advanced for the app to find currently."])
				}
				if earlyForce {
					comments.append(["you started forcing too early!", "you put your opponent in check without a second order win available. second order wins are wins that use first order checks and checkmates to force a first order win (4 in a row). typically the best strategy is to wait until a forcing sequence is available to start checking your opponent, though there are exceptions."])
				}
				
				if let comment = comments.randomElement() {
					gameEndText = comment
					return gameEndText
				}
				
				gameEndText = [["watch out for that one!", "they won this round!", "better luck next time!"].randomElement() ?? ""]
				return gameEndText
				// laterDO once I have stats, add "your first loss!"
				// laterDO once I can see 3rd order wins, add those in as well
			}
		case .myTimeout:
			gameEndText = [["don’t let the clock run out!", "keep your eye on the clock!", "make sure to watch your time!"].randomElement() ?? "", "the timer under your name displays how much time you have left for the entire game. anytime it’s your turn, it will continue counting down. make sure to use your time judiciously!"]
			return gameEndText
		case .myResign:
			if let last = game.moves.last {
				if last.hints[opTurn] == .w1 {
					gameEndText = ["you couldn’t let them win?", "you resigned when your opponent was about to win, why not let them win?"]
					return gameEndText
				}
				if last.hints[myTurn]?.oneOf(.w2, .w1, .w2d1, .cm1) == true {
					gameEndText = ["but you had a win!", "you had a win available when you resigned! you can review the game and use the analysis to learn more!"]
					return gameEndText
				}
				if last.hints[myTurn] == .c1 {
					if game.moves.count > 2 {
						let prevHint = game.moves[game.moves.count - 2].hints[myTurn]
						if prevHint == .w2 || prevHint == .w2d1 || prevHint == .w1 {
							gameEndText = ["but you had a win!", "you had a win available when you resigned! you can review the game and use the analysis to learn more!"]
							return gameEndText
						}
					}
				}
				if last.hints[opTurn]?.oneOf(.w2, .w2d1, .cm1) == true {
					gameEndText = ["they did have a win!", "your opponent had a win available when you resigned. you can review the game and use the analysis to see it."]
					return gameEndText
				}
				if last.hints[opTurn] == .c1 {
					if game.moves.count > 2 {
						if game.moves[game.moves.count - 2].hints[opTurn]?.oneOf(.w2, .w2d1, .w1) == true {
							gameEndText = ["they did have a win!", "your opponent had a win available when you resigned. you can review the game and use the analysis to see it."]
							return gameEndText
						}
					}
				}
			}
			return ["better luck next time!"]
		case .draw:
			// laterDO add "your first draw!" when i have stats
			gameEndText = ["that’s hard to do!", "you and your opponent filled the entire board without either of you getting 4 in a row! that's very rare!"]
			return gameEndText
		case .ended:
			switch game.moves.count {
			case 0...12:
				gameEndText = ["a short one!"]
				return gameEndText
			case 24...64:
				gameEndText = ["a long one!"]
				return gameEndText
			default:
				gameEndText = ["come back soon!"]
				return gameEndText
			}
			
		default: return [""]
		}
	}
}
