//
//  WelcomeView.swift
//  qubic
//
//  Created by Chris McElroy on 11/11/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
	@ObservedObject var layout = TutorialLayout.main
	@State var cubeDown: Bool = false
	@State var showTapText: Bool = false
	let cube = CubeView()
	
	var body: some View {
		VStack(spacing: 0) {
			Blank()
			cube
				.frame(height: 180)
				.offset(y: cubeDown ? 0 : -(Layout.main.fullHeight/2 + 100))
			Text("welcome to qubic")
				.modifier(CustomFont(size: 24))
			Blank(6)
			Text("tap to continue")
				.foregroundColor(.secondary)
				.opacity(showTapText ? 1 : 0)
			Blank()
		}
		.background(Fill())
		.onTapGesture { layout.advance() }
		.onAppear {
			Timer.after(0.5) {
				withAnimation(.easeOut(duration: 0.6)) { cubeDown = true }
				cube.flipCube(duration: 0.55)
			}
			
			Timer.after(1.2) { layout.readyToContinue = true }
			
			Timer.after(2.5) { withAnimation { showTapText = true } }
		}
	}
}
