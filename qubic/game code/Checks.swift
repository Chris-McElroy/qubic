//
//  WinHelper.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

extension Board {
    
    func hasW0(_ n: Int) -> Bool {
        // returns true if player n has won
        return !open[8*n].isEmpty
    }
    
    func getW0(for n: Int) -> Set<Int> {
        // returns the lines where player n has won
        return Set(open[8*n].keys)
    }
    
    func hasW1(_ n: Int) -> Bool {
        // returns true if player n has a win
        return !open[1+6*n].isEmpty
    }
    
    func getW1(for n: Int) -> Set<Int> {
        // returns points that give player n a win
        var wins: Set<Int> = []
        for p in open[1+6*n].values {
            wins.insert(p.first!)
        }
        return wins
    }
    
    func hasC1(_ n: Int) -> Bool {
        // returns true if player n has
        // at least one option for a check
        return !open[2+4*n].isEmpty
    }
    
    func getC1(for n: Int) -> Set<Int> {
        // returns points that leave player n with
        // at least one option for a win next move
        var wins: Set<Int> = []
        for p in open[2+4*n].values {
            wins.insert(p.first!)
        }
        return wins
    }
    
    func hasW2(_ n: Int, depth: Int = 32) -> Bool {
        let o = n^1
        var stack: [Board] = [self]
        var nextStack: [Board] = []
        var seen: Set<UInt64> = [board[n]]
        let first = move[n].count
        
        for _ in 0..<depth {
            for b in stack {
                if b.hasW1(o) {
                    if b.addCheckMove(n, &nextStack, &seen, first) != nil {
                        return true
                    }
                } else {
                    if b.addAllForces(n, &nextStack, &seen, first) != nil {
                        return true
                    }
                }
            }
            stack = nextStack
            nextStack = []
        }
        return false
    }
    
    func getW2(for n: Int, depth: Int = 32) -> Set<Int> {
        let o = n^1
        var stack: [Board] = [self]
        var nextStack: [Board] = []
        var seen: Set<UInt64> = [board[n]]
        var wins: Set<Int> = []
        let first = move[n].count
        
        for _ in 0..<depth {
            for b in stack {
                if b.hasW1(o) {
                    if let p = b.addCheckMove(n, &nextStack, &seen, first) {
                        wins.insert(p)
                    }
                } else {
                    if let p = b.addAllForces(n, &nextStack, &seen, first) {
                        wins.insert(p)
                    }
                }
            }
            stack = nextStack
            nextStack = []
        }
        return wins
    }
    
    func getW2Blocks(for n: Int, depth: Int = 32) -> Set<Int>? {
        var blocks: Set<Int> = []
        let o = n^1
        if !hasW2(o) { return nil }
        for p in 0..<64 {
            if pointEmpty(p) {
                addMove(p, for: n)
                if hasW2(o, depth: depth) { blocks.insert(p) }
                undoMove(for: n)
            }
        }
        return blocks.isEmpty ? nil : blocks
    }
    
    private func addCheckMove(_ n: Int, _ stack: inout [Board], _ seen: inout Set<UInt64>, _ first: Int) -> Int? {
        let o = n^1
        if let check = open[1+6*o].values.first?[0] {
            if let back = checkBack(n, check) {
                let b1 = Board(self)
                b1.addMove(check, for: n)
                if b1.hasW1(o) { return nil }
                b1.addMove(back, for: o)
                if b1.hasW1(n) { return b1.move[n][first] }
                if seen.insert(b1.board[n]).inserted { stack.append(b1) }
            }
        }
        return nil
    }
    
    private func checkBack(_ n: Int, _ p: Int) -> Int? {
        for pair in open[2+4*n].values {
            for i in [0,1] {
                if pair[i] == p { return pair[i^1] }
            }
        }
        return nil
    }
    
    private func addAllForces(_ n: Int, _ stack: inout [Board], _  seen: inout Set<UInt64>, _ first: Int) -> Int? {
        for pair in open[2+4*n].values {
            let b1 = Board(self)
            b1.addMove(pair[0], for: n)
            b1.addMove(pair[1], for: n^1)
            if b1.hasW1(n) { return b1.move[n][first] }
            
            let b2 = Board(self)
            b2.addMove(pair[1], for: n)
            b2.addMove(pair[0], for: n^1)
            if b2.hasW1(n) { return b2.move[n][first] }
            
            if seen.insert(b1.board[n]).inserted { stack.append(b1) }
            if seen.insert(b2.board[n]).inserted { stack.append(b2) }
        }
        return nil
    }
    
//    func hasO2Win(_ n: Int) -> Bool {
//        // returns true if player n has 1st order check,
//        // and they have a string of checks available that
//        // leads to a 1st order checkmate
//        let wins = getO1WinsFor(n)
//        if wins.count != 1 { return false }
//        addMove(wins.first!) // only works if the next player is o
//        // TODO make this callable no matter who's move it is
//        // TODO check for o getting check with their move
//        if get2ndOrderWinFor(n) != nil {
//            undoMove()
//            return true
//        }
//        undoMove()
//        return false
//    }
    
//    func get2ndOrderWinFor(_ n: Int) -> Int? {
//        // if possible, returns a point that will give player n a 1st order check,
//        // and will eventually allow them to get a 2nd order win
//
//        // TODO check the state of the board?
//        // or state clearly what I'm assuming about the board
//        let o = n^1
//        dTable = []
//        var dQueue: Set<D> = []
//        var dBoard: [Set<D>] = Array(repeating: [], count: 64)
//        move[n].forEach { m in dQueue.insert(D(given: m)) }
//
//        while let d0 = dQueue.popFirst() {
//            // try to find wins
//            for d1 in dBoard[d0.gain] {
//                if let winPairs = worksSansChecks(d0: d0, d1: d1) {
//                    let gains2 = d0.gains | d1.gains
//                    let costs2 = d0.costs | d1.costs
//                    // check that no checks will form
//                    var checkPoint: Int? = nil
//                    var checkStatus: [[Int]] = status
//                    for cost in winPairs.keys {
//                        if checkPoint != nil { break }
//                        for l in Board.linesThruPoint[cost] {
//                            if checkStatus[o][l] == 2 && checkStatus[n][l] == 0 {
//                                var points = Board.pointsInLine[l]
//                                points.remove(at: cost)
//                                for p in points {
//                                    if (board[o] | costs2) & (1 &<< p) == 0 {
//                                        checkPoint = p
//                                        break
//                                    }
//                                }
//                                break
//                            }
//                            checkStatus[o][l] += 1
//                        }
//                    }
//                    // TODO make sure that if the check has a check on the way, that it also finds that
//                    // if no checks, you're good!
//                    guard let forcedPoint = checkPoint else {
//                        // yay we found one! (checkPoint was nil)
//                        return getFirstMove(i: 4, printMoves: false)
//                    }
//                    // otherwise, see if the forced point is left open
//                    if gains2 & (1 &<< forcedPoint) == 0 {
//                        // if they are open, see if the natural blocks work
//                    }
//                        // if they are closed, see if you can build up to that block without the thing that causes it
//                        // also consider seeing if you can stop the check from being a check at all?
//                }
//            }
//            // try to find new deductions
//            let opBoard = d0.costs | board[o]
//            for l in Board.linesThruPoint[d0.gain] {
//                // check that the line seems clear
//                if Board.linePoints[l] & opBoard == 0 {
//                    let points = Board.pointsInLine[l] //.subtracting([d0.gain])
//                    for p in points {
//                        for d1 in dBoard[p] {
//                            // check that the gain cubes and cost cubes are separate
//                            if (d0.gains & d1.costs) | (d0.costs & d1.gains) == 0 {
//                                var newPoints = points//.subtracting([p])
//                                let p0 = newPoints[0]
//                                let p1 = newPoints[0]
//                                let gains = d0.gains | d1.gains
//                                let costs = d0.costs | d1.costs
//                                // check that p0 and p1 are open
//                                if ((board[n] | gains | costs) & ((1 &<< p0) | (1 &<< p1))) == 0 {
//                                    // check that the cost cubes only overlap if the gain cubes for that one overlaps
//                                    var allPairs: Dictionary<Int,Int> = d0.pairs
//                                    var mergable: Bool = true
//                                    for pair in d1.pairs {
//                                        if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
//                                            if prevGain != pair.value {
//                                                mergable = false
//                                                break
//                                            }
//                                        }
//                                    }
//                                    if mergable {
//                                        dQueue.insert(D(gain: p0, cost: p1, gains: gains | (1 &<< p0) , costs: costs | (1 &<< p1), pairs: allPairs.add((key: p1, value: p0)), line: l))
//                                        dQueue.insert(D(gain: p1, cost: p0, gains: gains | (1 &<< p1) , costs: costs | (1 &<< p0), pairs: allPairs.add((key: p0, value: p1)), line: l))
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            dBoard[d0.gain].insert(d0)
//        }
//        return nil
//    }
    
//    func noConflict(n: Int, d0: D, d1: D, p0: Int, p1: Int) -> (UInt64, UInt64, Dictionary<Int,Int>)? {
//        // check that the gain cubes and cost cubes are separate
//        if (d0.gains & d1.costs) | (d0.costs & d1.gains) != 0 {
//            return nil
//        }
//        let gains = d0.gains | d1.gains
//        let costs = d0.costs | d1.costs
//        // check that p0 and p1 are open
//        if ((board[n] | gains | costs) & ((1 &<< p0) | (1 &<< p1))) != 0 {
//            return nil
//        }
//        // check that the cost cubes only overlap if the gain cubes for that one overlaps
//        var allPairs: Dictionary<Int,Int> = d0.pairs
//        for pair in d1.pairs {
//            if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
//                if prevGain != pair.value {
//                    return nil
//                }
//            }
//        }
//        // success!
//        return (gains, costs, allPairs)
//    }
//
//    func worksSansChecks(d0: D, d1: D) -> Dictionary<Int,Int>? {
//        // check that the gain cubes and cost cubes are separate
//        if (d0.gains & d1.costs) | (d0.costs & d1.gains) != 0 {
//            return nil
//        }
//        // check that the cost cubes only overlap if the gain cubes for that one overlaps
//        var allPairs: Dictionary<Int,Int> = d0.pairs
//        for pair in d1.pairs {
//            if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
//                if prevGain != pair.value {
//                    return nil
//                }
//            }
//        }
//        return allPairs
//    }
//
//    func checkCombos(n: Int, plyLimit: Int) -> Int? {
//        // check for non-conflicting deductions on the same point
//        let opTurn = inc(n)
//        let undoNum = move.count
//        for i in 0..<dTable.count {
//            for j in 0..<i {
//                // if the two points are the same
//                if dTable[i].gain == dTable[j].gain {
//                    let i1 = dTable[i].line
//                    let i2 = dTable[i].line
//                    // add all the first ones, should never fail (not adding j/i itself)
//                    let _ = addDMoves(i: i1, myTurn: n, opTurn: opTurn)
//                    let _ = addDMoves(i: i2, myTurn: n, opTurn: opTurn)
//
//                    let j1 = dTable[j][2]
//                    let j2 = dTable[j][3]
//                    // try adding all the second ones (again not adding j/i itself)
//                    if addDMoves(i: j1, myTurn: n, opTurn: opTurn) {
//                        if addDMoves(i: j2, myTurn: n, opTurn: opTurn) {
//                            // make sure the two sets don't create checks with each other
//                            if getMyLines(n: opTurn, k: 3) == 0 && b.getMyLines(n: opTurn, k: 4) == 0 {
//                                // if we got here, they're compatible, so go for it
//                                undoDMoves(undoNum: undoNum)
//                                return getFirstMove(i: i, printMoves: false)
//                                }
//                            }
//                        }
//                    }
//                    undoDMoves(undoNum: undoNum)
//                }
//            }
//        }
//        return nil
//    }
//
//    func getFirstMove(i: Int, printMoves: Bool) -> Int {
//        var possMove = dTable[i][0]
//        var nextD = i
//        while dTable[nextD][2] != dLen {
//            if printMoves {
//                print(possMove)
//            }
//            possMove = dTable[nextD][0]
//            nextD = dTable[nextD][2]
//        }
//        return possMove
//    }
    
    
    
//    func hasO1Checkmate(_ n: Int) -> Bool {
//        // returns true if player n will have a win
//        // available no matter what the opponent does
//        for p in (0..<64).filter({ pointEmpty($0) }) {
//            if Board.linesThruPoint[p].filter({ status[$0] == 2*(1 + 4*n) }).count > 1 {
//                return true
//            }
//        }
//        return false
//    }
//
//    func getO1CheckmatesFor(_ n: Int) -> [Int] {
//        // returns points that leave player n with a
//        // win no matter what the opponent does
//        var checkmates: [Int] = []
//        for p in (0..<64).filter({ pointEmpty($0) }) {
//            if Board.linesThruPoint[p].filter({ status[$0] == 2*(1 + 4*n) }).count > 1 {
//                checkmates.append(p)
//            }
//        }
//        return checkmates
//    }
}

//    // TODO consider removing
//    func getMyLines(_ n: Int) -> [Int] {
//        return set[n].map({ s in s.count })
//
//
//        var myMove: Bool = n == 1
//        for p in move {
//            if myMove {
//                for l in linesThruPoint[p] {
//                    linesArray[l] += 1
//                }
//            } else {
//                for l in linesThruPoint[p] {
//                    linesArray[l] = 5 // invalidates
//                }
//            }
//            myMove.toggle()
//        }
//        var numLines = Array(repeating: 0, count: 4)
//        for c in linesArray {
//            if (0..<4).contains(c) {
//                numLines[c] += 1
//            }
//        }
//        return numLines
//    }
//
//    func getMyLinesArray(_ n: Int) -> ([Int], [[Int]]) {
//        var linesArray: [Int] = Array(repeating: 0, count: 76)
//        var myMove: Bool = n == 1
//        for p in move {
//            if myMove {
//                for l in linesThruPoint[p] {
//                    linesArray[l] += 1
//                }
//            } else {
//                for l in linesThruPoint[p] {
//                    linesArray[l] = 5 // invalidates
//                }
//            }
//            myMove.toggle()
//        }
//        var numLines = Array(repeating: 0, count: 4)
//        var linesList = Array(repeating: [Int](), count: 4)
//        for (c, i) in linesArray.enumerated() {
//            if (0..<4).contains(c) {
//                numLines[c] += 1
//                linesList[c].append(i)
//            }
//        }
//        return (numLines, linesList)
//    }

//
//    // return number of open points on lines with k of n's points
//    func getMyPointsArray(n: Int, k: Int) -> (Int, [Bool]) {
//        var array = Array(repeating: false, count: 64)
//        var numPoints = 0
//
//        if (k == 0) {
//            for i in 0...75 {
//                if self.line[i][0] == 0 {
//                    for p in 0...3 {
//                        // all points are open
//                        array[pointsInLine[i][p]] = true
//                    }
//                }
//            }
//        } else {
//            for i in 0...75 {
//                if self.line[i][0] == n {
//                    if self.line[i][1] == k {
//                        for p in 0...3 {
//                            let currentPoint = pointsInLine[i][p]
//                            if self.point[currentPoint] != n {
//                                array[currentPoint] = true
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        for i in 0...63 {
//            if array[i] {
//                numPoints += 1
//            }
//        }
//
//        return (numPoints, array)
//    }
