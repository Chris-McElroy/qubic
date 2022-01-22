//
//  PracticeGameView.swift
//  qubic
//
//  Created by Chris McElroy on 1/22/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

struct PracticeGameView: View {
	@ObservedObject var layout = TutorialLayout.main
	
	var body: some View {
		TutorialGameView()
			.onAppear { TutorialGame.tutorialMain.load() }
	}
}
