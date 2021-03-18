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
    @State var selected = [1,1,0]
    let game: Game
    let menuText = [[("local",false),("online",false),("invite",false)],
                    [("first",false),("random",false),("second",false)],
                    [("challenge",false),("sandbox",false)]]
    
    var body: some View {
        if view == .play {
            GameView(game: game)
                .onAppear { game.load(mode: .play, turn: Int.random(in: 0...1)) }
        } else if view == .playMenu {
            VStack(spacing: 0) {
                Spacer()
                HPicker(content: menuText, dim: (90, 55), selected: $selected, action: {_,_ in })
                    .frame(height: 180)
                    .opacity(view == .playMenu ? 1 : 0)
            }
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(view: .constant(.main), game: Game())
    }
}
