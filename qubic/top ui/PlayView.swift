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
    @ObservedObject var layout = Layout.main
    @Binding var selected: [Int]
    static let onlineMenuText = [[("local",false),("online",false),("invite",false)],
                                 [("bots",false),("auto",false),("humans",false)],
                                 [("sandbox",false),("challenge",false)]]
    static let altMenuText = [[("local",false),("online",false),("invite",false)],
                              [("first",false),("random",false),("second",false)],
                              [("sandbox",false),("challenge",false)]]
    @State var menuText: [[Any]] = PlayView.onlineMenuText
    
    var body: some View {
        if layout.view == .play {
            GameView()
                .onAppear { Game.main.load(mode: mode, turn: turn, hints: hints) }
        } else if layout.view == .playMenu {
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    HPicker(content: $menuText, dim: (90, 55), selected: $selected, action: onSelection)
                        .frame(height: 180)
                }
                VStack {
                    Fill()
                        .opacity(mode == .local ? 0.0 : 0.8)
                        .animation(.linear(duration: 0.15))
                    Blank(120)
                }
            }.onAppear {
                FB.main.finishedOnlineGame(with: .error)
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
        if mode == .online { return FB.main.myGameData?.myTurn ?? Int.random(in: 0...1) }
        
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
        FB.main.cancelOnlineSearch?()
        if component == 0 {
            menuText = mode == .online ? PlayView.onlineMenuText : PlayView.altMenuText
        }
    }
    
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(selected: .constant([0,0,0]))
    }
}
