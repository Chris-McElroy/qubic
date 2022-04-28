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
			NewHPicker(width: 100, height: 50, scaling: 0.7, selected: $sel[0], labels: $list, underlines: $und, onSelection: onSelection)
			NewHPicker(width: 100, height: 50, selected: $sel[1], labels: .constant(["hi", "more", "buttons"])) { print("gottem", $0) }
		}
	}
	
	func onSelection(i: Int) {
		print("selected", i)
		sel[1] = 2
	}
}

struct NewHPicker: View {
	@Binding var selected: Int
	@Binding var labels: [Any]
	@Binding var underlines: [Bool]
	let width: CGFloat
	let height: CGFloat
	let scaling: CGFloat
	let onSelection: (Int) -> Void
	
	@State var focus: CGFloat = 0
	@State var startFocus: CGFloat? = nil
	@State var lastFocus: CGFloat = 0
	
	init(width: CGFloat, height: CGFloat, scaling: CGFloat = 1.0, selected: Binding<Int>, labels: Binding<[Any]>, underlines: Binding<[Bool]>? = nil, onSelection: @escaping (Int) -> Void) {
		self.width = width
		self.height = height
		self.scaling = scaling
		self.onSelection = onSelection
		
		self._selected = selected
		self._labels = labels
		self._underlines = underlines ?? .constant(Array(repeating: false, count: labels.count))
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
				LinearGradient(colors: [.systemBackground.opacity(0.7), .systemBackground.opacity(0.0)], startPoint: .leading, endPoint: .trailing)
				Spacer().frame(width: width)
				LinearGradient(colors: [.systemBackground.opacity(0.0), .systemBackground.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
			}
			.frame(width: Layout.main.width, height: height)
			.allowsHitTesting(false)
		}
		.buttonStyle(Solid())
		.onAppear {
			focus = CGFloat(selected)
		}
		.onReceive(Just(focus), perform: tickIfNew) // TODO change to onChange when on iOS 14+
		.onReceive(Just(selected), perform: changeSelection) // TODO change to onChange when on iOS 14+
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
					
					NewHPicker.ticker.prepare()
				}
			}
			.onEnded { drag in
				let end = drag.predictedEndTranslation.width/width
				guard let start = startFocus  else {
					withAnimation(.easeInOut(duration: 0.2)) {
						focus = focus.rounded(.toNearestOrAwayFromZero)
					}
					selected = Int(focus)
					startFocus = nil
					return
				}
				var closest = (start - end).rounded(.toNearestOrAwayFromZero)
				if closest >= CGFloat(labels.count) { closest = CGFloat(labels.count - 1) }
				if closest < 0 { closest = 0 }
				let time = bound(0.1, Double(abs(closest - (start - drag.translation.width/width))/7), 0.4)
				print(time, abs(closest - (start - drag.translation.width/width))/7)
				selected = Int(closest)
				withAnimation(.easeIn(duration: time)) { focus = closest }
				startFocus = nil
			}
	}
	
	func tickIfNew(newFocus: CGFloat) {
		if newFocus.rounded(.down) != lastFocus.rounded(.down) {
			NewHPicker.ticker.impactOccurred()
		}
		lastFocus = newFocus
	}
	
	func changeSelection(i: Int) {
		withAnimation(.easeInOut(duration: 0.19 + Double(abs(focus - CGFloat(i)))*0.06)) {
			focus = CGFloat(i)
		}
	}
	
//	func fade(for i: Int) -> CGFloat {
//		let distance = abs(CGFloat(i) - focus)
//		return pow(2.5, -distance)
//	}
}
