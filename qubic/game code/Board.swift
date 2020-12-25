//
//  Board.swift
//  qubic
//
//  Created by 4 on 8/29/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Board {
    var move: [[Int]]
    var board: [UInt64]
    var open: [[Int: [Int]]]
    var status: [Int?]
    
    func getTurn() -> Int {  move[0].count - move[1].count }
    func nextTurn() -> Int {  1 - move[0].count + move[1].count }
    
    func pointEmpty(_ p: Int) -> Bool { (((board[0] | board[1]) &>> p) & 1) == 0 }
    func pointFull(_ p: Int) -> Bool { (((board[0] | board[1]) &>> p) & 1) == 1 }
    
    init() {
        move = [[],[]]
        board = [0,0]
        open = Array(repeating: Dictionary(minimumCapacity: 76), count: 9)
        status = Array(repeating: 4, count: 76)
        Board.pointsInLine.enumerated().forEach { (i,points) in open[4][i] = points } // TODO add to static Board helper
        
    }
    
    init(_ other: Board) {
        move = other.move
        board = other.board
        open = other.open
        status = other.status
    }
    
    func addMove(_ p: Int, for n: Int) {
        move[n].append(p)
        board[n] |= (1 << p)
        for line in Board.linesThruPoint[p] {
            if let s = status[line] {
                var openPoints = open[s][line]!
                openPoints.removeAll(where: { $0 == p })
                open[s][line] = nil
                if s == 4 || ((s > 4) == (n == 1)) {
                    status[line]! += 2*n-1
                    open[status[line]!][line] = openPoints
                } else {
                    status[line] = nil
                }
            }
        }
    }
    
    func undoMove(for n: Int) {
        let p = move[n].popLast()!
        board[n] ^= (1 << p)
        for line in Board.linesThruPoint[p] {
            if let s = status[line] {
                var openPoints = open[s][line]!
                openPoints.append(p)
                open[s][line] = nil
                status[line]! -= 2*n-1
                open[status[line]!][line] = openPoints
            } else {
                var openPoints: [Int] = []
                var lineNum: UInt64 = 0
                for point in Board.pointsInLine[line] {
                    lineNum |= 1 << point
                    if pointEmpty(point) {
                        openPoints.append(point)
                    }
                }
                if board[0] & lineNum == 0 || board[1] & lineNum == 0 {
                    status[line] = 4 + (2*n - 1)*(4 - openPoints.count)
                    open[status[line]!][line] = openPoints
                } else {
                    status[line] = nil
                }
            }
        }
    }
    
    func processMove(_ p: Int) -> [WinLine]? {
        guard (0..<64).contains(p) else { return nil }
        guard pointEmpty(p) else { return nil }
        let n = getTurn()
        addMove(p, for: n)
        
//        var printed = false
//        for d in 1..<10 {
//            let w2 = (hasW2(0, depth: d), false)
//            if w2.0 || w2.1 {
//                print("\(d):", w2.0, w2.1)
//                printed = true
//                break
//            }
//        }
//        if !printed { print("nothing") }
        
        var winLines: [WinLine] = []
        for line in getW0(for: n) {
            let points = Board.pointsInLine[line]
            winLines.append(WinLine(start: points[0], end: points[3], line: line))
        }
        return winLines
    }
}
