//
//  ReplaysView.swift
//  qubic
//
//  Created by 4 on 8/4/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct PastGamesView: View {
	@ObservedObject var layout = Layout.main
	@State var result = 1
	@State var turn = 0
	@State var mode = 2
	@State var expanded: Int? = nil
    
    var body: some View {
		VStack(spacing: 0) {
			Button("past games") { layout.change(to: .pastGames) }
				.buttonStyle(MoreStyle())
				.zIndex(10)
			if layout.current == .pastGames {
				Fill(5)
					.onAppear { expanded = nil }
				if #available(iOS 14.0, *) {
					ScrollViewReader { proxy in
						ScrollView {
							LazyVStack(spacing: 10) {
								ForEach(1...100, id: \.self) { i in
									gameEntry(i) { expand(to: i, with: proxy) }
								}
							}
						}
						.frame(maxWidth: 500)
						.onAppear {
							proxy.scrollTo(99)
						}
					}
				} else {
					VStack {
						   Text("hello")
						   Text("goodbye")
					   }
				}
				Blank(10)
				HPicker(width: 84, height: 40, selection: $result, labels: ["wins", "all", "losses"], onSelection: {_ in })
				HPicker(width: 84, height: 40, selection: $turn, labels: ["all", "untimed", "1 min", "5 min", "10 min"], onSelection: {_ in })
				HPicker(width: 84, height: 40, selection: $mode, labels: ["local", "bots", "online", "train", "solve"], onSelection: {_ in })
			} else {
				Spacer()
			}
        }
        .background(Fill())
    }
	
	@available(iOS 14.0, *)
	func expand(to i: Int, with proxy: ScrollViewProxy) {
		withAnimation {
			if expanded == nil {
				expanded = i
				proxy.scrollTo(i)
			} else {
				expanded = nil
			}
		}
	}

	func gameEntry(_ i: Int, action: @escaping () -> Void) -> some View {
		VStack(spacing: 10) {
			if i % ([3, 4, 5, 6][Online.bots[i].color % 4]) == 0 {
				Text("April 14, 2022")
			}
			VStack(spacing: 0) {
				HStack(spacing: 0) {
					Name(name: Online.bots[i].name, color: .of(n: Online.bots[i].color), rounded: true)
						.allowsHitTesting(false)
						.frame(height: 40)
					Spacer()
					Text(["untimed", "1 min", "5 min", "10 min"][Online.bots[i].color % 4])
						.frame(width: 65)
					Spacer()
					Text(["win", "loss", "draw"][Online.bots[i].color % 3])
						.frame(width: 40)
				}
				if expanded == i {
					expandedGameView(i)
				}
			}
			.padding(.horizontal, 22)
			.background(Fill())
			.onTapGesture { action() }
		}
	}
	
	func expandedGameView(_ i: Int) -> some View {
		HStack(spacing: 0) {
			VStack(spacing: 20) {
				Spacer()
				Text("4 days\n7 hours\n 3 minutes\n12 seconds")
				Text("12 moves")
				Text("first")
				Spacer()
				Button("share") {}
				Button("review") {}
				Spacer()
			}
			.buttonStyle(Standard())
			.frame(minWidth: 140, maxWidth: 160)
			BoardView()
				.onAppear {
					for p in [0, 23, 12, 20, 60, 40, 33] {
						BoardScene.main.placeCube(move: p, color: .of(n: 4))
					}
					for p in [1, 3, 61, 45, 23, 38, 28] {
						BoardScene.main.placeCube(move: p, color: .of(n: 1))
					}
				}
			Spacer()
		}
		.multilineTextAlignment(.center)
	}
}

//struct ListView: View {
//    var body: some View {
//        List {
//            Section(header: Text("header text")
//            ) {
//                Text("list text")
//            }.modifier(KeepLowercase())
//        }
//    }
//}

//struct KeepLowercase: ViewModifier {
//    var thing: Bool = false
//    @ViewBuilder
//    func body(content: Content) -> some View {
//        guard #available(iOS 14, *) else {
//            content.textCase(nil)
//        }
//        content
//    }
//}

struct PastGamesView_Previews: PreviewProvider {
    static var previews: some View {
        PastGamesView()
    }
}
