//
//  Master.swift
//  qubic
//
//  Created by 4 on 10/11/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

struct Master: AI {
    func getMove(for board: Board) -> Int {
        let n = getTurn(for: board)
        let o = inc(n)
        var options = board.get1stOrderWinsFor(n)
        if options.isEmpty { options = board.get1stOrderWinsFor(o) }
        if options.isEmpty {
            options = Array(0..<64)
            options.removeAll { board.pointFull($0) }
        }
        return options.randomElement() ?? 0
    }
    
    private func getTurn(for board: Board) -> Int {
        return board.move[0].count - board.move[1].count
    }
}
