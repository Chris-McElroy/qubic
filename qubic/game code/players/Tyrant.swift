//
//  Tyrant.swift
//  qubic
//
//  Created by 4 on 12/28/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Tyrant: Player {
    override init(b: Board, n: Int) {
        super.init(b: b, n: n, name: "tyrant", color: 6,
                   lineP: [3: 1.96, -3: 2.2, 2: 1.0],
                   dirStats: Player.setStats(hs: 1.0, vs: 1.0, hd: 1.0, vd: 0.98, md: 1.0),
                   depth: 5,
                   w2BlockP: 1.0,
                   lineScore: [0,0,1,10,1,3,5,0,0], // my points on the left
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
