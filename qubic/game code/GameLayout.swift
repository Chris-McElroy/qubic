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
	let gameControlSpace: CGFloat = Layout.main.hasBottomGap ? 45 : 60
	let gameControlHeight: CGFloat = 40
	
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
		
		game.timers.append(Timer.after(0.3) {
			withAnimation {
				self.hideBoard = true
			}
			BoardScene.main.rotate(right: false)
		})
		
		game.timers.append(Timer.after(0.6) {
			withAnimation { self.showWinsFor = nil }
			game.turnOff()
			if rematch { game.loadRematch() }
			else { game.loadNextGame() }
			
			// inside this one so they don't get cancled when the game turns off
			game.timers.append(Timer.after(0.2) {
				withAnimation {
					self.hideBoard = false
				}
				BoardScene.main.rotate(right: false)
			})
			
			game.timers.append(Timer.after(0.6) {
				game.startGame()
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
		case .noW:  opText = ["no wins", 			"Your opponent doesn't have any forced wins right now, keep it up!"]
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
		case .noW:  myText = ["no wins", 			"You don't have any forced wins right now, keep working to set one up!"]
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
}
