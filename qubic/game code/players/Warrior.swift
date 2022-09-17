//
//  Warrior.swift
//  qubic
//
//  Created by 4 on 12/28/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Warrior: Player {
    override init(b: Board, n: Int) {
		super.init(b: b, n: n, id: "warrior", name: "warrior", color: 0,
                   lineP: [3: 1.96, -3: 2.2, 2: 0.9],
                   dirStats: Player.setStats(hs: 1.0, vs: 1.0, hd: 0.9, vd: 0.4, md: 1.0),
                   depth: 4,
                   w2BlockP: 0.8,
                   lineScore: [0,2,4,8,1,1,1,1,0], // my points on the left
                   bucketP: 0.8)
    }
    
    override func getPause() -> Double {
        if b.getW1(for: 0).count + b.getW1(for: 0).count > 0 {
            return .random(in: 1.0..<3.0)
        }
        
        let moves = Double(b.move[0].count)
        let bottom = 0.9 + moves/10
        let top = 2.5 + moves/6
        return .random(in: bottom..<top)
    }
    
}
