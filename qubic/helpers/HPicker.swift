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
	@State var list: [Any] = [("test", 0), Image("blueCube"), "cool", "vibes", "adding", "more", "buttonss", "test", "hits", "cool", "vibes", "adding", "more", "buttonss"]
	@State var und: [Bool] = [false, false, true, true, true, false, false, false, false, true, true, true, false, true, false, false, false, false]
	@State var sel: [Int] = [2, 0]
	
	var body: some View {
		VStack(spacing: 0) {
			HPicker(width: 100, height: 50, scaling: 0.7, selection: $sel[0], labels: $list, underlines: $und, onSelection: onSelection)
			HPicker(width: 100, height: 50, selection: $sel[1], labels: .constant(["hi", "more", "buttons"])) { print("gottem", $0) }
		}
	}
	
	func onSelection(i: Int) {
		print("selected", i)
		sel[1] = 2
	}
}

struct HPicker: View {
	@Binding var selection: Int
	@Binding var labels: [Any]
	@Binding var underlines: [Bool]
	let width: CGFloat
	let height: CGFloat
	let scaling: CGFloat
	let onSelection: (Int) -> Void
	
	@State var focus: CGFloat = -1
	@State var startFocus: CGFloat? = nil
	@State var lastFocus: CGFloat = -1
	@State var lastSelection: Int = -1
	
	init(width: CGFloat, height: CGFloat, scaling: CGFloat = 1.0, selection: Binding<Int>, labels: Binding<[Any]>, underlines: Binding<[Bool]>? = nil, onSelection: @escaping (Int) -> Void) {
		self.width = width
		self.height = height
		self.scaling = scaling
		self.onSelection = onSelection
		
		self._selection = selection
		self._labels = labels
		self._underlines = underlines ?? .constant(Array(repeating: false, count: labels.wrappedValue.count))
		// using wrapped value to avoid a crash pre iOS 15
	}
	
	init(width: CGFloat, height: CGFloat, scaling: CGFloat = 1.0, selection: Binding<Int>, labels: [Any], underlines: Binding<[Bool]>? = nil, onSelection: @escaping (Int) -> Void) {
		self.init(width: width, height: height, scaling: scaling, selection: selection, labels: .constant(labels), underlines: underlines, onSelection: onSelection)
	}
	
	static let ticker: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
	
	var body: some View {
		ZStack {
			HStack(spacing: 0) {
				Spacer()
					.frame(width: max(0, (CGFloat(labels.count) - focus)) * width)
				ForEach(0..<Int(labels.count), id: \.self) { i in
					option(i)
						.frame(width: width, height: height)
						.background(Fill())
						.onTapGesture {
							selection = i
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
				Fill().opacity(0.6)
				Spacer().frame(width: width)
				Fill().opacity(0.6)
			}
			.allowsHitTesting(false)
		}
		.frame(width: Layout.main.width, height: height)
		.onReceive(Just(focus), perform: tickIfNew) // TODO change to onChange when on iOS 14+ (and consider losing lastFocus)
		.onReceive(Just(selection), perform: changeSelection) // TODO change to onChange when on iOS 14+ (and consider losing lastSelection)
		.onAppear { focus = CGFloat(selection) }
		.gesture(swipe)
	}
	
	@ViewBuilder func option(_ i: Int) -> some View {
		if let text = labels[i] as? String {
			underlinedText(text, underlines[i])
		} else if let (text, n) = labels[i] as? (String, Int) {
			VStack(spacing: 0) {
				underlinedText(text, underlines[i])
				Text(String(n))
					.foregroundColor(.gray)
					.font(.system(size: 15))
			}
		} else if let image = labels[i] as? Image {
			image
				.resizable()
				.aspectRatio(contentMode: .fit)
				.scaleEffect(scaling)
		}
	}
	
	@ViewBuilder func underlinedText(_ text: String, _ underlined: Bool?) -> some View {
		if underlined == true {
			Text(text).underline()
		} else {
			Text(text)
		}
	}
	
	var swipe: some Gesture {
		DragGesture()
			.onChanged { drag in
				if let start = startFocus {
					let newFocus = start - drag.translation.width/width
					withAnimation(.easeInOut(duration: 0.2)) { focus = newFocus }
				} else {
					startFocus = focus
					
					HPicker.ticker.prepare()
				}
			}
			.onEnded { drag in
				let end = drag.predictedEndTranslation.width/width
				guard let start = startFocus  else {
					withAnimation(.easeInOut(duration: 0.2)) {
						focus = focus.rounded(.toNearestOrAwayFromZero)
					}
					selection = Int(focus)
					startFocus = nil
					return
				}
				var closest = (start - end).rounded(.toNearestOrAwayFromZero)
				if closest >= CGFloat(labels.count) { closest = CGFloat(labels.count - 1) }
				if closest < 0 { closest = 0 }
				let time = bound(0.1, Double(abs(closest - (start - drag.translation.width/width))/7), 0.4)
				print(time, abs(closest - (start - drag.translation.width/width))/7)
				selection = Int(closest)
				withAnimation(.easeIn(duration: time)) { focus = closest }
				onSelection(selection)
				startFocus = nil
			}
	}
	
	func tickIfNew(newFocus: CGFloat) {
		if lastFocus == -1 {
			lastFocus = newFocus
		}
		if newFocus.rounded(.down) != lastFocus.rounded(.down) {
			HPicker.ticker.impactOccurred()
			lastFocus = newFocus
		}
	}
	
	func changeSelection(i: Int) {
		if lastSelection == -1 {
			lastSelection = i
		}
		if i != lastSelection {
			withAnimation(.easeInOut(duration: min(0.6, 0.19 + Double(abs(focus - CGFloat(i)))*0.06))) {
				focus = CGFloat(i)
			}
			lastSelection = i
		}
	}
	
//	func fade(for i: Int) -> CGFloat {
//		let distance = abs(CGFloat(i) - focus)
//		return pow(2.5, -distance)
//	}
}
