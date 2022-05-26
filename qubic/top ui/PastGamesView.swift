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
					.onAppear {
						expanded = nil
					}
				if #available(iOS 14.0, *) {
					ScrollViewReader { proxy in
						ScrollView {
							LazyVStack(spacing: 10) {
								ForEach(0..<(FB.main.pastGamesDict.count), id: \.self) { i in
									gameEntry(i) { expand(to: i, with: proxy) }
								}
							}
						}
						.frame(maxWidth: 500)
						.onAppear {
							proxy.scrollTo(FB.main.pastGamesDict.count - 1)
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
		let game = FB.main.pastGamesDict.values[i]
		let op = FB.main.playerDict[game.opID] ?? FB.PlayerData(name: "n/a", color: 4)
		let time = Date(timeIntervalSinceReferenceDate: Double(game.gameID)/1000)
		let newDay: Bool
		if #available(iOS 14, *) {
			if i > 0 {
				let lastGame = FB.main.pastGamesDict.values[i - 1]
				let lastTime = Date(timeIntervalSinceReferenceDate: Double(lastGame.gameID)/1000)
				let lastDay = Calendar.current.startOfDay(for: lastTime)
				newDay = lastDay != Calendar.current.startOfDay(for: time)
			} else {
				newDay = true
			}
		} else {
			if i < FB.main.pastGamesDict.count - 1 {
				let lastGame = FB.main.pastGamesDict.values[i + 1]
				let lastTime = Date(timeIntervalSinceReferenceDate: Double(lastGame.gameID)/1000)
				let lastDay = Calendar.current.startOfDay(for: lastTime)
				newDay = lastDay != Calendar.current.startOfDay(for: time)
			} else {
				newDay = true
			}
		}
		let format = DateFormatter()
		format.dateStyle = .long
		format.timeStyle = .short
		
		return VStack(spacing: 10) {
			if newDay {
				if #available(iOS 15, *) {
					Text(time.formatted(date: .abbreviated, time: .omitted))
				} else {
					Text(format.string(from: time))
				}
			}
			VStack(spacing: 0) {
				HStack(spacing: 0) {
					Name(name: op.name, color: .of(n: op.color), rounded: true)
						.allowsHitTesting(false)
						.frame(height: 40)
					Spacer()
					Text([60: "1 min", 300: "5 min", 600: "10 min"][game.myTimes[0]] ?? "untimed")
						.frame(width: 65)
					Spacer()
					Text(game.state.myWin ? "win" : (game.state.opWin ? "loss" : "draw"))
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
		let game = FB.main.pastGamesDict.elements[i].value
		let op = FB.main.playerDict[game.opID] ?? FB.PlayerData(name: "n/a", color: 4)
		let time = Date(timeIntervalSinceReferenceDate: Double(game.gameID)/1000)
		let format = DateFormatter()
		format.dateStyle = .none
		format.timeStyle = .short
		
		return HStack(spacing: 0) {
			VStack(spacing: 20) {
				Spacer()
				if #available(iOS 15, *) {
					Text(time.formatted(date: .omitted, time: .shortened))
				} else {
					Text(format.string(from: time))
				}
				// TODO start tracking how long games last and when they actually start
//				Text("4 days\n7 hours\n 3 minutes\n12 seconds")
				Text("\(game.myMoves.count + game.opMoves.count) moves")
				Text(game.myTurn == 0 ? "first" : "second")
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
