//
//  Daily.swift
//  qubic
//
//  Created by 4 on 12/16/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Daily: Player {
    override init(b: Board, n: Int) {
        let format = DateFormatter()
        format.dateStyle = .short
        let name = format.string(from: Date())
        
        super.init(b: b, n: n, name: name, color: 1,
                   wins:            [Array(repeating: 2.0, count: 76),
                                     Array(repeating: 2.0, count: 76)],
                   o1CheckMates:    [Array(repeating: 2.0, count: 76),
                                     Array(repeating: 2.0, count: 76)],
                   o1Checks:        [Array(repeating: 0.0, count: 76),
                                     Array(repeating: 0.0, count: 76)])
    }
    
    override func getPause() -> Double {
        .random(in: b.hasO1Check(n^1) ? 0.6..<1.0 : 1.8..<2.5)
    }
    
    override func unforcedHeuristic() -> Int {
        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
        return rich.isEmpty ? poor.randomElement() ?? 0 : rich.randomElement() ?? 0
    }
}
