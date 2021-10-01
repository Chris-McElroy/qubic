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
	@ObservedObject var layout: Layout = Layout.main
    @State var cubeHeight: CGFloat = 10
    @State var rotateMe = false
    @State var isRotated = false
    @State var cont = false
    @State var hintSelection = [1,2]
    @State var hintPickerContent: [[Any]] = [
        ["blocks", "wins"],
		["all", "best", "off"]
    ]
    @State var hintText: [[String]?] = [nil, nil]
    @State var currentSolveType: SolveType? = nil
    @State var hideAll: Bool = true
    @State var hideBoard: Bool = true
    @State var centerNames: Bool = true
    @State var opText: [String]?
    @State var myText: [String]?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Fill(65)
                BoardView()
                    .gesture(swipe)
                    .zIndex(0.0)
					.alert(isPresented: $game.showDCAlert, content: { enableBadgesAlert })
                    .opacity(hideBoard ? 0 : 1)
            }
            VStack(spacing: 0) {
                names
                Spacer()
                ZStack {
					Fill().shadow(radius: 20).offset(y: game.hintCard || game.gameEndPopup ? 0 : 300)
					gameEndOptions.offset(y: game.gameEndPopup ? 0 : 300)
					hintContent.offset(y: game.hintCard ? 0 : 300)
                }
                .frame(height: 240)
            }
        }
        .opacity(hideAll ? 0 : 1)
        .onAppear {
            Game.main.newHints = refreshHintPickerContent
            animateIntro()
        }
    }
	
	let swipe = DragGesture(minimumDistance: 30)
		.onEnded { drag in
			let h = drag.translation.height
			let w = drag.translation.width
			if abs(w/h) < 1 {
				if h > 0 {
					Game.main.goBack()
				} else {
					Game.main.showHintCard()
				}
			}
			BoardScene.main.endRotate()
		}
		.onChanged { drag in
			let h = drag.translation.height
			let w = drag.translation.width
			if abs(w/h) > 1 {
			   BoardScene.main.rotate(angle: w, start: drag.startLocation, time: drag.time)
			}
		}
	
	let enableBadgesAlert = Alert(title: Text("Enable Badges"),
								  message: Text("Allow 4Play to show a badge when a daily challenge is available?"),
								  primaryButton: .default(Text("OK"), action: {
									Notifications.turnOn()
								  }),
								  secondaryButton: .cancel())
	
	var names: some View {
		HStack {
			PlayerName(turn: 0, game: game, text: game.myTurn == 0 ? $myText : $opText)
			Spacer().frame(minWidth: 15).frame(width: centerNames ? 15 : nil)
			PlayerName(turn: 1, game: game, text: game.myTurn == 1 ? $myText : $opText)
		}
		.padding(.horizontal, 22)
		.padding(.top, 10)
		.offset(y: centerNames ? Layout.main.safeHeight/2 - 50 : 0)
		.zIndex(1.0)
	}
	
	var gameEndOptions: some View {
		var titleText = game.gameState.myWin ? "you won!" : "you lost!"
		if game.gameState == .draw { titleText = "draw" }
		if game.mode == .daily && Storage.int(.lastDC) > game.lastDC { titleText = "\(Storage.int(.streak)) day streak!" }
		let rematchText = game.mode.solve ? "try again" : "rematch"
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
		
		return VStack(spacing: 15) {
			Spacer()
			Text(titleText).font(.custom("Oligopoly Regular", size: 24)) // .system(.largeTitle))
			Spacer()
			Button("review game") { game.hideGameEndPopup() }
			if game.mode != .online {
				Button(rematchText) { animateGameChange(rematch: true) }
			}
			if !(game.mode == .local || (game.mode == .daily && game.solveBoard == 3) || game.mode == .cubist) {
				ZStack {
					Button(newGameText) {
						if layout.shouldStartOnlineGame() {
							FB.main.getOnlineMatch(onMatch: { animateGameChange(rematch: false) })
						} else {
							animateGameChange(rematch: false)
						}
					}
					.opacity(layout.searchingOnline ? 0 : 1)
					ActivityIndicator(color: .label, size: .medium)
						.offset(x: 1, y: 1)
						.opacity(layout.searchingOnline ? 1 : 0)
				}
			}
			Spacer()
			Spacer()
		}
		.font(.custom("Oligopoly Regular", size: 18)) //.system(size: 18))
		.buttonStyle(Solid())
	}
    
    func animateIntro() {
        hideAll = true
        hideBoard = true
        centerNames = true
//        BoardScene.main.rotate(right: true) // this created a race condition
        game.timers.append(Timer.after(0.1) {
            withAnimation {
                hideAll = false
            }
        })
		game.timers.append(Timer.after(1) {
            withAnimation {
                centerNames = false
            }
        })
		game.timers.append(Timer.after(1.1) {
            withAnimation {
                hideBoard = false
            }
            BoardScene.main.rotate(right: false)
        })
		game.timers.append(Timer.after(1.5) {
            game.startGame()
        })
    }
	
	func animateGameChange(rematch: Bool) {
		game.hideGameEndPopup()
		game.cancelActions()
		withAnimation {
			game.undoOpacity = .clear
			game.prevOpacity = .clear
			game.nextOpacity = .clear
		}
		
		game.timers.append(Timer.after(0.3) {
			withAnimation {
				hideBoard = true
			}
			BoardScene.main.rotate(right: false)
		})
		
		game.timers.append(Timer.after(0.6) {
			if rematch { game.loadRematch() }
			else { game.loadNextGame() }
		})
		
		game.timers.append(Timer.after(0.8) {
			withAnimation {
				hideBoard = false
			}
			BoardScene.main.rotate(right: false)
		})
		
		game.timers.append(Timer.after(1.2) {
			game.startGame()
		})
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
        let myHint: HintValue?
		let opHint: HintValue?
		if game.currentMove == nil {
			myHint = .noW
			opHint = .noW
		} else if game.turn == game.myTurn {
			myHint = game.currentMove?.nHint
			opHint = game.currentMove?.oHint
		} else {
			myHint = game.currentMove?.oHint
			opHint = game.currentMove?.nHint
		}
        currentSolveType = game.currentMove?.solveType
        
        hintPickerContent = [
            [("blocks", opHint ?? .noW != .noW),
             ("wins", myHint ?? .noW != .noW)],
            ["all", "best", "off"]
        ]
        
        switch opHint {
        case .w0:   opText = ["4 in a row", "Your opponent won the game, better luck next time!"]
        case .w1:   opText = ["3 in a row","Your opponent has 3 in a row, so now they can fill in the last move in that line and win!"]
        case .w2d1: opText = ["checkmate", "Your opponent can get two checks with their next move, and you can’t block both!"]
        case .w2:   opText = ["2nd order win", "Your opponent can get to a checkmate using a series of checks! They can win in \(game.currentMove?.winLen ?? 0) moves!"]
        case .c1:   opText = ["check", "Your opponent has 3 in a row, so you should block their line to prevent them from winning!"]
        case .cm1:  opText = ["checkmate", "Your opponent has more than one check, and you can’t block them all!"]
        case .cm2:  opText = ["2nd order checkmate", "Your opponent has more than one second order check, and you can’t block them all!"]
        case .c2d1: opText = ["2nd order check", "Your opponent can get checkmate next move if you don’t stop them!"]
        case .c2:   opText = ["2nd order check", "Your opponent can get checkmate through a series of checks if you don’t stop them!"]
        case .noW:  opText = ["no wins", "Your opponent doesn't have any forced wins right now, keep it up!"]
        case nil:   opText = nil
        }
        
        switch myHint {
        case .w0:   myText = ["4 in a row", "You won the game, great job!"]
        case .w1:   myText = ["3 in a row","You have 3 in a row, so now you can fill in the last move in that line and win!"]
        case .w2d1: myText = ["checkmate", "You can get two checks with your next move, and your opponent can’t block both!"]
		case .w2:   myText = ["2nd order win", "You can get to a checkmate using a series of checks! You can win in \(game.currentMove?.winLen ?? 0) moves!"]
        case .c1:   myText = ["check", "You have 3 in a row, so you can win next turn unless it’s blocked!"]
        case .cm1:  myText = ["checkmate", "You have more than one check, and your opponent can’t block them all!"]
        case .cm2:  myText = ["2nd order checkmate", "You have more than one second order check, and your opponent can’t block them all!"]
        case .c2d1: myText = ["2nd order check", "You can get checkmate next move if your opponent doesn’t stop you!"]
        case .c2:   myText = ["2nd order check", "You can get checkmate through a series of checks if your opponent doesn’t stop you!"]
        case .noW:  myText = ["no wins", "You don't have any forced wins right now, keep working to set one up!"]
        case nil:   myText = nil
        }
        
        hintText = [opText, myText]
    }
    
    var hintContent: some View {
        ZStack {
            if game.hints {
                // HPickers
                VStack(spacing: 0) {
                    Spacer()
                    HPicker(content: $hintPickerContent, dim: (60, 50), selected: $hintSelection, action: onSelection)
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
                    Blank(15)
                    if let text = hintText[hintSelection[0]] {
                        Text(text[0]).bold()
                        Blank(4)
                        Text(text[1]).multilineTextAlignment(.center)
                    } else {
                        Spacer()
                        Text("loading...").bold()
                    }
                    Spacer()
                    Text("show moves")
                    Blank(34)
                    Text("hints for")
                    Blank(36)
                }.padding(.horizontal, 40)
                VStack {
                    if solveButtonsEnabled { solveButtons }
                    Spacer()
                }
            } else {
                if game.mode.solve {
                    if game.solved {
                        VStack(spacing: 20) {
                            Text("you previously solved this puzzle, do you want to enable hints?")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Button("enable") { game.hints = true }
                                .buttonStyle(Solid())
                        }
                    } else {
                        Text("hints are not available on solve boards until they are solved!")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    Text("hints are only available in sandbox mode or after games!")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
    
    func onSelection(row: Int, component: Int) {
        withAnimation {
            if component == 1 { // changing show
                if row < 2 {
                    game.showHintFor = hintSelection[0]
					game.showAllHints = row == 0
                    game.hideHintCard()
                } else {
                    game.showHintFor = nil
                }
            } else {            // changing blocks/wins
                hintSelection[1] = 2
                game.showHintFor = nil
            }
        }
        BoardScene.main.spinMoves()
    }
    
    struct PlayerName: View {
        let turn: Int
        @ObservedObject var game: Game
        @Binding var text: [String]?
        var color: Color { .of(n: game.player[turn].color) }
        var rounded: Bool { game.player[turn].rounded }
        var glow: Color { game.realTurn == turn ? color : .clear }
        var timerOpacity: Opacity { game.totalTime == nil ? .clear : (game.realTurn == turn ? .full : .half) }
        
        var body: some View {
            VStack(spacing: 3) {
                ZStack {
                    Text(game.showHintFor == turn^game.myTurn^1 ? text?[0] ?? "loading..." : "")
                        .animation(.none)
                        .multilineTextAlignment(.center)
                        .frame(height: 45)
                    Text(game.player[turn].name)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .foregroundColor(.white)
                        .frame(minWidth: 140, maxWidth: 160, minHeight: 40)
                        .background(Rectangle().foregroundColor(color))
                        .cornerRadius(rounded ? 100 : 4)
                        .shadow(color: glow, radius: 8, y: 0)
                        .animation(.easeIn(duration: 0.3))
                        .rotation3DEffect(game.showHintFor == turn^game.myTurn^1 ? .radians(.pi/2) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .top)
                }
                Text(String(format: "%01d:%02d", (game.currentTimes[turn]/60) % 100, game.currentTimes[turn] % 60))
                    .opacity(timerOpacity.rawValue)
            }
        }
    }
    
    var animation = Animation.linear.delay(0)
    
//    func showStreak() {
//        withAnimation {
//            
//        }
//    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: Game())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (1st generation)"))
    }
}
