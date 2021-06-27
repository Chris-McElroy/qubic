//
//  User.swift
//  qubic
//
//  Created by 4 on 12/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

class User: Player {
    init(b: Board, n: Int, name: String? = nil) {
        var username = UserDefaults.standard.string(forKey: Key.name) ?? "you"
        if let name = name {
            username = name
        }
        super.init(b: b, n: n, name: username, color: UserDefaults.standard.integer(forKey: Key.color), rounded: true)
    }
    
    override func move() {
        premove()
    }
    
    func move(at p: Int) {
        if Game.main.replayMode {
            Game.main.processGhostMove(p)
        } else if Game.main.winner == nil {
            if Game.main.premoves.isEmpty {
                Game.main.processMove(p, for: n, num: b.numMoves())
            }
        }
    }
    
    func premove() {
        if Game.main.turn == n {
            if !Game.main.premoves.isEmpty {
                let p = Game.main.premoves.removeFirst()
                if (b.hasW1(n) != b.getW1(for: n).contains(p)) || b.pointFull(p) {
                    Game.main.premoves = []
                } else {
                    Game.main.processMove(p, for: n, num: b.numMoves())
                }
            }
            BoardScene.main.spinMoves()
        }
    }
}
