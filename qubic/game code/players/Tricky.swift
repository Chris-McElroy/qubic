//
//  Tricky.swift
//  qubic
//
//  Created by 4 on 12/16/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

// TODO make this harder
class Tricky: Player {
    init(b: Board, n: Int, num: Int) {
        super.init(b: b, n: n, name: "tricky \(num+1)", color: 4,
                   wins:            [Array(repeating: 2.0, count: 76),
                                     Array(repeating: 2.0, count: 76)],
                   o1CheckMates:    [Array(repeating: 2.0, count: 76),
                                     Array(repeating: 2.0, count: 76)],
                   o1Checks:        [Array(repeating: 0.0, count: 76),
                                     Array(repeating: 0.0, count: 76)])
    }
    
    override func getPause() -> Double {
        .random(in: b.hasO1Check(n^1) ? 0.4..<0.7 : 2.0..<2.1)
    }
    
    override func unforcedHeuristic() -> Int {
        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
        return rich.isEmpty ? poor.randomElement() ?? 0 : rich.randomElement() ?? 0
    }
}
