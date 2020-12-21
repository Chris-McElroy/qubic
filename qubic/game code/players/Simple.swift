//
//  Simple.swift
//  qubic
//
//  Created by 4 on 12/16/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

// TODO make this better/harder
class Simple: Player {
    init(b: Board, n: Int, num: Int) {
        super.init(b: b, n: n, name: "simple \(num+1)", color: 2, d: 1,
                   w1: [Array(repeating: 2.0, count: 76),
                        Array(repeating: 2.0, count: 76)],
                   w2: [Array(repeating: 2.0, count: 76),
                        Array(repeating: 2.0, count: 76)],
                   c1: [Array(repeating: 0.0, count: 76),
                        Array(repeating: 0.0, count: 76)])
    }
    
    override func getPause() -> Double {
        .random(in: 1.5..<3.0)
    }
    
    override func unforcedHeuristic() -> Int {
        let moves = (0..<64).filter { b.pointEmpty($0) }
        return moves.randomElement() ?? 0
    }
}
