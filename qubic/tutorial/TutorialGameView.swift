//
//  TutorialGameView.swift
//  qubic
//
//  Created by Chris McElroy on 11/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct TutorialGameView: View {
	let nameSpace: CGFloat = 65
	let gameControlSpace: CGFloat = Layout.main.hasBottomGap ? 45 : 60
	
	var body: some View {
		VStack(spacing: 0) {
			Fill(nameSpace + 15)
			TutorialBoardView()
				.frame(width: Layout.main.width)
			Fill(gameControlSpace)
		}
	}
}
