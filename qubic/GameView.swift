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
    var switchBack: () -> Void
    let board: BoardView
    
    init(_ preset: [Int] = [], _ switchBackFunc: @escaping () -> Void) {
        board = BoardView(preset)
        switchBack = switchBackFunc
    }
    
    var body: some View {
        board
//            .frame(height: 800)
            .gesture(DragGesture()
                .onEnded { drag in
                    let h = drag.predictedEndTranslation.height
                    let w = drag.predictedEndTranslation.width
                    if abs(w)/abs(h) > 1 {
                        self.board.rotate(right: w > 0)
                    } else if h > 0 {
                        self.switchBack()
                    }
                }
            )
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView([3]) {}
    }
}
