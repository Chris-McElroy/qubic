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
    @ObservedObject var game: Game
    @State var cubeHeight: CGFloat = 10
    @State var rotateMe = false
    @State var isRotated = false
    @State var cont = false
    @State var hintSelection = [1,1]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    PlayerName(turn: 0, game: game)
                    Spacer().frame(minWidth: 15, maxWidth: 80)
                    PlayerName(turn: 1, game: game)
                }.padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .zIndex(1.0)
                BoardView(boardScene: game.boardScene!)
                    .gesture(DragGesture()
                        .onEnded { drag in
                            let h = drag.predictedEndTranslation.height
                            let w = drag.predictedEndTranslation.width
                            if abs(w)/abs(h) > 1 {
                                game.boardScene?.rotate(right: w > 0)
                            } else if h > 0 {
                                game.goBack()
                            } else {
                                withAnimation {
                                    game.hintCard = true
                                }
                                if game.hintText == nil {
                                    hintSelection[1] = 1
                                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                        game.updateHintText()
                                    }
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
    }
    
    var hintContent: some View {
        ZStack {
            if let text = game.hintText {
                // HPickers
                VStack(spacing: 0) {
                    Spacer()
                    HPicker(content: [[("blocks", false), ("wins", false)],[("on",false),("off",false)]], dim: (60, 50), selected: $hintSelection, action: onSelection)
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
                    Text(text[hintSelection[0]][0]).bold()
                    Blank(4)
                    Text(text[hintSelection[0]][1]).multilineTextAlignment(.center)
                    Spacer()
                    Text("show moves")
                    Blank(34)
                    Text("hints for")
                    Blank(36)
                }.padding(.horizontal, 40)
            } else {
                if game.hints {
                    Text("loading...")
                } else {
                    Text("hints are only\navailable in sandbox mode!")
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    func onSelection(row: Int, component: Int) {
        print("selected", row, component, hintSelection[0])
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
        var color: Color { .primary(game.player[turn].color) }
        var glow: Color {
            if let winner = game.winner {
                return winner == turn ? color : .clear
            } else {
                return game.turn == turn ? color : .clear
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
                    .cornerRadius(100)
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
