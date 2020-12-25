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
                   dirStats: Array(repeating: 1.0, count: 76),
                   depth: 8,
                   w2BlockP: 1.0,
                   lineScore: [0,0,1,8,3,4,1,0,0], // my points on the left
                   bucketP: 1.0)
//                   w1: [Array(repeating: 2.0, count: 76),
//                        Array(repeating: 2.0, count: 76)],
//                   w2: [Array(repeating: 2.0, count: 76),
//                        Array(repeating: 2.0, count: 76)],
//                   c1: [Array(repeating: 0.0, count: 76),
//                        Array(repeating: 0.0, count: 76)])
    }
    
    override func getPause() -> Double {
        0.2
        // Double.random(in: b.has1stOrderCheck(n) ? 0.6..<1.0 : 2.0..<3.0)
    }
    
//    override func unforcedHeuristic() -> Int {
//        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
//        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
//        return rich.isEmpty ? poor.randomElement() ?? 0 : rich.randomElement() ?? 0
//    }
}

