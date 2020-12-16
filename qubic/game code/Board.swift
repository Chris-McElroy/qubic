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
//    var doubles: [Set<Int>] = [[],[]]
    var status: [Int] = Array(repeating: 0, count: 76)
    var dTable: [D] = []
    
    func getTurn() -> Int {  move[0].count - move[1].count }
    func nextTurn() -> Int {  1 - move[0].count + move[1].count }
    
    func pointEmpty(_ p: Int) -> Bool { (((board[0] | board[1]) &>> p) & 1) == 0 }
    func pointFull(_ p: Int) -> Bool { (((board[0] | board[1]) &>> p) & 1) == 1 }
    
    func addMove(_ p: Int) {
        let n = move[0].count - move[1].count
        move[n].append(p)
        board[n] |= (1 << p)
        for line in Board.linesThruPoint[p] {
            status[line] += 1 + 4*n
//            doubles[n].remove(line)
//            if status[n][line] == 2 && status[o][line] == 0 {
//                doubles[n].insert(line)
//            }
        }
    }
    
    func undoMove() {
        let n = (move[0].count - move[1].count)^1
        let p = move[n].popLast()!
        board[n] ^= (1 << p)
        for line in Board.linesThruPoint[p] {
            status[line] -= 1 + 4*n
//            doubles[n].remove(line)
//            if status[n][line] == 2 && status[o][line] == 0 {
//                doubles[n].insert(line)
//            }
        }
    }
    
    func processMove(_ p: Int) -> [WinLine]? {
        guard (0..<64).contains(p) else { return nil }
        guard pointEmpty(p) else { return nil }
        let n = getTurn()
        addMove(p)
        var winLines: [WinLine] = []
        if hasO1Win(n) {
            for line in Board.linesThruPoint[p] {
                if status[line] == 4*(1 + 4*n) {
                    let points = Board.pointsInLine[line]
                    winLines.append(WinLine(start: points[0], end: points[3], line: line))
                }
            }
        }
        return winLines
    }
}
