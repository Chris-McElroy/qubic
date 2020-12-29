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
    @ObservedObject var game: Game // TODO do i still need to observe this?
    @State var cubeHeight: CGFloat = 10
    @State var rotateMe = false
    @State var isRotated = false
    @State var cont = false
    
    var body: some View {
//        VStack(spacing: 20) {
//            // 1
//            Button("Rotate") {
//                self.isRotated = true
//                print(cont)
//                self.cont.toggle()
//            }
//            // 2
//            Rectangle()
//                .foregroundColor(.green)
//                .frame(width: 200, height: 200)
//                .rotationEffect(Angle.degrees(isRotated && cont ? 360 : 0))
//                .animation(cont ? animation : .default)
//        }
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
                                withAnimation { game.hintCard = true }
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
            VStack {
                Spacer()
                ZStack {
                    Fill()
                        .shadow(radius: 20)
                    VStack(spacing: 10) {
                        Spacer()
                        Text("threats    wins             ")
                        Spacer()
                        Text("open check").bold()
                        Text("Your opponent did not answer your check, so you are free to take the last move in that line and win!")
                        Spacer()
                        Text("possible wins")
                        Text("show    hide          ")
                        Spacer()
                    }.padding(.horizontal, 40)
                }.frame(height: 260)
            }.offset(y: game.hintCard ? 0 : 300)
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
