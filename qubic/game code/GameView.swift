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
    @ObservedObject var data: GameData = GameData()
    var switchBack: () -> Void = { return }
    let boardRep: BoardViewRep
    @State var cubeHeight: CGFloat = 10
    
    init(_ preset: [Int] = [], _ switchBackFunc: @escaping () -> Void) {
        switchBack = switchBackFunc
        boardRep = BoardViewRep()
        let newData = GameData(preset: preset)
        data = newData
        boardRep.load(newData)
    }
    
    var body: some View {
        ZStack {
            boardRep
    //            .frame(height: 800)
                .gesture(DragGesture()
                    .onEnded { drag in
                        let h = drag.predictedEndTranslation.height
                        let w = drag.predictedEndTranslation.width
                        if abs(w)/abs(h) > 1 {
                            self.boardRep.rotate(right: w > 0)
                        } else if h > 0 {
                            self.switchBack()
                        }
                    }
                )
            VStack {
                if data.turn == data.myTurn { Spacer() }
                HStack {
                    Image(data.turn == data.myTurn ? "blueCube" : "pinkCube")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Spacer()
                }
                if data.turn != data.myTurn { Spacer() }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView([3]) {}
    }
}
