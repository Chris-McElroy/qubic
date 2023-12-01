//
//  GameViewComponents.swift
//  qubic
//
//  Created by Chris McElroy on 5/2/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI


class GameViewComponents {
	static let gameLayout: GameLayout = GameLayout.main
	static let layout: Layout = Layout.main
	
	static var boardView: some View {
		VStack(spacing: 0) {
			Fill(gameLayout.nameSpace + 15)
			BoardView()
				.frame(width: layout.width)
				.zIndex(0.0)
				.opacity(gameLayout.hideBoard ? 0 : 1)
			Fill(gameLayout.gameControlSpace)
		}
	}
	
	static var names: some View {
		VStack(spacing: 0) {
			HStack {
				PlayerName(turn: 0)
				Spacer().frame(minWidth: 15).frame(width: gameLayout.centerNames && layout.width > 320 ? 15 : nil)
				PlayerName(turn: 1)
			}
			.padding(.horizontal, 22)
			.padding(.top, 10)
			.frame(width: layout.width)
			.background(Fill())
			.offset(y: gameLayout.centerNames ? Layout.main.safeHeight/2 - 50 : 0)
			.zIndex(1.0)
			Spacer()
		}
	}
	
	static var gameControls: some View {
		let distance: CGFloat = (layout.width - 95)/2 - 15
		
		return VStack(spacing: 0) {
			Spacer()
			ZStack {
				optionsButton
				undoButton.offset(x: gameLayout.arrowSide == 0 ? distance : -distance)
				arrowButtons.offset(x: gameLayout.arrowSide == 0 ? -distance : distance)
			}
			.frame(width: layout.width, height: gameLayout.gameControlHeight)
			.background(Fill())
			.buttonStyle(Solid())
			.offset(y: layout.hasBottomGap ? 5 : -10)
		}
	}
	
	static var optionsButton: some View {
		let vShape: Bool = gameLayout.popup == .options || gameLayout.popup == .gameEnd || (gameLayout.popup == .gameEndPending && (game.gameState == .myResign || game.gameState == .ended))
		
		return Button(action: {
			if gameLayout.popup == .options {
				gameLayout.hidePopups()
			} else if gameLayout.popup != .gameEndPending {
				gameLayout.setPopups(to: .options)
			}
		}, label: {
			HStack (spacing: 7) {
				Text("·").bold().offset(y: vShape ? -6 : 0)
				Text("·").bold().offset(y: vShape ?  6 : 0)
				Text("·").bold().offset(y: vShape ? -6 : 0)
			}
			.font(.system(size: 28))
		}).opacity(gameLayout.optionsOpacity.rawValue)
	}
	
	static var undoButton: some View {
		HStack(spacing: 0) {
			Button(action: game.undoMove) {
				VStack(spacing: 0) {
					Fill(20).cornerRadius(10).opacity(0.00001)
					Text("undo")
						.modifier(Oligopoly(size: 16))
						.accentColor(.label)
					Text(" ")
				}
			}
			.frame(width: 75, alignment: gameLayout.arrowSide == 0 ? .trailing : .leading)
			.padding(.horizontal, 10)
			.opacity(gameLayout.undoOpacity.rawValue)
		}
	}
	
	static var arrowButtons: some View {
		HStack(spacing: 0) {
			Button(action: game.prevMove) {
				VStack(spacing: 0) {
					Fill(20).cornerRadius(10).opacity(0.00001)
					Text("←")
						.modifier(Oligopoly(size: 25))
						.accentColor(.label)
					Blank(12)
				}
			}
			.frame(width: 40)
			.opacity(gameLayout.prevOpacity.rawValue)
			Spacer().frame(width: 15)
			Button(action: game.nextMove) {
				VStack(spacing: 0) {
					Fill(20).cornerRadius(10).opacity(0.00001)
					Text("→")
						.modifier(Oligopoly(size: 25))
						.accentColor(.label)
					Blank(12)
				}
			}
			.frame(width: 40)
			.opacity(gameLayout.nextOpacity.rawValue)
		}
	}
	
	static var popupFill: some View {
		Fill().opacity(gameLayout.popup.up ? 0.015 : 0) // 0.015 seems to be about the minimum opacity to work
			.onTapGesture { gameLayout.hidePopups() }
	}
	
	static var popupMasks: some View {
		VStack(spacing: 0) {
			Fill(100).offset(y: -100)
			Spacer()
			Fill(100).offset(y: 85)
		}
	}
	
	static var optionsPopup: some View {
		VStack(spacing: 0) {
			Spacer()
			VStack(spacing: 20) {
//				Text("share board")
				Button("settings") { gameLayout.setPopups(to: .settings) }
				if game.hints || game.solved {
					Button("analysis") { gameLayout.setPopups(to: .analysis) }
				}
//				Text("game insights")
				if game.reviewingGame {
					ShareButton()
					if shouldShowNewGameButton() {
						newGameButton
					}
					if game.mode != .online && game.player[game.myTurn].id == myID {
						// laterDO support online rematch requests
						rematchButton
					}
					Button("menu") { layout.goBack() }
				} else {
					if game.mode.solve || game.mode == .local || game.mode.train {
						Button("restart") {
							game.endGame(with: .restart) // otherwise it doesn't save the game
							gameLayout.animateGameChange(rematch: true)
						}
						Button("end game") { game.endGame(with: .ended) }
					} else {
						Button("resign") { game.endGame(with: .myResign) }
					}
				}
			}
			.modifier(Oligopoly(size: 18))
			.buttonStyle(Solid())
			.padding(.top, 20)
			.padding(.bottom, gameLayout.gameControlSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .options ? 0 : 400)
		}
	}
	
	static var gameEndPopup: some View {
		var titleText = game.gameState.myWin ? "you won" : "you lost"
		if game.gameState == .ended || game.gameState == .error { titleText = "game over" }
		if game.mode.solve { titleText = game.gameState.myWin ? "solved" : "failed" }
		if game.gameState == .draw { titleText = "draw" }
//		if game.mode == .picture4 { titleText = "8 day streak!" }
		let gameEndText = gameLayout.gameEndText
		
		return VStack(spacing: 0) {
			VStack(spacing: 15) {
				Text(titleText).modifier(Oligopoly(size: 24)) // .system(.largeTitle))
				Text(gameEndText[0])
					.multilineTextAlignment(.center)
			}
			.onTapGesture {
				if gameEndText.count == 2 { // TODO excuse me wtf why is this so hidden???
					TipStatus.main.showTip(gameEndText[1])
				}
			}
			.padding(.vertical, 15)
			.padding(.top, gameLayout.nameSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .gameEnd ? 0 : -(130 + gameLayout.nameSpace))
			
			Spacer()
			
			VStack(spacing: 15) {
				Button("review game") { gameLayout.hidePopups() }
//				Text("game insights")
				ShareButton()
				if shouldShowNewGameButton() {
					newGameButton
				}
				if game.mode != .online && game.player[game.myTurn].id == myID {
					rematchButton
				}
				Button("menu") { layout.goBack() }
			}
			.padding(.top, 15)
			.padding(.bottom, gameLayout.gameControlSpace)
			.modifier(Oligopoly(size: 18)) //.system(size: 18))
			.buttonStyle(Solid())
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .gameEnd ? 0 : 330)
		}
	}
	
	static var rematchButton: some View {
		Button(game.mode.solve ? "try again" : "rematch") { // game.mode == .picture4 ||
			gameLayout.animateGameChange(rematch: true)
		}
	}
	
	static var newGameButton: some View {
		let newGameText: String
		switch game.mode {
		case .novice: newGameText = "play defender"
		case .defender: newGameText = "play warrior"
		case .warrior: newGameText = "play tyrant"
		case .tyrant: newGameText = "play oracle"
		case .oracle: newGameText = "play cubist"
		case .daily, .simple, .common, .tricky:
			let key: Key = [.simple: .simple, .common: .common, .tricky: .tricky][game.mode, default: .daily]
			let type: String = [.simple: "simple", .common: "common", .tricky: "tricky"][game.mode, default: "daily"]
			if game.setupNum == solveBoardCount(key) {
				newGameText = "new \(type) ?"
			} else if game.setupNum == solveBoardCount(key) - 1 {
				newGameText = "try \(type) ?"
			} else {
				newGameText = "try \(type) \(game.setupNum + 2)"
			}
		case .bot:
			if layout.shouldStartOnlineGame() {
				newGameText = "new online game"
			} else {
				newGameText = "play new bot"
			}
		default: newGameText = "new game"
		}
		
		return ZStack {
			Button(newGameText) {
				if layout.shouldStartOnlineGame() {
					FB.main.getOnlineMatch(onMatch: { gameLayout.animateGameChange(rematch: false) },
										   timeLimit: game.totalTime ?? -1,
										   humansOnly: layout.shouldWaitForHuman())
				} else {
					gameLayout.animateGameChange(rematch: false)
				}
			}
			.opacity(layout.searchingOnline ? 0 : 1)
			ActivityIndicator(color: .label, size: .medium)
				.offset(x: 1, y: 1)
				.opacity(layout.searchingOnline ? 1 : 0)
		}
	}
	
	static var solveButtons: some View {
		HStack(spacing: 30) {
			Button("d1") { if gameLayout.currentSolveType == .d1 { Game.main.uploadSolveBoard("d1") } }
				.opacity(gameLayout.currentSolveType == .d1 ? 1.0 : 0.3)
			Button("d2") { if gameLayout.currentSolveType == .d2 { Game.main.uploadSolveBoard("d2") } }
				.opacity(gameLayout.currentSolveType == .d2 ? 1.0 : 0.3)
			Button("d3") { if gameLayout.currentSolveType == .d3 { Game.main.uploadSolveBoard("d3") } }
				.opacity(gameLayout.currentSolveType == .d3 ? 1.0 : 0.3)
			Button("d4") { if gameLayout.currentSolveType == .d4 { Game.main.uploadSolveBoard("d4") } }
				.opacity(gameLayout.currentSolveType == .d4 ? 1.0 : 0.3)
			Button("si") { if [.d1, .d2, .d3, .d4, .si, .tr].contains(gameLayout.currentSolveType) { Game.main.uploadSolveBoard("si") } }
				.opacity([.d1, .d2, .d3, .d4, .si, .tr].contains(gameLayout.currentSolveType) ? 1.0 : 0.3)
			Button("co") { if [.d4, .si, .tr].contains(gameLayout.currentSolveType) { Game.main.uploadSolveBoard("co") } }
				.opacity([.d4, .si, .tr].contains(gameLayout.currentSolveType) ? 1.0 : 0.3)
			Button("tr") { if gameLayout.currentSolveType == .tr { Game.main.uploadSolveBoard("tr") } }
				.opacity(gameLayout.currentSolveType == .tr ? 1.0 : 0.3)
		}
	}
	
	static var analysisPopup: some View {
		return VStack(spacing: 0) {
			VStack(spacing: 0) {
				if game.hints {
					Spacer()
					if let text = gameLayout.analysisText[gameLayout.analysisTurn] {
						Text(text[0]).bold()
						Blank(4)
						Text(text[1])
					} else {
						Text("loading...").bold()
					}
					Spacer()
				} else if game.mode.solve {
					if game.solved {
						VStack(spacing: 20) {
							Text("you previously solved this puzzle, do you want to enable analysis?")
							Button("yes") { withAnimation {
								game.hints = true
								GameLayout.main.updateGameView.toggle()
							} }
							.buttonStyle(Standard())
						}
					} else {
						Text("you can’t analyze solve boards until they are solved!")
					}
				} else {
					Text("analysis is only available in sandbox mode or after games!")
				}
			}
			.multilineTextAlignment(.center)
			.padding(.horizontal, 25)
			.padding(.top, gameLayout.nameSpace)
			.frame(width: layout.width, height: 200)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .analysis ? 0 : -(200 + 30 + gameLayout.nameSpace))
			
			Spacer()
			
			VStack(spacing: 0) {
				Spacer()
//				if game.reviewingGame {
//					Button("show win") {
//						// laterDO figure out how to or if i want to pause input
//						// also pause changing the analysis turn and best/all
//						let winTurn = gameLayout.analysisTurn == 1 ? 1 : 0 // laterDO use currentPriority here
//						while gameLayout.winAvailable[gameLayout.analysisTurn] {
//							let moveSet = game.moves.last?.hints[gameLayout.]
//							game.processGhostMove()
//						}
//					}
//					.opacity(gameLayout.winAvailable[gameLayout.analysisTurn] ? Opacity.full.rawValue : Opacity.half.rawValue)
//					.buttonStyle(Standard())
//				}
				if solveButtonsEnabled { solveButtons }
				Text("show moves").bold()
				HPicker(width: 70, height: 35, selection: .constant(gameLayout.analysisMode), labels: ["all", "best", "off"], onSelection: gameLayout.onAnalysisModeSelection)
				Text("wins for").bold()
				HPicker(width: 70, height: 35, selection: .constant(gameLayout.analysisTurn), labels: ["first", "priority", "second"], underlines: .constant(gameLayout.winAvailable), onSelection: gameLayout.onAnalysisTurnSelection)
			}
			.padding(.horizontal, 40)
			.padding(.bottom, gameLayout.gameControlSpace)
			.frame(width: layout.width, height: 170)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .analysis && game.hints && !gameLayout.delayPopups ? 0 : 200)
		}
		.modifier(BoundSize(min: .large, max: .extraLarge))
	}
	
	static var settingsPopup: some View {
		return VStack(spacing: 0) {
			Spacer()
			VStack(spacing: 0) {
				Text("confirm moves").bold().frame(height: 20)
				HPicker(width: 60, height: 40, selection: .constant(gameLayout.confirmMoves), labels: ["on", "off"], onSelection: gameLayout.setConfirmMoves)
				Text("premoves").bold().frame(height: 20)
				HPicker(width: 60, height: 40, selection: .constant(gameLayout.premoves), labels: ["on", "off"], onSelection: gameLayout.setPremoves)
				Text("move checker").bold().frame(height: 20)
				if gameLayout.beatCubist {
					HPicker(width: 60, height: 40, selection: .constant(gameLayout.moveChecker), labels: ["all", "checks", "off"], onSelection: gameLayout.setMoveChecker)
				} else {
					Text("beat cubist in challenge mode to unlock!")
						.foregroundColor(.secondary)
						.frame(width: layout.width, height: 40)
						.background(Fill())
						.environment(\.sizeCategory, .large)
				}
				Text("arrow side").bold().frame(height: 20)
				HPicker(width: 60, height: 40, selection: .constant(gameLayout.arrowSide), labels: ["left", "right"], onSelection: gameLayout.setArrowSide)
			}
			.padding(.bottom, gameLayout.gameControlSpace - 15)
			.padding(.top, 15)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .settings ? 0 : 400)
		}
	}
	
	static var swipe: some Gesture { DragGesture(minimumDistance: 30)
		.onEnded { drag in
			let h = drag.translation.height
			let w = drag.translation.width
			if abs(w/h) < 1 && BoardScene.main.mostRecentRotate == nil {
				if h > 0 {
					if gameLayout.popup == .options || gameLayout.popup == .gameEnd || gameLayout.popup == .settings {
						gameLayout.hidePopups()
					} else if gameLayout.popup == .none {
						gameLayout.setPopups(to: .analysis)
					}
				} else {
					if gameLayout.popup == .analysis {
						gameLayout.hidePopups()
					} else if gameLayout.popup == .none {
						gameLayout.setPopups(to: .options)
					}
				}
			}
			BoardScene.main.endRotate()
		}
		.onChanged { drag in
			let h = drag.translation.height
			let w = drag.translation.width
			if abs(w/h) > 1 && gameLayout.popup == .none {
				BoardScene.main.rotate(angle: w, start: drag.startLocation)
			}
		}
	}
	
	static let enableBadgesAlert = Alert(title: Text("Enable Badges"),
										 message: Text("Allow qubic to show a badge when a daily challenge is available?"),
										 primaryButton: .default(Text("OK"), action: { Notifications.turnOn() }),
										 secondaryButton: .cancel())
	
	static let cubistAlert = Alert(title: Text("Congratulations!"),
								   message: Text("You beat cubist in challenge mode, which unlocks the move checker feature! You can turn it on in settings."),
								   dismissButton: .cancel(Text("OK")))
	
	struct PlayerName: View {
		let turn: Int
		@ObservedObject var gameLayout: GameLayout = GameLayout.main
		@Environment(\.colorScheme) var colorScheme
		var color: Color { .of(n: game.player[turn].color) }
		var rounded: Bool { game.player[turn].rounded }
		var glow: Color { game.realTurn == turn ? color : .clear }
		var timerOpacity: Opacity { game.totalTime == nil ? .clear : (game.realTurn == turn ? .full : .half) }
		
		var body: some View {
			VStack(spacing: 3) {
				ZStack {
					Text(gameLayout.showWinsFor == turn ? gameLayout.analysisText[gameLayout.analysisTurn]?[0] ?? "loading..." : "")
						.animation(.none)
						.multilineTextAlignment(.center)
						.frame(height: 45)
					Name(for: game.player[turn], opaque: game.realTurn == turn || game.gameState == .new)
						.shadow(color: glow, radius: colorScheme == .dark ? 15 : 8, y: 0)
						.animation(.easeIn(duration: 0.3))
						.rotation3DEffect(gameLayout.showWinsFor == turn ? .radians(.pi/2) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .top)
				}
//				ZStack {
				Text(String(format: "%01d:%02d", (game.currentTimes[turn]/60) % 100, game.currentTimes[turn] % 60))
					.opacity(timerOpacity.rawValue)
//					if game.player[turn] as? User == nil {
//						HStack {
//							if turn == 1 { Spacer() }
//							ActivityIndicator(color: .label, size: .medium)
//								.opacity(game.realTurn == turn && game.gameState == .active ? 1 : 0)
//								.padding(.horizontal, 5)
//							if turn == 0 { Spacer() }
//						}
//					}
//				}
//				.frame(minWidth: 140, maxWidth: 160, minHeight: 40)
			}
		}
	}
	
	static var deepLinkPopup: some View {
		VStack(spacing: 0) {
			Spacer()
			VStack(spacing: 20) {
				Text("you opened a shared game—do you want to leave this game to see it now, or finish this game first? you can always click the link again to see the shared game")
				Button("open shared game") { gameLayout.deepLinkAction() }
				Button("dismiss") { gameLayout.hidePopups() }
			}
			.multilineTextAlignment(.center)
			.padding(.horizontal, 25)
			.buttonStyle(Standard())
			.padding(.top, 20)
			.padding(.bottom, gameLayout.gameControlSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .deepLink ? 0 : 400)
		}
	}
	
	static private func shouldShowNewGameButton() -> Bool {
		if type(of: game) == PastGame.self {
			return false
		} else if game.mode.oneOf(.local, .cubist) {
			return false
		} else if game.mode == .daily && game.setupNum == 3 {
			return false
		} else if game.player[game.myTurn].id != myID {
			return false
		}
		
		// else if game.mode == .picture4 {
		//		return false
		// }
		
		return true
	}
}
