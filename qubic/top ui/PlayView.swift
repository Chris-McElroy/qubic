//
//  PlayView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import MessageUI

struct PlayView: View {
    @Binding var view: ViewStates
    @Binding var selected: [Int]
    let game: Game
    var menuText = [[("local",false),("online",false),("invite",false)],
                    [("first",false),("random",false),("second",false)],
                    [("sandbox",false),("challenge",false)]]
    
    var body: some View {
        if view == .play {
            GameView(game: game)
                .onAppear { game.load(mode: mode, turn: turn, hints: hints) }
        } else if view == .playMenu {
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    HPicker(content: menuText, dim: (90, 55), selected: $selected, action: onSelection)
                        .frame(height: 180)
                }
                VStack {
                    Fill()
                        .opacity(selected[0] == 1 ? 0.8 : 0.0)
                        .animation(.linear(duration: 0.15))
                    Blank(120)
                }
            }.onAppear {
                FB.main.op = nil
            }
        }
    }
    
    var mode: GameMode {
        switch selected[0] {
        case 0: return .local
        case 1: return .online
        default: return .invite
        }
    }
    
    var turn: Int {
        switch selected[1] {
        case 0: return 0
        case 2: return 1
        default: return Int.random(in: 0...1)
        }
    }
    
    var hints: Bool {
        selected[2] == 0 && mode != .online
    }
    
    func onSelection(row: Int, component: Int) {
        // use this to make the hidey box go up and down?
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(view: .constant(.main), selected: .constant([0,0,0]), game: Game())
    }
}
