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
		case threes, fours, find, practice, nice
	}
	
	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				Fill(50)
				TutorialBoardView()
					.opacity(boardStyle != .none ? 1 : 0)
				Fill(50)
			}
			VStack(spacing: 0) {
				if boardStyle != .large {
					Spacer()
				}
				Text(text)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 50)
					.offset(y: boardStyle == .small ? -150 : 0) // TODO still not relative
					.zIndex(4)
				Spacer()
				HStack {
					Button("exit tutorial") { layout.exitTutorial() }
					.opacity(exitOpacity.rawValue)
					Spacer()
					Button("next", action: nextAction)
						.opacity(nextOpacity.rawValue)
				 }
				 .padding(20)
				 .buttonStyle(Solid())
			}
		}
		
		.onAppear {
			TutorialBoardScene.tutorialMain.reset()
			print(Layout.main.width)
//			Timer.after(2.5) { withAnimation(.easeInOut(duration: 0.6)) { textOffset = -160 } }
			tttWins()
			
//			Timer.after(9.5) {
//				step = .fours
//			}
			
//			Timer.after(10) {
//				TutorialBoardScene.tutorialMain.panOut()
//				withAnimation {
//					pannedOut = true
//				}
//			}
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
		case .practice:
			return "some lines are hard to find\npractice by filling in each one" // TODO use two different text fields for this effect
		case .nice:
			return "nice job! now you're ready to try a game!"
		}
	}
	
	func nextAction() {
		guard nextOpacity == .full else { return }
		switch step {
		case .threes:
			step = .fours
			boardStyle = .small
			TutorialBoardScene.tutorialMain.panOut()
			withAnimation(.easeInOut(duration: 1.0)) {
				boardStyle = .large
			}
			Timer.after(2) { nextOpacity = .full }
		case .fours:
			nextOpacity = .half
			step = .find
			Timer.after(1.5) {
				withAnimation { step = .practice }
				nextOpacity = .full
			}
		case .find:
			break // shouldn't reach here
		case .practice:
			break
		case .nice:
			break
		}
	}
	
	func placeAndRemove(_ moves: [Int], color: UIColor) {
		for (i, move) in moves.enumerated() {
			guard step == .threes else { break }
			// TODO put this timer in a bank of timers that gets reset when the tutorial is reset
			Timer.after(0.3*Double(i)) { TutorialBoardScene.tutorialMain.placeCube(move: move, color: color) }
		}
		
		Timer.after(1.5) {
			for move in moves {
				TutorialBoardScene.tutorialMain.undoMove(move)
			}
		}
	}
	
	func tttWins() {
		Timer.after(1) {
			withAnimation {
				nextOpacity = .full
				exitOpacity = .full
			}
		}
		
		Timer.after(2) {
			withAnimation(.easeInOut(duration: 0.4)) {
				boardStyle = .small
			}
		}
		
		Timer.after(4) { placeAndRemove([1, 5, 9], color: .of(n: 1)) }
		Timer.after(6) { placeAndRemove([4, 5, 6], color: .of(n: 3)) }
		Timer.after(8) { placeAndRemove([8, 5, 2], color: .of(n: 4)) }
		
		guard step == .threes else { return }
		Timer.after(10) { nextOpacity = .half }
		Timer.after(10.2) { nextOpacity = .full }
		Timer.after(10.4) { nextOpacity = .half }
		Timer.after(10.6) { nextOpacity = .full }
		Timer.after(10.8) { nextOpacity = .half }
		Timer.after(11) { nextOpacity = .full }
	}
}
