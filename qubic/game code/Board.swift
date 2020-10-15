//
//  Board.swift
//  qubic
//
//  Created by 4 on 8/29/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Board {
    var move: [[Int]] = [[],[]]
    var board: [UInt64] = [0,0]
    var doubles: [Set<Int>] = [[],[]]
    var status: [[Int]] = Array(repeating: Array(repeating: 0, count: 76), count: 2)
    var dTable: [D] = []
    
    func inc(_ n: Int) -> Int { 1 - n }
    func getTurn() -> Int {  move[0].count - move[1].count }
    func nextTurn() -> Int {  1 - move[0].count + move[1].count }
    
    func pointEmpty(_ p: Int) -> Bool { (((board[0] | board[1]) &>> p) & 1) == 0 }
    func pointFull(_ p: Int) -> Bool { (((board[0] | board[1]) &>> p) & 1) == 1 }
    
    func addMove(_ p: Int) {
        let n = move[0].count - move[1].count
        let o = inc(n)
        move[n].append(p)
        board[n] |= (1 << p)
        for line in Board.linesThruPoint[p] {
            status[n][line] += 1
            if status[n][line] == 2 && status[o][line] == 0 {
                doubles[n].insert(line)
            }
        }
    }
    
    func undoMove() {
        let o = move[0].count - move[1].count
        let n = inc(o)
        let p = move[n].popLast()!
        board[n] ^= (1 << p)
        for line in Board.linesThruPoint[p] {
            doubles[n].remove(line)
            status[n][line] -= 1
            if status[n][line] == 2 && status[o][line] == 0 {
                doubles[n].insert(line)
            }
        }
    }
    
    func processMove(_ p: Int) -> [WinLine]? {
        guard (0..<64).contains(p) else { return nil }
        guard pointEmpty(p) else { return nil }
        let n = getTurn()
        addMove(p)
        var winLines: [WinLine] = []
        if has1stOrderWin(n) {
            for line in Board.linesThruPoint[p] {
                if status[n][line] == 4 {
                    let points = Board.pointsInLine[line]
                    winLines.append(WinLine(start: points[0], end: points[3], line: line))
                }
            }
        }
        return winLines
    }
}
