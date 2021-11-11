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
	@State var showBoard = false
	@State var pannedOut = false
	@State var showTapText = false
	@State var text = "in 3x3 tic tac toe, you can win with\n3 in a row along any line"
	
	var body: some View {
		VStack(spacing: 20) {
			Text(text)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 50)
			// TODO figure out how to get this offset correctly
			if showBoard {
				TutorialGameView()
					.opacity(showBoard ? 1 : 0)
					.frame(height: pannedOut ? nil : Layout.main.width)
			}
			Text("tap to continue")
				.foregroundColor(.secondary)
				.offset(y: 180) // TODO i think this is screen relative (see above)
				.opacity(showTapText ? 1 : 0)
		}
		.onAppear {
//			Timer.after(2.5) { withAnimation(.easeInOut(duration: 0.6)) { textOffset = -160 } }
			Timer.after(2.8) { withAnimation(.easeInOut(duration: 0.4)) { showBoard = true } }
			
			Timer.after(4) { placeAndRemove([1, 5, 9], color: .of(n: 1)) }
			Timer.after(6) { placeAndRemove([4, 5, 6], color: .of(n: 3)) }
			Timer.after(8) { placeAndRemove([8, 5, 2], color: .of(n: 4)) }
			
			Timer.after(9.5) {
				text = "in 4x4x4 tic tac toe, you need 4 in a row along any line to win"
			}
		}
	}
	
	func placeAndRemove(_ moves: [Int], color: UIColor) {
		for (i, move) in moves.enumerated() {
			Timer.after(0.3*Double(i)) { TutorialBoardScene.tutorialMain.placeCube(move: move, color: color) }
		}
		
		Timer.after(1.5) {
			for move in moves {
				TutorialBoardScene.tutorialMain.undoMove(move)
			}
		}
	}
}
