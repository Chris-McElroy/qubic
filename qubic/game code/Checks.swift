//
//  WinHelper.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

extension Board {
    func has1stOrderWin(_ n: Int) -> Bool {
        // returns true if player n has won
        for s in status {
            if s == 4*(1 + 4*n) { return true }
        }
        return false
    }
    
    func get1stOrderWinsFor(_ n: Int) -> [Int] {
        // returns points that give player n a win
        var wins: [Int] = []
        for l in 0..<76 {
            if status[l] == 3*(1 + 4*n) {
                for p in Board.pointsInLine[l] {
                    if ((board[n] &>> p) & 1) == 0 {
                        wins.append(p)
                        break
                    }
                }
            }
        }
        return wins
    }
    
    func has1stOrderCheckmate(_ n: Int) -> Bool {
        // returns true if player n will have a win
        // available no matter what the opponent does
        for p in (0..<64).filter({ pointEmpty($0) }) {
            if Board.linesThruPoint[p].filter({ status[$0] == 2*(1 + 4*n) }).count > 1 {
                return true
            }
        }
        return false
    }
    
    func get1stOrderCheckmatesFor(_ n: Int) -> [Int] {
        // returns points that leave player n with a
        // win no matter what the opponent does
        var checkmates: [Int] = []
        for p in (0..<64).filter({ pointEmpty($0) }) {
            if Board.linesThruPoint[p].filter({ status[$0] == 2*(1 + 4*n) }).count > 1 {
                checkmates.append(p)
            }
        }
        return checkmates
    }
    
    func has1stOrderCheck(_ n: Int) -> Bool {
        // returns true if player n has
        // at least one option for a win next move
        for l in 0..<76 {
            if status[l] == 3*(1 + 4*n) {
                return true
            }
        }
        return false
    }
    
    func get1stOrderChecksFor(_ n: Int) -> [Int] {
        // returns points that leave player n with
        // at least one option for a win next move
        var checks: [Int] = []
        for p in (0..<64).filter({ pointEmpty($0) }) {
            if Board.linesThruPoint[p].filter({ status[$0] == 3*(1 + 4*n) }).count > 0 {
                checks.append(p)
            }
        }
        return checks
    }
    
    func has2ndOrderWin(_ n: Int) -> Bool {
        // returns true if player n has 1st order check,
        // and they have a string of checks available that
        // leads to a 1st order checkmate
        let wins = get1stOrderWinsFor(n)
        if wins.count != 1 { return false }
        addMove(wins.first!) // only works if the next player is o
        // TODO make this callable no matter who's move it is
        // TODO check for o getting check with their move
//        if get2ndOrderWinFor(n) != nil {
//            undoMove()
//            return true
//        }
        undoMove()
        return false
    }
    
//    func get2ndOrderWinFor(_ n: Int) -> Int? {
//        // if possible, returns a point that will give player n a 1st order check,
//        // and will eventually allow them to get a 2nd order win
//
//        // TODO check the state of the board?
//        // or state clearly what I'm assuming about the board
//        let o = n^1
////        dTable = []
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
////                    // if no checks, you're good!
////                    guard let forcedPoint = checkPoint else {
////                        // yay we found one! (checkPoint was nil)
////                        return getFirstMove(i: 4, printMoves: false)
////                    }
////                    // otherwise, see if the forced point is left open
////                    if gains2 & (1 &<< forcedPoint) == 0 {
////                        // if they are open, see if the natural blocks work
////                    }
////                        // if they are closed, see if you can build up to that block without the thing that causes it
////                        // also consider seeing if you can stop the check from being a check at all?
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
    
    func noConflict(n: Int, d0: D, d1: D, p0: Int, p1: Int) -> (UInt64, UInt64, Dictionary<Int,Int>)? {
        // check that the gain cubes and cost cubes are separate
        if (d0.gains & d1.costs) | (d0.costs & d1.gains) != 0 {
            return nil
        }
        let gains = d0.gains | d1.gains
        let costs = d0.costs | d1.costs
        // check that p0 and p1 are open
        if ((board[n] | gains | costs) & ((1 &<< p0) | (1 &<< p1))) != 0 {
            return nil
        }
        // check that the cost cubes only overlap if the gain cubes for that one overlaps
        var allPairs: Dictionary<Int,Int> = d0.pairs
        for pair in d1.pairs {
            if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
                if prevGain != pair.value {
                    return nil
                }
            }
        }
        // success!
        return (gains, costs, allPairs)
    }
    
    func worksSansChecks(d0: D, d1: D) -> Dictionary<Int,Int>? {
        // check that the gain cubes and cost cubes are separate
        if (d0.gains & d1.costs) | (d0.costs & d1.gains) != 0 {
            return nil
        }
        // check that the cost cubes only overlap if the gain cubes for that one overlaps
        var allPairs: Dictionary<Int,Int> = d0.pairs
        for pair in d1.pairs {
            if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
                if prevGain != pair.value {
                    return nil
                }
            }
        }
        return allPairs
    }
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
    
    func has2ndOrderCheckmate(_ n: Int) -> Bool {
        // returns true if player n will have a 2nd order win
        // available no matter what the opponent does
        // TODO this
        return false
    }
    
    func get2ndOrderCheckmatesFor(_ n: Int) -> Set<Int> {
        // returns points that leave player n with a
        // 2nd order win no matter what the opponent does
        // TODO this
        return Set<Int>()
    }
    
    func has2ndOrderCheck(_ n: Int) -> Bool {
        // returns true if player n will has at least
        // one option for a 2nd order win next move
        // TODO this
        return false
    }
    
    func get2ndOrderChecksFor(_ n: Int) -> Set<Int> {
        // returns points that leave player n with at least
        // one option for a 2nd order win next move
        // TODO this
        return Set<Int>()
    }
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
