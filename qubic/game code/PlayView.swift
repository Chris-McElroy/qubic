//
//  PlayView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct PlayView: View {
    @Binding var view: ViewStates
    let board: BoardScene
    
    var body: some View {
        if view == .play {
            GameView(board: board)
                .onAppear { board.data = GameData(mode: .play, turn: Int.random(in: 0...1)) }
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(view: .constant(.main), board: BoardScene())
    }
}
