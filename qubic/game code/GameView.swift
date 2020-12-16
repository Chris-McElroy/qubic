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
    @ObservedObject var board: BoardScene // TODO do i still need to observe this?
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
        
        VStack(spacing: 0) {
            HStack {
                PlayerName(turn: 0, data: board.data)
                Spacer().frame(minWidth: 15, maxWidth: 80)
                PlayerName(turn: 1, data: board.data)
            }.padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .zIndex(1.0)
            BoardView(boardScene: board)
                .onAppear { board.load() }
                .gesture(DragGesture()
                    .onEnded { drag in
                        let h = drag.predictedEndTranslation.height
                        let w = drag.predictedEndTranslation.width
                        if abs(w)/abs(h) > 1 {
                            board.rotate(right: w > 0)
                        } else if h > 0 {
                            board.goBack()
                        }
                    }
                )
                .zIndex(0.0)
                .alert(isPresented: $board.showDCAlert) {
                    Alert(title: Text("Enable Badges"),
                          message: Text("Allow 4Play to show a badge when a daily challenge is available?"),
                          primaryButton: .default(Text("OK"), action: {
                                Notifications.turnOn()
                          }),
                          secondaryButton: .cancel())
                }
        }
    }
    
    struct PlayerName: View {
        let turn: Int
        @ObservedObject var data: GameData
        var color: Color { .primary(data.player[turn].color) }
        
        var body: some View {
            Text(data.player[turn].name)
                .lineLimit(1)
                .padding(.horizontal, 5)
                .foregroundColor(.white)
                .frame(minWidth: 140, maxWidth: 160, minHeight: 40)
                .background(Rectangle().foregroundColor(color))
                .cornerRadius(100)
                .shadow(color: data.turn == turn ? color : .clear, radius: 8, y: 0)
                .animation(.easeIn(duration: 0.3))
        }
    }
    
    var animation = Animation.linear.delay(0)
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(board: BoardScene())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (1st generation)"))
    }
}
