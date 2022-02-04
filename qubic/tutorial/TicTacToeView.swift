//
//  TicTacToeView.swift
//  qubic
//
//  Created by Chris McElroy on 11/11/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct TicTacToeView: View {
	@ObservedObject var layout = TutorialLayout.main
	@State var boardStyle: BoardStyle = .none
	@State var step: Step = .threes
	@State var nextOpacity: Opacity = .clear
	@State var exitOpacity: Opacity = .clear
	
	enum BoardStyle {
		case none, small, large
	}
	
	enum Step {
		case threes, fours, find, line1, line2, line3, line4, nice
	}
	
	///  triggers when you hit next or continue
	///  action is based on what step currently is
	///  if step is .nice it advances to the practice game view
	func nextAction() {
		guard nextOpacity == .full else { return }
		layout.readyToContinue = false
		switch step {
		case .threes:
			step = .fours
			boardStyle = .small
			layout.resetTTTLinesTimers()
			clearTTTWins()
			TutorialBoardScene.tutorialMain.panOut()
			withAnimation(.easeInOut(duration: 1.0)) {
				boardStyle = .large
			}
			Timer.after(2.5) { setNextToContinue(for: .fours) }
		case .fours:
			boardStyle = .large
			step = .find
			Timer.after(1.5) {
				if step == .find {
					withAnimation { step = .line1 }
					practiceLine([15, 14, 13, 12], answer: 3, color: .of(n: 3), for: .line1)
				}
			}
		case .find:
			step = .line1
			practiceLine([15, 14, 13, 12], answer: 3, color: .of(n: 4), for: .line1)
			break
		case .line1:
			step = .line2
			practiceLine([0, 16, 32, 48], answer: 1, color: .of(n: 8), for: .line2)
			break
		case .line2:
			step = .line3
			practiceLine([14, 26, 38, 50], answer: 2, color: .of(n: 5), for: .line3)
			break
		case .line3:
			step = .line4
			practiceLine([51, 38, 25, 12], answer: 0, color: .of(n: 2), for: .line4)
			break
		case .line4:
			if TutorialBoardScene.tutorialMain.answer == nil {
				Timer.after(0.2) {
					step = .nice
					setNextToContinue(for: .nice)
				}
			} else {
				TutorialBoardScene.tutorialMain.clearMoves()
				step = .nice
				setNextToContinue(for: .nice)
			}
			break
		case .nice:
			layout.resetTTTLinesTimers()
			TutorialBoardScene.tutorialMain.clearMoves()
			layout.advance()
			break
		}
	}
	
	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				Fill(60)
				TutorialBoardView()
					.opacity(boardStyle != .none ? 1 : 0)
				Fill(40)
			}
			VStack(spacing: 0) {
				if boardStyle != .large {
					Spacer()
				}
				Text(text)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 50)
					.offset(y: boardStyle == .small ? -Layout.main.width/2 : 0)
				if [.line1, .line2, .line3, .line4].contains(step) {
					Text("practice by filling in each one")
						.padding(.horizontal, 50)
				}
				Spacer()
				HStack {
					Button("exit tutorial") { layout.exitTutorial() }
					.opacity(exitOpacity.rawValue)
					Spacer()
					Button(layout.readyToContinue ? "continue" : "next", action: nextAction)
						.opacity(nextOpacity.rawValue)
				 }
				 .padding(20)
				 .buttonStyle(Solid())
				 .modifier(Oligopoly(size: 16))
			}
		}
		.onAppear {
			layout.readyToContinue = false
			layout.next = nextAction
			tttWins()
		}
	}
	
	var text: String {
		switch step {
		case .threes:
			return "in 3x3 tic tac toe, you can win with\n3 in a row along any line"
		case .fours:
			return "in 4x4x4 tic tac toe, you need 4 in a row along any line to win"
		case .find:
			return "some lines are hard to find"
		case .line1, .line2, .line3, .line4:
			return "some lines are hard to find"
		case .nice:
			return "nice job! now you're ready to try a game!"
		}
	}
	
	func practiceLine(_ moves: [Int], answer: Int, color: UIColor, for currentStep: Step) {
//		layout.resetTTTLinesTimers()
		TutorialBoardScene.tutorialMain.clearMoves()
		
		for (i, move) in moves.enumerated() where i != answer {
			layout.tttLinesTimers.append(Timer.after(0.3*Double(i) - (i > answer ? 0.3 : 0)) {
				guard step == currentStep else { return }
				TutorialBoardScene.tutorialMain.placeCube(move: move, color: color)
			})
		}
		
		TutorialBoardScene.tutorialMain.answer = moves[answer]
		TutorialBoardScene.tutorialMain.line = moves
		TutorialBoardScene.tutorialMain.currentColor = color
	}
	
//	func flashNext() {
//		nextOpacity = .half
//		layout.tttTimers.append(Timer.after(0.2) { nextOpacity = .full })
//		layout.tttTimers.append(Timer.after(0.4) { nextOpacity = .half })
//		layout.tttTimers.append(Timer.after(0.6) { nextOpacity = .full })
//		layout.tttTimers.append(Timer.after(0.8) { nextOpacity = .half })
//		layout.tttTimers.append(Timer.after(1) { nextOpacity = .full })
//	}
	
	func setNextToContinue(for currentStep: Step) {
		guard step == currentStep else { return }
		nextOpacity = .clear
		layout.readyToContinue = true
		Timer.after(0.2) { nextOpacity = .full }
	}
	
	func placeAndRemove(_ moves: [Int], color: UIColor) {
		for (i, move) in moves.enumerated() {
			guard step == .threes else { break }
			layout.tttLinesTimers.append(Timer.after(0.3*Double(i)) {
				TutorialBoardScene.tutorialMain.placeCube(move: move, color: color)
			})
		}
		
		layout.tttLinesTimers.append(Timer.after(1.5) {
			for move in moves {
				TutorialBoardScene.tutorialMain.undoMove(move)
			}
		})
	}
	
	func clearTTTWins() {
		for move in [1, 5, 9, 4, 6, 8, 2] {
			TutorialBoardScene.tutorialMain.undoMove(move)
		}
	}
	
	func tttWins() {
		layout.tttLinesTimers.append(Timer.after(1) {
			withAnimation {
				nextOpacity = .full
				exitOpacity = .full
			}
		})
		
		layout.tttLinesTimers.append(Timer.after(2) {
			withAnimation(.easeInOut(duration: 0.4)) {
				boardStyle = .small
			}
		})
		
		layout.tttLinesTimers.append(Timer.after(3) { placeAndRemove([1, 5, 9], color: .of(n: 1)) })
		layout.tttLinesTimers.append(Timer.after(5) { placeAndRemove([4, 5, 6], color: .of(n: 3)) })
		layout.tttLinesTimers.append(Timer.after(7) { placeAndRemove([8, 5, 2], color: .of(n: 4)) })
		
		layout.tttLinesTimers.append(Timer.after(9) { setNextToContinue(for: .threes) })
	}
}
