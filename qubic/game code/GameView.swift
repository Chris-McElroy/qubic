//
//  GameView.swift
//  qubic
//
//  Created by 4 on 8/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct GameView: View {
    @ObservedObject var game: Game = Game.main
	@ObservedObject var gameLayout: GameLayout = GameLayout.main
	@ObservedObject var layout: Layout = Layout.main
    @State var hintPickerContent: [[Any]] = [
        ["first", "priority", "second"],
		["all", "best", "off"]
    ]
    @State var hintText: [[String]?] = [nil, nil, nil]
    @State var currentSolveType: SolveType? = nil
	@State var currentPriority: Int = 0
	
//	var animation = Animation.linear.delay(0)
	let nameSpace: CGFloat = 65
	let gameControlSpace: CGFloat = Layout.main.hasBottomGap ? 45 : 60
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Fill(nameSpace + 15)
                BoardView()
					.frame(width: layout.width)
                    .zIndex(0.0)
					.opacity(gameLayout.hideBoard ? 0 : 1)
				Fill(gameControlSpace)
            }
			Fill().opacity(gameLayout.popup.up ? 0.015 : 0) // 0.015 seems to be about the minimum opacity to work
				.onTapGesture { gameLayout.hidePopups() }
			optionsPopup
			gameEndPopup
			analysisPopup
			settingsPopup
			VStack(spacing: 0) {
				Fill(100).offset(y: -100)
				Spacer()
				Fill(100).offset(y: 85)
			}
			VStack(spacing: 0) {
				names
				Spacer()
				gameControls
			}
        }
		.opacity(gameLayout.hideAll ? 0 : 1)
		.gesture(swipe)
		.alert(isPresented: $gameLayout.showDCAlert, content: { enableBadgesAlert })
		.alert(isPresented: $gameLayout.showCubistAlert, content: { cubistAlert })
        .onAppear {
			TutorialGame.tutorialMain.gameState = .off
            game.newHints = refreshHintPickerContent
			gameLayout.animateIntro(for: game)
        }
		.modifier(BoundSize(min: .large, max: .extraExtraExtraLarge))
    }
	
	var swipe: some Gesture { DragGesture(minimumDistance: 30)
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
	
	let enableBadgesAlert = Alert(title: Text("Enable Badges"),
								  message: Text("Allow qubic to show a badge when a daily challenge is available?"),
								  primaryButton: .default(Text("OK"), action: {
									Notifications.turnOn()
								  }),
								  secondaryButton: .cancel())
	
	let cubistAlert = Alert(title: Text("Congratulations!"),
								  message: Text("You beat cubist in challenge mode, which unlocks the move checker feature! You can turn it on in settings."),
								  dismissButton: .cancel(Text("OK")))
	
	var names: some View {
		HStack {
			PlayerName(turn: 0, text: $hintText)
			Spacer().frame(minWidth: 15).frame(width: gameLayout.centerNames && layout.width > 320 ? 15 : nil)
			PlayerName(turn: 1, text: $hintText)
		}
		.padding(.horizontal, 22)
		.padding(.top, 10)
		.frame(width: layout.width)
		.background(Fill())
		.offset(y: gameLayout.centerNames ? Layout.main.safeHeight/2 - 50 : 0)
		.zIndex(1.0)
	}
	
	var gameControls: some View {
		let distance: CGFloat = (layout.width - 95)/2 - 15
		
		return ZStack {
			optionsButton
			undoButton.offset(x: layout.leftArrows ? distance : -distance)
			arrowButtons.offset(x: layout.leftArrows ? -distance : distance)
		}
		.frame(width: layout.width, height: 40)
		.background(Fill())
		.buttonStyle(Solid())
		.offset(y: layout.hasBottomGap ? 5 : -10)
	}
	
	private var optionsButton: some View {
		let vShape: Bool = gameLayout.popup == .options || gameLayout.popup == .gameEnd || (gameLayout.popup == .gameEndPending && game.gameState == .myResign)
		
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
	
	private var undoButton: some View {
		HStack(spacing: 0) {
//            Spacer().frame(width: layout.leftArrows ? 20 : 10)
			Button(action: game.undoMove) {
				VStack(spacing: 0) {
					Fill(20).cornerRadius(10).opacity(0.00001)
					Text("undo")
						.modifier(Oligopoly(size: 16))
						.accentColor(.label)
					Text(" ")
	//                    .padding(.bottom, 10)
	//                    .multilineTextAlignment(layout.leftArrows ? .trailing : .leading)
				}
			}
			.frame(width: 75, alignment: layout.leftArrows ? .trailing : .leading)
			.padding(.horizontal, 10)
			.opacity(gameLayout.undoOpacity.rawValue)
//            Spacer().frame(width: layout.leftArrows ? 10 : 20)
		}
	}
	
	private var arrowButtons: some View {
		HStack(spacing: 0) {
//            Spacer().frame(width: layout.leftArrows ? 30 : 0)
			Button(action: game.prevMove) {
				VStack(spacing: 0) {
					Fill(20).cornerRadius(10).opacity(0.00001)
					Text("←")
						.modifier(Oligopoly(size: 25))
						.accentColor(.label)
	//                    .padding(.bottom, 10)
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
	//                    .padding(.bottom, 10)
					Blank(12)
				}
			}
			.frame(width: 40)
			.opacity(gameLayout.nextOpacity.rawValue)
//            Spacer().frame(width: layout.leftArrows ? 0 : 30)
		}
	}
	
	var optionsPopup: some View {
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
					if !(game.mode == .local || (game.mode == .daily && game.solveBoard == 3) || game.mode == .cubist) {
						newGameButton
					}
					if game.mode != .online {
						rematchButton
					}
					Button("menu") { layout.goBack() }
				} else {
					if game.mode.solve {
						Button("restart") { gameLayout.animateGameChange(rematch: true) }
					}
					Button("resign") { game.endGame(with: .myResign) }
				}
			}
			.modifier(Oligopoly(size: 18))
			.buttonStyle(Solid())
			.padding(.top, 20)
			.padding(.bottom, gameControlSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .options ? 0 : 400)
		}
	}
	
	var gameEndPopup: some View {
		var titleText = game.gameState.myWin ? "you won!" : "you lost!"
		if game.gameState == .draw { titleText = "draw" }
		if game.gameState == .error { titleText = "game over" }
		if game.mode == .daily && Storage.int(.lastDC) > game.lastDC { titleText = "\(Storage.int(.streak)) day streak!" }
//		if game.mode == .picture4 { titleText = "8 day streak!" }
		
		return VStack(spacing: 0) {
			VStack(spacing: 15) {
				Text(titleText).modifier(Oligopoly(size: 24)) // .system(.largeTitle))
//				Text("a little something about the game")
			}
			.padding(.vertical, 15)
			.padding(.top, nameSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .gameEnd ? 0 : -(130 + nameSpace))
			
			Spacer()
			
			VStack(spacing: 15) {
//				Text("share board")
				Button("review game") { gameLayout.hidePopups() }
//				Text("game insights")
				if !(game.mode == .local || (game.mode == .daily && game.solveBoard == 3) || game.mode == .cubist) { // || game.mode == .picture4) {
					newGameButton
				}
				if game.mode != .online {
					rematchButton
				}
				Button("menu") { layout.goBack() }
			}
			.padding(.top, 15)
			.padding(.bottom, gameControlSpace)
			.modifier(Oligopoly(size: 18)) //.system(size: 18))
			.buttonStyle(Solid())
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .gameEnd ? 0 : 330)
		}
	}
	
	var rematchButton: some View {
		Button(game.mode.solve ? "try again" : "rematch") { gameLayout.animateGameChange(rematch: true) } // game.mode == .picture4 ||
	}
	
	var newGameButton: some View {
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
			if game.solveBoard == solveBoardCount(key) {
				newGameText = "new \(type) ?"
			} else if game.solveBoard == solveBoardCount(key) - 1 {
				newGameText = "try \(type) ?"
			} else {
				newGameText = "try \(type) \(game.solveBoard + 2)"
			}
		default: newGameText = "new online game"
		}
		
		return ZStack {
			Button(newGameText) {
				if layout.shouldStartOnlineGame() {
					FB.main.getOnlineMatch(onMatch: { gameLayout.animateGameChange(rematch: false) })
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
    
    var solveButtons: some View {
        HStack(spacing: 30) {
            Button("d1") { if currentSolveType == .d1 { Game.main.uploadSolveBoard("d1") } }
                .opacity(currentSolveType == .d1 ? 1.0 : 0.3)
            Button("d2") { if currentSolveType == .d2 { Game.main.uploadSolveBoard("d2") } }
                .opacity(currentSolveType == .d2 ? 1.0 : 0.3)
            Button("d3") { if currentSolveType == .d3 { Game.main.uploadSolveBoard("d3") } }
                .opacity(currentSolveType == .d3 ? 1.0 : 0.3)
            Button("d4") { if currentSolveType == .d4 { Game.main.uploadSolveBoard("d4") } }
                .opacity(currentSolveType == .d4 ? 1.0 : 0.3)
            Button("si") { if [.d1, .d2, .d3, .d4, .si, .tr].contains(currentSolveType) { Game.main.uploadSolveBoard("si") } }
                .opacity([.d1, .d2, .d3, .d4, .si, .tr].contains(currentSolveType) ? 1.0 : 0.3)
            Button("co") { if [.d4, .si, .tr].contains(currentSolveType) { Game.main.uploadSolveBoard("co") } }
                .opacity([.d4, .si, .tr].contains(currentSolveType) ? 1.0 : 0.3)
            Button("tr") { if currentSolveType == .tr { Game.main.uploadSolveBoard("tr") } }
                .opacity(currentSolveType == .tr ? 1.0 : 0.3)
        }
    }
    
    func refreshHintPickerContent() {
        let firstHint: HintValue?
		let secondHint: HintValue?
		let priorityHint: HintValue?
		if game.currentMove == nil {
			firstHint = .dw
			secondHint = .noW
		} else {
			firstHint = game.currentMove?.hints[0]
			secondHint = game.currentMove?.hints[1]
		}
		
        currentSolveType = game.currentMove?.solveType
		
		let opText: [String]?
		let myText: [String]?
		let priorityText: [String]?
		switch (game.myTurn == 1 ? firstHint : secondHint) {
		case .dw:	opText = ["forced win",			"Your opponent can reach a second order checkmate in \(game.currentMove?.winLen ?? 9) moves!"]
		case .dl:	opText = ["strong defense",		"Your opponent can force you to take up to \(game.currentMove?.winLen ?? 9) moves to reach a second order checkmate!"]
        case .w0:   opText = ["4 in a row", 		"Your opponent won the game, better luck next time!"]
        case .w1:   opText = ["3 in a row",			"Your opponent has 3 in a row, so now they can fill in the last move in that line and win!"]
        case .w2d1: opText = ["checkmate", 			"Your opponent can get two checks with their next move, and you can’t block both!"]
        case .w2:   opText = ["2nd order win", 		"Your opponent can get to a checkmate using a series of checks! They can win in \(game.currentMove?.winLen ?? 0) moves!"]
        case .c1:   opText = ["check", 				"Your opponent has 3 in a row, so you should block their line to prevent them from winning!"]
        case .cm1:  opText = ["checkmate", 			"Your opponent has more than one check, and you can’t block them all!"]
        case .cm2:  opText = ["2nd order checkmate","Your opponent has more than one second order check, and you can’t block them all!"]
        case .c2d1: opText = ["2nd order check", 	"Your opponent can get checkmate next move if you don’t stop them!"]
        case .c2:   opText = ["2nd order check", 	"Your opponent can get checkmate through a series of checks if you don’t stop them!"]
        case .noW:  opText = ["no wins", 			"Your opponent doesn't have any forced wins right now, keep it up!"]
        case nil:   opText = nil
        }
        
        switch (game.myTurn == 0 ? firstHint : secondHint) {
		case .dw:	myText = ["forced win",			"You can reach a second order checkmate in \(game.currentMove?.winLen ?? 9) moves!"]
		case .dl:	myText = ["strong defense",		"You can force your oppoennt to take up to \(game.currentMove?.winLen ?? 9) moves to reach a second order checkmate!"]
        case .w0:   myText = ["4 in a row", 		"You won the game, great job!"]
        case .w1:   myText = ["3 in a row",			"You have 3 in a row, so now you can fill in the last move in that line and win!"]
        case .w2d1: myText = ["checkmate", 			"You can get two checks with your next move, and your opponent can’t block both!"]
		case .w2:   myText = ["2nd order win", 		"You can get to a checkmate using a series of checks! You can win in \(game.currentMove?.winLen ?? 0) moves!"]
        case .c1:   myText = ["check", 				"You have 3 in a row, so you can win next turn unless it’s blocked!"]
        case .cm1:  myText = ["checkmate", 			"You have more than one check, and your opponent can’t block them all!"]
        case .cm2:  myText = ["2nd order checkmate","You have more than one second order check, and your opponent can’t block them all!"]
        case .c2d1: myText = ["2nd order check", 	"You can get checkmate next move if your opponent doesn’t stop you!"]
        case .c2:   myText = ["2nd order check", 	"You can get checkmate through a series of checks if your opponent doesn’t stop you!"]
        case .noW:  myText = ["no wins", 			"You don't have any forced wins right now, keep working to set one up!"]
        case nil:   myText = nil
        }
		
		if firstHint == nil || secondHint == nil {
			priorityHint = nil
			priorityText = nil
			currentPriority = gameLayout.showWinsFor ?? game.myTurn
		} else if firstHint == .noW && secondHint == .noW {
			priorityHint = .noW
			priorityText = myText
			currentPriority = game.myTurn
		} else if firstHint ?? .noW > secondHint ?? .noW {
			priorityHint = firstHint
			priorityText = game.myTurn == 0 ? myText : opText
			currentPriority = 0
		} else {
			priorityHint = secondHint
			priorityText = game.myTurn == 1 ? myText : opText
			currentPriority = 1
		}
		
		hintPickerContent = [
			[("first", firstHint ?? .noW != .noW),
			 ("priority", priorityHint ?? .noW != .noW),
			 ("second", secondHint ?? .noW != .noW)],
			["all", "best", "off"]
		]
        
		Timer.after(0.05) {
			hintText = game.myTurn == 0 ? [myText, priorityText,  opText] : [opText, priorityText, myText]
		}
		
		if gameLayout.hintSelection[1] != 2 && gameLayout.hintSelection[0] == 1 {
			Timer.after(0.06) {
				withAnimation {
	//				print("old show wins:", game.showWinsFor, "new show wins:", currentPriority)
					self.gameLayout.showWinsFor = self.currentPriority
				}
				BoardScene.main.spinMoves()
			}
		}
    }
    
    var analysisPopup: some View {
		VStack(spacing: 0) {
			VStack(spacing: 0) {
				if game.hints {
					Spacer()
					if let text = hintText[gameLayout.hintSelection[0]] {
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
								if game.gameState != .active && !game.moves.isEmpty {
									gameLayout.prevOpacity = .full
								}
							} }
								.buttonStyle(Solid())
						}
					} else {
						Text("you can't analyze solve boards until they are solved!")
					}
				} else {
					Text("analysis is only available in sandbox mode or after games!")
				}
			}
			.multilineTextAlignment(.center)
			.padding(.horizontal, 25)
			.padding(.top, nameSpace)
			.frame(width: layout.width, height: 200)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .analysis ? 0 : -(200 + 30 + nameSpace))
			
			// unfucks the HPicker
			Fill().opacity(gameLayout.popup == .analysis ? 0.015 : 0) // 0.015 seems to be about the minimum opacity to work
				.onTapGesture { gameLayout.hidePopups() }
				.zIndex(4)
			
			ZStack {
				// HPickers
				VStack(spacing: 0) {
					Spacer()
					HPicker(content: $hintPickerContent, dim: (70, 50), selected: $gameLayout.hintSelection, action: onAnalysisSelection)
					 .frame(height: 100)
				}
				// Mask
				VStack(spacing: 0) {
					Fill()
					Blank(30)
					Fill(20)
					Blank(30)
					Fill(10)
				}
				// Content
				VStack(spacing: 0) {
					Spacer()
					Text("show moves").bold()
					Blank(34)
					Text("wins for").bold()
					Blank(36)
				}.padding(.horizontal, 40)
				if solveButtonsEnabled {
					VStack {
						solveButtons
						Spacer()
					}
				}
			}
			.padding(.bottom, gameControlSpace)
			.frame(width: layout.width, height: 170)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .analysis && game.hints && !gameLayout.delayPopups ? 0 : 200)
		}
		.modifier(BoundSize(min: .large, max: .extraLarge))
    }
    
    func onAnalysisSelection(row: Int, component: Int) {
        withAnimation {
            if component == 1 { // changing show options
                if row < 2 {
//					print("old show wins:", game.showWinsFor, "new show wins:", currentPriority)
					gameLayout.showWinsFor = gameLayout.hintSelection[0] == 1 ? currentPriority : gameLayout.hintSelection[0]/2
					gameLayout.showAllHints = row == 0
					gameLayout.hidePopups()
                } else {
					gameLayout.showWinsFor = nil
                }
            } else {            // changing first/priority/second
				gameLayout.hintSelection[1] = 2
				gameLayout.showWinsFor = nil
            }
        }
        BoardScene.main.spinMoves()
    }
	
	var settingsPopup: some View {
		let picker1Content: [[Any]] = [["all", "checks", "off"], ["on", "off"], ["on", "off"]]
		let picker2Content: [[Any]] = [["left", "right"]]
		
		return VStack(spacing: 0) {
			Spacer()
			ZStack {
				VStack(spacing: 0) {
					Fill(32)
					HPicker(content: .constant(picker1Content), dim: (60,55), selected: $gameLayout.settingsSelection1, action: gameLayout.onSettingsSelection1)
						.frame(height: 165)
						.zIndex(1)
					Fill(9)
					HPicker(content: .constant(picker2Content), dim: (60,55), selected: $gameLayout.settingsSelection2, action: gameLayout.onSettingsSelection2)
						.frame(height: 55)
						.zIndex(0)
				}
				VStack(spacing: 0) {
					Fill(5)
					Text("confirm moves").bold().frame(height: 20)
					Blank(40)
					Text("premoves").bold().frame(height: 20)
					Blank(40)
					Text("move checker").bold().frame(height: 20)
					if gameLayout.beatCubist {
						Blank(40)
					} else {
						Text("beat cubist in challenge mode to unlock!")
							.foregroundColor(.secondary)
							.frame(width: layout.width, height: 40)
							.background(Fill())
							.environment(\.sizeCategory, .large)
					}
					Text("arrow side").bold().frame(height: 20)
					Blank(40)
				}
			}
			.padding(.bottom, gameControlSpace - 20)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .settings ? 0 : 400)
		}
	}
	
    struct PlayerName: View {
        let turn: Int
		@ObservedObject var game: Game = Game.main
		@ObservedObject var gameLayout: GameLayout = GameLayout.main
        @Binding var text: [[String]?]
		@Environment(\.colorScheme) var colorScheme
        var color: Color { .of(n: game.player[turn].color) }
        var rounded: Bool { game.player[turn].rounded }
        var glow: Color { game.realTurn == turn ? color : .clear }
        var timerOpacity: Opacity { game.totalTime == nil ? .clear : (game.realTurn == turn ? .full : .half) }
        
        var body: some View {
            VStack(spacing: 3) {
                ZStack {
					Text(gameLayout.showWinsFor == turn ? text[gameLayout.hintSelection[0]]?[0] ?? "loading..." : "")
                        .animation(.none)
                        .multilineTextAlignment(.center)
                        .frame(height: 45)
                    Text(game.player[turn].name)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .foregroundColor(.white)
                        .frame(minWidth: 140, maxWidth: 160, minHeight: 40)
						.background(Rectangle()
										.foregroundColor(color)
										.opacity(game.realTurn == turn || game.gameState == .new ? 1 : 0.55)
						)
						.background(Rectangle().foregroundColor(.systemBackground))
                        .cornerRadius(rounded ? 100 : 4)
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
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: Game())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (1st generation)"))
    }
}
