//
//  Simple.swift
//  qubic
//
//  Created by 4 on 12/16/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

// laterDO make this better/harder
class Simple: Player {
    init(b: Board, n: Int, num: Int) {
		let localName = num == solveBoards[.simple]?.count ?? 0 ? "simple ?" : "simple \(num+1)"
		super.init(b: b, n: n, id: localName, name: localName, color: 7,
                   lineP: [3: 1.0, -3: 1.0, 2: 1.0],
                   dirStats: Array(repeating: 1.0, count: 76),
                   depth: 7,
                   w2BlockP: 1.0,
                   lineScore: [0,2,2,2,1,2,2,2,0], // my points on the left
                   bucketP: 0.8)
    }
    
    override func getPause() -> Double {
        .random(in: 1.5..<3.0)
    }
    
//    override func unforcedHeuristic() -> Int {
//        let moves = (0..<64).filter { b.pointEmpty($0) }
//        return moves.randomElement() ?? 0
//    }
}
