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
	@State var turn = 1
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
				ScrollView {
					if #available(iOS 14.0, *) {
						LazyVStack {
							ForEach(1...100, id: \.self) { i in
//									let first = selection == 1 ? Bool.random() : selection == 0
								VStack(spacing: 0) {
									HStack(spacing: 0) {
										Name(name: Online.bots[i].name, color: .of(n: Online.bots[i].color), rounded: true)
											.frame(height: 40)
										Spacer()
										Text(["untimed", "1 min", "5 min", "10 min"].randomElement() ?? "fwoi")
											.frame(width: 65)
										Spacer()
										Text(["win", "loss", "draw"].randomElement() ?? "win")
											.frame(width: 40)
									}
									if expanded == i {
										HStack(spacing: 0) {
											VStack(spacing: 20) {
												Spacer()
												Text("3 weeks ago")
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
								.padding(.horizontal, 22)
								.background(Fill())
								.onTapGesture {
									withAnimation {
										expanded = expanded == nil ? i : nil
									}
								}
							}
						}
					} else {
						VStack {
							Text("hello")
							Text("goodbye")
						}
					}
				}
				.frame(maxWidth: 500)
				Blank(10)
				HPicker(width: 84, height: 40, selection: $turn, labels: ["first", "either", "second"], onSelection: {_ in })
				HPicker(width: 84, height: 40, selection: $result, labels: ["wins", "all", "losses"], onSelection: {_ in })
				HPicker(width: 84, height: 40, selection: $mode, labels: ["local", "bots", "online", "train", "solve"], onSelection: {_ in })
			} else {
				Spacer()
			}
        }
        .background(Fill())
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
