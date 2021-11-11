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
			default: Spacer()
			}
		}
	}
}
