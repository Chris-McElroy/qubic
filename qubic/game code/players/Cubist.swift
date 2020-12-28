//
//  Cubist.swift
//  qubic
//
//  Created by 4 on 10/11/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Cubist: Player {
    override init(b: Board, n: Int) {
        super.init(b: b, n: n, name: "cubist", color: 3,
                   lineP: [3: 1.0, -3: 1.0, 2: 1.0],
                   dirStats: Player.setStats(hs: 1.0, vs: 1.0, hd: 0.9, vd: 0.9, md: 1.0),
                   depth: 10,
                   w2BlockP: 1.0,
                   lineScore: [0,0,-3,8,3,4,1,0,0], // my points on the left
                   bucketP: 1.0)
    }
    
    override func getPause() -> Double {
        0.2
    }
}

