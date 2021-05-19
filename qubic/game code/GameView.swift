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
    @State var cubeHeight: CGFloat = 10
    @State var rotateMe = false
    @State var isRotated = false
    @State var cont = false
    @State var hintSelection = [1,1]
    @State var hintPickerContent: [[Any]] = [
        [("blocks", false), ("wins", false)],
        [("on",false),("off",false)]
    ]
    @State var hintText: [[String]?] = [nil, nil]
    @State var currentSolveType: SolveType? = nil
    @State var hideAll: Bool = true
    @State var hideBoard: Bool = true
    @State var centerNames: Bool = true
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    PlayerName(turn: 0, game: game)
                    Spacer().frame(minWidth: 15).frame(width: centerNames ? 15 : nil)
                    PlayerName(turn: 1, game: game)
                }.padding(.horizontal, 22)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .zIndex(1.0)
                .offset(y: centerNames ? Layout.main.safeHeight/2 - 50 : 0)
                if game.hints && solveButtonsEnabled { solveButtons }
                BoardView()
                    .gesture(DragGesture()
                        .onEnded { drag in
                            let h = drag.predictedEndTranslation.height
                            let w = drag.predictedEndTranslation.width
                            if abs(w)/abs(h) > 1 {
                                BoardScene.main.rotate(right: w > 0)
                            } else if h > 0 {
                                game.goBack()
                            } else {
                                if game.showHintCard() {
                                    hintSelection[1] = 1
                                }
                            }
                        }
                    )
                    .zIndex(0.0)
                    .alert(isPresented: $game.showDCAlert) {
                        Alert(title: Text("Enable Badges"),
                              message: Text("Allow 4Play to show a badge when a daily challenge is available?"),
                              primaryButton: .default(Text("OK"), action: {
                                    Notifications.turnOn()
                              }),
                              secondaryButton: .cancel())
                    }
                    .opacity(hideBoard ? 0 : 1)
            }
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Fill()
                        .shadow(radius: 20)
                    hintContent
                    
                }.frame(height: 240)
            }.offset(y: game.hintCard ? 0 : 300)
        }
        .opacity(hideAll ? 0 : 1)
        .onAppear {
            Game.main.newHints = refreshHintPickerContent
            animateIntro()
        }
    }
    
    func animateIntro() {
        hideAll = true
        hideBoard = true
        centerNames = true
        BoardScene.main.rotate(right: true)
        Game.main.timers.append(Timer.after(0.1) {
            withAnimation {
                hideAll = false
            }
        })
        Game.main.timers.append(Timer.after(1) {
            withAnimation {
                centerNames = false
            }
        })
        Game.main.timers.append(Timer.after(1.1) {
            withAnimation {
                hideBoard = false
            }
            BoardScene.main.rotate(right: false)
        })
        Game.main.timers.append(Timer.after(1.5) {
            game.startGame()
        })
    }
    
    var solveButtons: some View {
        HStack {
            Button("daily1") { if currentSolveType == .d1 { Game.main.uploadSolveBoard("d1") } }
                .opacity(currentSolveType == .d1 ? 1.0 : 0.3)
            Spacer()
            Button("daily2") { if currentSolveType == .d2 { Game.main.uploadSolveBoard("d2") } }
                .opacity(currentSolveType == .d2 ? 1.0 : 0.3)
            Spacer()
            Button("daily3") { if currentSolveType == .d3 { Game.main.uploadSolveBoard("d3") } }
                .opacity(currentSolveType == .d3 ? 1.0 : 0.3)
            Spacer()
            Button("daily4") { if currentSolveType == .d4 { Game.main.uploadSolveBoard("d4") } }
                .opacity(currentSolveType == .d4 ? 1.0 : 0.3)
            Spacer()
            Button("tricky") { if currentSolveType == .tr { Game.main.uploadSolveBoard("tr") } }
                .opacity(currentSolveType == .tr ? 1.0 : 0.3)
        }.padding(.horizontal, 30)
    }
    
    func refreshHintPickerContent() {
        let myHint: HintValue? = game.currentMove == nil ? .noW : game.currentMove?.myHint
        let opHint: HintValue? = game.currentMove == nil ? .noW : game.currentMove?.opHint
        currentSolveType = game.currentMove?.solveType
        
        hintPickerContent = [
            [("blocks", opHint ?? .noW != .noW),
             ("wins", myHint ?? .noW != .noW)],
            [("on",false),("off",false)]
        ]
        
        let opText: [String]?
        switch opHint {
        case .w0:   opText = ["4 in a row", "Your opponent won the game, better luck next time!"]
        case .w1:   opText = ["3 in a row","Your opponent has 3 in a row, so now they can fill in the last move in that line and win!"]
        case .w2d1: opText = ["checkmate", "Your opponent can get two checks with their next move, and you can’t block both!"]
        case .w2:   opText = ["second order win", "Your opponent can get to a checkmate using a series of checks!"]
        case .c1:   opText = ["check", "Your opponent has 3 in a row, so you should block their line to prevent them from winning!"]
        case .cm1:  opText = ["checkmate", "Your opponent has more than one check, and you can’t block them all!"]
        case .cm2:  opText = ["second order checkmate", "Your opponent has more than one second order check, and you can’t block them all!"]
        case .c2d1: opText = ["second order check", "Your opponent can get checkmate next move if you don’t stop them!"]
        case .c2:   opText = ["second order check", "Your opponent can get checkmate through a series of checks if you don’t stop them!"]
        case .noW:  opText = ["no wins", "Your opponent doesn't have any forced wins right now, keep it up!"]
        case nil:   opText = nil
        }
        
        let myText: [String]?
        switch myHint {
        case .w0:   myText = ["4 in a row", "You won the game, great job!"]
        case .w1:   myText = ["3 in a row","You have 3 in a row, so now you can fill in the last move in that line and win!"]
        case .w2d1: myText = ["checkmate", "You can get two checks with your next move, and your opponent can’t block both!"]
        case .w2:   myText = ["second order win", "You can get to a checkmate using a series of checks!"]
        case .c1:   myText = ["check", "You have 3 in a row, so you can win next turn unless it’s blocked!"]
        case .cm1:  myText = ["checkmate", "You have more than one check, and your opponent can’t block them all!"]
        case .cm2:  myText = ["second order checkmate", "You have more than one second order check, and your opponent can’t block them all!"]
        case .c2d1: myText = ["second order check", "You can get checkmate next move if your opponent doesn’t stop you!"]
        case .c2:   myText = ["second order check", "You can get checkmate through a series of checks if your opponent doesn’t stop you!"]
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
            } else {
                if game.mode.solve {
                    Text("hints are not available on solve boards until they are solved!")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                } else {
                    Text("hints are only available in sandbox mode or after games!")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
    
    func onSelection(row: Int, component: Int) {
        if component == 1 { // changing show
            if row == 0 {
                game.showMoves(for: hintSelection[0] == 1 ? game.myTurn : game.myTurn^1)
            } else {
                game.showMoves(for: nil)
            }
        } else { // changing blocks/wins
            hintSelection[1] = 1
            game.showMoves(for: nil)
        }
    }
    
    struct PlayerName: View {
        let turn: Int
        @ObservedObject var game: Game
        // TODO why are these vars?
        var color: Color { .primary(game.player[turn].color) }
        var rounded: Bool { game.player[turn].rounded }
        var glow: Color {
            if let winner = game.winner {
                return winner == turn ? color : .clear
            } else {
                return game.moves.count % 2 == turn ? color : .clear
            }
        }
        
        var body: some View {
            ZStack {
                Text(game.newStreak != nil ? "\(game.newStreak ?? 0) day streak!" : "")
                Text(game.player[turn].name)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.white)
                    .frame(minWidth: 140, maxWidth: 160, minHeight: 40)
                    .background(Rectangle().foregroundColor(color))
                    .cornerRadius(rounded ? 100 : 4)
                    .shadow(color: glow, radius: 8, y: 0)
                    .animation(.easeIn(duration: 0.3))
                    .rotation3DEffect(game.newStreak != nil && game.winner != turn ? .radians(.pi/2) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .top)
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
