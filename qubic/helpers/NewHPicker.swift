//
//  NewHPicker.swift
//  qubic
//
//  Created by Chris McElroy on 10/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct NewHPicker: View {
	@Binding var content: [String]
	@Binding var selected: Int
	@State var focus: CGFloat = 0
	@State var startFocus: CGFloat? = nil
	let width: CGFloat
	let height: CGFloat
	let onSelection: (Int) -> Void
	
	var body: some View {
		HStack(spacing: 0) {
			Spacer()
				.frame(width: max(0,(CGFloat(content.count) - focus)) * width)
				.gesture(swipe)
			// id shit is super sus, it's from https://stackoverflow.com/questions/69527614/swiftui-why-does-foreach-need-an-id
			ForEach(0..<Int(content.count), id: \.self) { i in
				Button(action: {
					withAnimation(.easeInOut(duration: 0.19 + Double(abs(focus - CGFloat(i)))*0.06)) {
						selected = i
						focus = CGFloat(i)
					}
					onSelection(i)
				}, label: {
					Text(content[i])
						.frame(width: width, height: height)
						.background(Fill())
						.opacity(fade(for: i))
						.gesture(swipe)
				})
			}
			Spacer()
				.frame(width: max(0,focus + 1) * width)
				.gesture(swipe)
		}
		.buttonStyle(Solid())
		.onAppear {
			print("appeared")
			focus = CGFloat(selected)
		}
	}
	
	func fade(for i: Int) -> CGFloat {
		let distance = abs(CGFloat(i) - focus)
		return pow(2.5, -distance)
	}
	
	var swipe: some Gesture {
		DragGesture()
			.onChanged { drag in
				let w = drag.translation.width
				if let start = startFocus {
					print(".")
					withAnimation(.easeInOut(duration: 0.2)) { focus = start - w/width }
				} else {
					print("started")
					startFocus = focus
//					withAnimation(.easeOut(duration: 0.1)) { focus -= 2*w/width }
				}
			}
			.onEnded { drag in
				print("ended")
//				let w = drag.translation.width
				startFocus = nil
			}
	}
}
