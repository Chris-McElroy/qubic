//
//  LessonsView.swift
//  qubic
//
//  Created by Chris McElroy on 3/20/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

struct LessonsView: View {
	@ObservedObject var layout = Layout.main
	
	var body: some View {
		Spacer()
//		if layout.current == .dictLesson {
//			Spacer()
//		} else {
//			VStack(spacing: 0) {
//				ZStack {
//					Fill().frame(height: moreButtonHeight)
//					Button("lessons") {
//						layout.change(to: .lessons)
//					}
//					.buttonStyle(MoreStyle())
//				}
//				.zIndex(4)
//				if layout.current == .lessons {
//					VStack(spacing: 0) {
//						Blank(100)
//						Text("this is where you can learn patashnik's method")
//							.padding(.horizontal, 10)
//							.multilineTextAlignment(.center)
//						Spacer()
//						Button("start") {
//							Game.main.load(mode: .dictLesson, turn: 0, hints: true)
//							layout.current = .dictLesson
//						}
//						Blank(100)
//					}
//				}
//				Spacer()
//			}
//		}
	}
}
