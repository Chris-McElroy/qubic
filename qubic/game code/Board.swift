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
    
    func getTurn() -> Int { move[0].count - move[1].count }
    func nextTurn() -> Int {  1 - move[0].count + move[1].count }
    func numMoves() -> Int { move[0].count + move[1].count }
    
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
    
    func addMove(_ p: Int) {
        addMove(p, for: getTurn())
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
        guard let p = move[n].popLast() else { return }
        board[n] ^= (1 << p)
        for line in Board.linesThruPoint[p] {
            if var s = status[line] {
                var openPoints = open[s].removeValue(forKey: line)!
                openPoints.append(p)
                s -= 2*n-1
                open[s][line] = openPoints.sorted()
                status[line] = s
            } else {
                var openPoints: [Int] = []
                var p0Moves = false
                var p1Moves = false
                for p in Board.pointsInLine[line] {
                    if (board[0] &>> p) & 1 == 1 {
                        p0Moves = true
                    } else if (board[1] &>> p) & 1 == 1 {
                        p1Moves = true
                    } else {
                        openPoints.append(p)
                    }
                }
                if p0Moves && p1Moves {
                    status[line] = nil
                } else {
                    status[line] = p0Moves ? openPoints.count : (8 - openPoints.count)
                    open[status[line]!][line] = openPoints
                }
            }
        }
    }
    
//    func processMove(_ p: Int) -> Bool {
//        guard (0..<64).contains(p) else { return false }
//        guard pointEmpty(p) else { return false }
//        addMove(p, for: getTurn())
//        return true
        
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
//    }
    
    func getWinLines() -> [Int?] {
        var wins: [Int?] = Array(repeating: nil, count: 76)
        getW0(for: 0).forEach { wins[$0] = 0 }
        getW0(for: 1).forEach { wins[$0] = 1 }
        
        return wins
    }
}
