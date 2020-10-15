//
//  Master.swift
//  qubic
//
//  Created by 4 on 10/11/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

extension Board {
    func pauseTime() -> Double {
        Double.random(in: has1stOrderCheck(nextTurn()) ? 0.6..<1.0 : 2.0..<3.0)
    }
    
    func getMasterMove() -> Int {
        let n = getTurn()
        let o = inc(n)
        var options = get1stOrderWinsFor(n)
        if options.isEmpty { options = get1stOrderWinsFor(o) }
        if options.isEmpty {
            options = Array(0..<64)
            options.removeAll { pointFull($0) }
        }
        return options.randomElement() ?? 0
    }
}
