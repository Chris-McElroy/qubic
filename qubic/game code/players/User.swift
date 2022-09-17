//
//  User.swift
//  qubic
//
//  Created by 4 on 12/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

class User: Player {
	init(b: Board, n: Int, id: String? = nil, name: String? = nil) {
		super.init(b: b, n: n, id: id ?? myID, name: name ?? (Storage.string(.name) ?? "you"), color: Storage.int(.color), rounded: true)
    }
    
    override func move() {
        premove()
    }
    
    func move(at p: Int) {
        if Game.main.reviewingGame {
            Game.main.processGhostMove(p)
        } else if Game.main.gameState == .active {
            if Game.main.premoves.isEmpty {
                Game.main.checkAndProcessMove(p, for: n, setup: b.getSetup())
            }
        }
    }
    
    func premove() {
        if Game.main.turn == n {
            if !Game.main.premoves.isEmpty {
                let p = Game.main.premoves.removeFirst()
				// clause for allowing checkmate premoves
				if let nextP = Game.main.premoves.first, b.pointFull(p) && b.getW1(for: n).contains(nextP) {
					Game.main.premoves = []
					BoardScene.main.spinMoves()
					Game.main.checkAndProcessMove(nextP, for: n, setup: b.getSetup())
				} else if (b.hasW1(n) != b.getW1(for: n).contains(p)) || b.pointFull(p) {
					Game.main.notificationGenerator.notificationOccurred(.error)
                    Game.main.premoves = []
					Game.main.processingMove = true
					Game.main.timers.append(Timer.after(1) { Game.main.processingMove = false })
					BoardScene.main.spinMoves()
                } else {
					BoardScene.main.spinMoves()
                    Game.main.checkAndProcessMove(p, for: n, setup: b.getSetup())
                }
            }
        }
    }
}
