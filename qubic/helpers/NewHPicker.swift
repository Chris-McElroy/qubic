//
//  NewHPicker.swift
//  qubic
//
//  Created by Chris McElroy on 10/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI
import Combine

struct TestPicker: View {
	@State var list: [String] = ["test", "hits", "cool", "vibes", "adding", "more", "buttonss", "test", "hits", "cool", "vibes", "adding", "more", "buttonss"]
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
	@State var lastFocus: CGFloat = 0
	let width: CGFloat
	let height: CGFloat
	let onSelection: (Int) -> Void
	
	static let ticker: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
	
	var body: some View {
		ZStack {
			HStack(spacing: 0) {
				Spacer()
					.frame(width: max(0, (CGFloat(content.count) - focus)) * width)
				ForEach(0..<Int(content.count), id: \.self) { i in
					Text(content[i])
						.frame(width: width, height: height)
						.background(Fill())
	//					.opacity(fade(for: i))
						.onTapGesture {
							selected = i
							withAnimation(.easeInOut(duration: 0.19 + Double(abs(focus - CGFloat(i)))*0.06)) {
								focus = CGFloat(i)
							}
							onSelection(i)
						}
				}
				Spacer()
					.frame(width: max(0,focus + 1) * width)
			}
			HStack(spacing: 0) {
				LinearGradient(colors: [.systemBackground.opacity(0.7), .clear], startPoint: .leading, endPoint: .trailing)
				Spacer().frame(width: width)
				LinearGradient(colors: [.clear, .systemBackground.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
			}
			.frame(width: Layout.main.width)
			.allowsHitTesting(false)
		}
		.buttonStyle(Solid())
		.onAppear {
			print("appeared")
			focus = CGFloat(selected)
		}
		.modifier(TickerModifier(focus: $focus))
		.gesture(swipe)
	}
	
	func fade(for i: Int) -> CGFloat {
		let distance = abs(CGFloat(i) - focus)
		return pow(2.5, -distance)
	}
	
	var swipe: some Gesture {
		DragGesture()
			.onChanged { drag in
				if let start = startFocus {
					print(".")
					let newFocus = start - drag.translation.width/width
					withAnimation(.easeInOut(duration: 0.2)) { focus = newFocus }
				} else {
					print("started")
					startFocus = focus
					
					NewHPicker.ticker.prepare()
				}
			}
			.onEnded { drag in
				print("ended")
				let end = drag.predictedEndTranslation.width/width
				guard let start = startFocus  else {
					print("error")
					withAnimation(.easeInOut(duration: 0.2)) {
						focus = focus.rounded(.toNearestOrAwayFromZero)
					}
					selected = Int(focus)
					startFocus = nil
					return
				}
				var closest = (start - end).rounded(.toNearestOrAwayFromZero)
				if closest >= CGFloat(content.count) { closest = CGFloat(content.count - 1) }
				if closest < 0 { closest = 0 }
				let time = bound(0.1, Double(abs(closest - (start - drag.translation.width/width))/7), 0.4)
				print(time, abs(closest - (start - drag.translation.width/width))/7)
				selected = Int(closest)
				withAnimation(.easeIn(duration: time)) { focus = closest }
				startFocus = nil
			}
	}
	
	struct TickerModifier: ViewModifier {
		@Binding var focus: CGFloat
		@State var lastFocus: CGFloat = 0
		
		func body(content: Content) -> some View {
			if #available(iOS 14.0, *) {
				content
					.onChange(of: focus, perform: tickIfNew)
			} else {
				content
					.onReceive(Just(focus), perform: tickIfNew)
			}
		}
		
		func tickIfNew(newFocus: CGFloat) {
			if newFocus.rounded(.down) != lastFocus.rounded(.down) {
				NewHPicker.ticker.impactOccurred()
			}
			lastFocus = newFocus
		}
	}
}
