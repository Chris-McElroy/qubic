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
	
	var cachedInDict: Bool? = nil
	var cachedDictMoves: (Int, Set<Int>)? = nil
	var cachedHasW2: [Int?] = [nil, nil]
	var cachedGetW2: [[Int: Set<Int>]] = [[:], [:]]
	var cachedGetW2Blocks: [[Int: Set<Int>]] = [[:], [:]]
    
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
        Board.pointsInLine.enumerated().forEach { (i,points) in open[4][i] = points } // laterDO add to static Board helper
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
		cachedInDict = nil
		cachedDictMoves = nil
		cachedHasW2 = [nil, nil]
		cachedGetW2 = [[:], [:]]
		cachedGetW2Blocks = [[:], [:]]
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
		cachedInDict = nil
		cachedDictMoves = nil
		cachedHasW2 = [nil, nil]
		cachedGetW2 = [[:], [:]]
		cachedGetW2Blocks = [[:], [:]]
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
    
	func getSetup() -> [Int] {
		(0..<numMoves()).map { move[$0 % 2][$0/2] }
	}
	
    func getWinLines(for p: Int) -> [Int]? {
        let lines = Board.linesThruPoint[p].filter({ status[$0] == 8 || status[$0] == 0 })
        return !lines.isEmpty || numMoves() == 64 ? lines : nil
    }
	
	func getMoveArray() -> [Int] {
		var array: [Int] = []
		for i in 0..<numMoves() {
			array.append(move[i%2][i/2])
		}
		return array
	}
    
    func getMoveString() -> String {
		String(getMoveArray().map { moveStringMap[$0] })
    }
}
