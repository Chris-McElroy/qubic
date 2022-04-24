//
//  NewHPicker.swift
//  qubic
//
//  Created by Chris McElroy on 10/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct TestPicker: View {
	@State var list: [String] = ["test", "hits", "cool", "vibes", "adding", "more", "buttonss"]
	@State var sel: Int = 2
	
	var body: some View {
		NewHPicker(content: $list, selected: $sel, width: 100, height: 50, onSelection: onSelection)
	}
	
	func onSelection(i: Int) {
		print("selected", i)
	}
}

struct NewHPicker: View {
	@Binding var content: [String]
	@Binding var selected: Int
	@State var focus: CGFloat = 0
	@State var startFocus: CGFloat? = nil
	let width: CGFloat
	let height: CGFloat
	let onSelection: (Int) -> Void
	
	var body: some View {
//		if #available(iOS 14.0, *) {
//			ScrollViewReader { proxy in
//				ScrollView(.horizontal, showsIndicators: false) {
//					HStack {
//						Fill().frame(width: 500)
//						ForEach(0..<Int(content.count), id: \.self) { i in
//							Text(content[i])
//								.frame(width: width, height: height)
//								.background(Fill())
//								.opacity(fade(for: i))
////								.gesture(swipe)
//
//			//				Button(action: {
//			////					withAnimation(.easeInOut(duration: 0.19 + Double(abs(focus - CGFloat(i)))*0.06)) {
//			////						selected = i
//			////						focus = CGFloat(i)
//			////					}
//			////					onSelection(i)
//			//				}, label: {
//			//
//			//				})
//						}
//						Fill().frame(width: 500)
//					}
//					.gesture(DragGesture()
////						.onChanged { _ in
////						 print("hi")
////					}
//					.onEnded { _ in
//						print("ended")
//					})
//
//				}
//			}
//		} else {
			HStack(spacing: 0) {
				Spacer()
					.frame(width: max(0,(CGFloat(content.count) - focus)) * width)
//					.gesture(swipe)
				// id shit is super sus, it's from https://stackoverflow.com/questions/69527614/swiftui-why-does-foreach-need-an-id
				ForEach(0..<Int(content.count), id: \.self) { i in
					Text(content[i])
						.frame(width: width, height: height)
						.background(Fill())
						.opacity(fade(for: i))
						.onTapGesture {
							selected = i
							withAnimation(.easeInOut(duration: 0.19 + Double(abs(focus - CGFloat(i)))*0.06)) {
								focus = CGFloat(i)
							}
							onSelection(i)
						}
//						.gesture(swipe)
					
	//				Button(action: {
	////					withAnimation(.easeInOut(duration: 0.19 + Double(abs(focus - CGFloat(i)))*0.06)) {
	////						selected = i
	////						focus = CGFloat(i)
	////					}
	////					onSelection(i)
	//				}, label: {
	//
	//				})
				}
				Spacer()
					.frame(width: max(0,focus + 1) * width)
//					.gesture(swipe)
			}
			.buttonStyle(Solid())
			.onAppear {
				print("appeared")
				focus = CGFloat(selected)
			}
			.gesture(swipe)
//		}
		
		
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
				let end = drag.predictedEndTranslation.width/width
				if let start = startFocus {
					var closest = (start - end).rounded(.toNearestOrAwayFromZero)
					if closest >= CGFloat(content.count) { closest = CGFloat(content.count - 1) }
					if closest < 0 { closest = 0 }
					let time = min(max(abs(closest - (start - drag.translation.width/width))/7, 0.1), 0.4)
					print(time, abs(closest - (start - drag.translation.width/width))/7)
					selected = Int(closest)
					withAnimation(.easeIn(duration: time)) { focus = closest }
				} else {
					print("error")
					withAnimation(.easeInOut(duration: 0.2)) { focus = 0; selected = 0 }
				}
				startFocus = nil
			}
	}
}
