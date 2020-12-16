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
        super.init(b: b, n: n, name: "common \(num+1)", color: 3,
                   wins:            [Array(repeating: 2.0, count: 76),
                                     Array(repeating: 2.0, count: 76)],
                   o1CheckMates:    [Array(repeating: 2.0, count: 76),
                                     Array(repeating: 2.0, count: 76)],
                   o1Checks:        [Array(repeating: 0.0, count: 76),
                                     Array(repeating: 0.0, count: 76)])
    }
    
    override func getPause() -> Double {
        .random(in: b.hasO1Check(n^1) ? 0.8..<1.2 : 2.0..<3.0)
    }
    
    override func unforcedHeuristic() -> Int {
        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
        let bias = 8.0*Double(rich.count)/(0.001+Double(poor.count))
        if poor.isEmpty { return rich.randomElement() ?? 0}
        if rich.isEmpty { return poor.randomElement() ?? 0}
        return .random(in: 0...1) < (bias/(1+bias)) ? rich.randomElement() ?? 0 : poor.randomElement() ?? 0
    }
}
