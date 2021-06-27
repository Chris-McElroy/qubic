//
//  Common.swift
//  qubic
//
//  Created by 4 on 12/16/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

// TODO make this harder (but realistic)
class Common: Player {
    init(b: Board, n: Int, num: Int) {
        super.init(b: b, n: n, name: num == commonBoards.count ? "common ?" : "common \(num+1)", color: 8,
                   lineP: [3: 1.0, -3: 1.0, 2: 1.0],
                   dirStats: Array(repeating: 1.0, count: 76),
                   depth: 6,
                   w2BlockP: 1.0,
                   lineScore: [0,2,2,2,1,2,2,2,0], // my points on the left
                   bucketP: 0.8)
    }
    
    override func getPause() -> Double {
        .random(in: b.hasW1(n^1) ? 0.8..<1.2 : 2.0..<3.0)
    }
    
//    override func unforcedHeuristic() -> Int {
//        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
//        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
//        let bias = 8.0*Double(rich.count)/(0.001+Double(poor.count))
//        if poor.isEmpty { return rich.randomElement() ?? 0}
//        if rich.isEmpty { return poor.randomElement() ?? 0}
//        return .random(in: 0...1) < (bias/(1+bias)) ? rich.randomElement() ?? 0 : poor.randomElement() ?? 0
//    }
}
