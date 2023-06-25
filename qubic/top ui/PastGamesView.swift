//
//  ReplaysView.swift
//  qubic
//
//  Created by 4 on 8/4/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct PastGamesView: View {
	@ObservedObject var layout = Layout.main
	@State var result = 1
	@State var turn = 1
	@State var time = 0
	@State var mode = 2
	@State var expanded: Int? = nil
	@State var gameList: [GameSummary] = [] // this is what live updates the displayed games
	@State var currentProxy: Any? = nil
    
    var body: some View {
		VStack(spacing: 0) {
			Button("past games") { layout.change(to: .pastGames) }
				.buttonStyle(MoreStyle())
				.zIndex(10)
				.onAppear {
					DispatchQueue(label: "past game loader", qos: .userInteractive).async {
						GameSummary.updatePastGames()
					}
				}
			if layout.current == .pastGames || layout.current == .review {
				Fill(5)
					.onAppear {
						getCurrentGames()
						expanded = nil
					}
				if #available(iOS 14.0, *) {
					ScrollViewReader { proxy in
						ScrollView {
							LazyVStack(spacing: 10) {
								ForEach(0..<(gameList.count), id: \.self) { i in
									gameEntry(i) { expand(to: i, with: proxy) }
								}
							}
						}
						.frame(maxWidth: 500)
						.onAppear {
							currentProxy = proxy
							proxy.scrollTo(gameList.count - 1)
						}
					}
				} else {
					ScrollView {
						VStack(spacing: 10) {
							Fill(1)
							if gameList.count > 0 {
								ForEach(0..<(gameList.count), id: \.self) { i in
									gameEntry(gameList.count - 1 - i) { expand(to: gameList.count - 1 - i) }
								}
							}
						}
					}
					.frame(maxWidth: 500)
				}
				Blank(10)
				Spacer().frame(height: layout.current == .review ? layout.fullHeight : 0)
				HPicker(width: 84, height: 40, selection: $result, labels: ["wins", "all", "losses"], onSelection: {_ in getCurrentGames() })
				HPicker(width: 84, height: 40, selection: $turn, labels: ["first", "either", "second"], onSelection: {_ in getCurrentGames() })
				HPicker(width: 84, height: 40, selection: $time, labels: ["all", "~15 sec", "~30 sec", "1+ min", "untimed"], onSelection: {_ in getCurrentGames() })
					.modifier(EnableHPicker(on: mode.noneOf(3, 4)))
				HPicker(width: 84, height: 40, selection: $mode, labels: ["local", "bots", "online", "train", "solve"], onSelection: {_ in getCurrentGames() })
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
	
	func expand(to i: Int) {
		withAnimation {
			if expanded == nil {
				expanded = i
			} else {
				expanded = nil
			}
		}
	}

	func gameEntry(_ i: Int, action: @escaping () -> Void) -> some View {
		let game = gameList[i]
		let op = game.op
		let time = Date(timeIntervalSinceReferenceDate: Double(game.gameID)/1000)
		let newDay: Bool
		if #available(iOS 14, *) {
			if i > 0 {
				let lastGame = gameList[i - 1]
				let lastTime = Date(timeIntervalSinceReferenceDate: Double(lastGame.gameID)/1000)
				let lastDay = Calendar.current.startOfDay(for: lastTime)
				newDay = lastDay != Calendar.current.startOfDay(for: time)
			} else {
				newDay = true
			}
		} else {
			if i < gameList.count - 1 {
				let lastGame = gameList[i + 1]
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
					Text(timeLabel(for: game.timeLimit))
						.frame(width: 65)
					Spacer()
					Text(game.myTurn == 0 ? "1st" : "2nd")
						.frame(width: 30)
					Spacer()
					Text(game.state.myWin ? "win" : (game.state.opWin ? "loss" : (game.state == .draw ? "draw" : "—")))
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
		let summary = gameList[i]
		let game = GameData(from: GameData.all[String(summary.gameID)] ?? [:], gameID: summary.gameID)
		let op = summary.op
		let time = Date(timeIntervalSinceReferenceDate: Double(game.gameID)/1000)
		let length = game.endTime - game.gameID
		let format = DateFormatter()
		let boardScene = BoardScene()
		format.dateStyle = .none
		format.timeStyle = .short

		return HStack(spacing: 0) {
			VStack(spacing: 20) {
				Spacer()
				if #available(iOS 15, *) {
					Text(time.formatted(date: Date.FormatStyle.DateStyle.omitted, time: Date.FormatStyle.TimeStyle.shortened))
				} else {
					Text(format.string(from: time))
				}
				if length > 0 {
					Text(getLenString(from: length))
				}
				Text("\(game.orderedMoves().count) moves")
				Spacer()
				Spacer()
				Spacer()
				VStack(spacing: 20) {
					Button("review") {
						ReviewGame(gameData: game, opData: summary.op).load()
						GameLayout.main.animateIntro()
						layout.change(to: .review)
					}
					if game.mode != .online { // laterDo implement online rematches
						Button("rematch") {
							PastGamesView.startRematch(game: game)
						}
					}
					ShareButton(playerID: myID, gameID: String(game.gameID))
				}
				Spacer()
			}
			.buttonStyle(Standard())
			.frame(minWidth: 140, maxWidth: 160)
			BoardView(boardScene.view)
				.padding(.vertical, 15)
				.onAppear {
					boardScene.reset(baseRotation: SCNVector4(x: 0, y: -1, z: 0, w: .pi/2))
					let moves = game.orderedMoves()
					let board = Board()
					for (i, p) in moves.enumerated() {
						board.addMove(p)
						if i % 2 == game.myTurn {
							boardScene.addCube(move: p, color: Storage.int(.color))
						} else {
							boardScene.addCube(move: p, color: op.color)
						}
					}
					if let wins = board.getWinLines(for: moves.last ?? 0) {
						boardScene.showWins(wins, color: (moves.count % 2)^1 == game.myTurn ? Storage.int(.color) : op.color, spin: false)
					}
				}
			Spacer()
		}
		.multilineTextAlignment(.center)
	}

	func getCurrentGames() {
		withAnimation {
			expanded = nil
		}

		let requiredTime: ClosedRange<Double>? = [1: 0...22, 2: 23...59, 3: 60...(.infinity), 4: (-1)...(-1)][time]

		gameList = GameSummary.pastGames[mode].values
			.filter { result == 1 ? true : (result == 0 ? $0.state.myWin : $0.state.opWin) }
			.filter { turn == 1 ? true : (turn == 0 ? $0.myTurn == 0 : $0.myTurn == 1) }
			.filter { time == 0 || mode.oneOf(3, 4) ? true : ((requiredTime ?? (-1)...(-1)).contains($0.timeLimit))  }

		if #available(iOS 14.0, *) {
			Timer.after(0.03) {
				withAnimation(.easeOut(duration: 0.08)) {
					(currentProxy as? ScrollViewProxy)?.scrollTo(gameList.count - 1)
				}
			}
		}
	}
	
	func getLenString(from length: Int) -> String {
		let days = length / 86_400_000
		let hours = (length / 3_600_000) % 24
		let minutes = (length / 60000) % 60
		let seconds = (length / 1000) % 60
		let dayString = "\(days) day\(days != 1 ? "s" : "")"
		let hourString = "\(hours) hour\(hours != 1 ? "s" : "")"
		let minuteString = "\(minutes) minute\(minutes != 1 ? "s" : "")"
		let secondString = "\(seconds) second\(seconds != 1 ? "s" : "")"
		var lenString = ""
		if days > 0 {
			lenString += dayString
			if hours > 0 {
				lenString += "\n" + hourString
			}
		} else if hours > 0 {
			lenString += hourString
			if minutes > 0 {
				lenString += "\n" + minuteString
			}
		} else if minutes > 0 {
			lenString += minuteString
			if seconds > 0 {
				lenString += "\n" + secondString
			}
		} else if seconds >= 0 {
			lenString += secondString
		}
		return lenString
	}
	
	static func startRematch(game: GameData) {
		var setupNum = 0
		var turn: Int? = nil
		var hints = game.hints
		var timeLimit: Double? = game.totalTime
		let newGame = Game()
		
		if game.mode.train {
			// nothing to do
		} else if game.mode.solve {
			// turn stays nil just like normal solves
			hints = false
			newGame.preset = Array(game.orderedMoves().first(game.presetCount)) // TODO check that this works at alllll (it doesn't seem to at least for dailies?)
			newGame.rematchRequested = true // TODO make sure this isn't fucking shit up
		} else if game.mode == .bot {
			hints = false
			setupNum = game.setupNum // TODO is this actually saved?
		} else if game.mode == .local {
			// nothing to do
		} else { return }
		
		print(game.mode, setupNum, turn, hints, timeLimit)
		// TODO test that this works for every type of game
		// TODO if you do a play game after a share game does it bork everything? i feel like it should
		// i think the solution is to always call Game().load() and have it call Game.main.turnoff and Game.main = self
		
		newGame.load(mode: game.mode, setupNum: setupNum, turn: turn, hints: hints, time: timeLimit)
		GameLayout.main.animateIntro()
		Layout.main.change(to: .rematch)
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
