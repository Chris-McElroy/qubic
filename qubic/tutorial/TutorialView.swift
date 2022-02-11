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
			Storage.set(Storage.int(.playedTutorial) + 1, for: .playedTutorial)
			layout.reset()
		}
	}
}
