//
//  Online.swift
//  qubic
//
//  Created by Chris McElroy on 3/24/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation

class Online: Player {
    override init(b: Board, n: Int) {
		let data = FB.main.op ?? FB.PlayerData(name: "error", color: 1)
		super.init(b: b, n: n, name: data.name, color: data.color, rounded: true, local: false)
    }
    
    override func move() {
		let setup = b.getSetup()
		FB.main.gotOnlineMove = { move, time, num in
			Game.main.processMove(move, for: self.n, setup: setup, time: time)
		}
    }
}
