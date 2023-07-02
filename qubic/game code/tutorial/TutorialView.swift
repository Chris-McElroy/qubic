//
//  TutorialView.swift
//  qubic
//
//  Created by Chris McElroy on 10/23/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct TutorialView: View {
	@ObservedObject var layout = TutorialLayout.main
	
	var body: some View {
		ZStack {
			switch layout.current {
			case .welcome: WelcomeView()
			case .tictactoe: TicTacToeView()
			case .practiceGame: PracticeGameView()
			case .setName: SetNameView()
			default: Spacer()
			}
		}
		.onAppear {
			layout.reset()
			Storage.set(Storage.int(.startedTutorial) + 1, for: .startedTutorial)
		}
		.onDisappear { // changing this to disappear so it only increments when they've finished the tutorial
			Storage.set(Storage.int(.playedTutorial) + 1, for: .playedTutorial)
		}
	}
}
