//
//  Board.swift
//  qubic
//
//  Created by 4 on 8/29/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

func inc(_ n: Int) -> Int {
    return (n + 1) & 1
}

class Board {
    typealias D = (gain: Int, cost: Int?, allGains: UInt64, allCosts: UInt64, line: Int?)
    
    var move: [[Int]] = [[],[]]
    var board: [UInt64] = [0,0]
    var doubles: [Set<Int>] = [[],[]]
    var status: [[Int]] = Array(repeating: Array(repeating: 0, count: 76), count: 2)
    var dTable: [D] = []
    
    func pointEmpty(_ p: Int) -> Bool {
        return (((board[0] | board[1]) &>> p) & 1) == 0
    }
    
    func pointFull(_ p: Int) -> Bool {
        return (((board[0] | board[1]) &>> p) & 1) == 1
    }
    
    func addMove(p: Int) {
        let n = move[0].count - move[1].count
        let o = inc(n)
        move[n].append(p)
        board[n] |= (1 << p)
        for line in linesThruPoint[p] {
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
        for line in linesThruPoint[p] {
            doubles[n].remove(line)
            status[n][line] -= 1
            if status[n][line] == 2 && status[o][line] == 0 {
                doubles[n].insert(line)
            }
        }
    }
    
    func has1stOrderWin(_ n: Int) -> Bool {
        // returns true if player n has won
        for s in status[n] {
            if s == 4 { return true }
        }
        return false
    }
    
    func get1stOrderWinsFor(_ n: Int) -> Set<Int> {
        // returns points that give player n a win
        var wins: Set<Int> = []
        let o = inc(n)
        for l in 0..<76 {
            if status[n][l] == 3 && status[o][l] == 0 {
                for p in pointsInLine[l] {
                    if ((board[n] &>> p) & 1) == 0 {
                        wins.insert(p)
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
        var checks = -1
        let o = inc(n)
        for l in 0..<76 {
            if status[n][l] == 3 && status[o][l] == 0 {
                for p in pointsInLine[l] {
                    if ((board[n] &>> p) & 1) == 0 {
                        if checks < 0 { checks = p }
                        else { return true }
                        break
                    }
                }
            }
        }
        return false
    }
    
    func get1stOrderCheckmatesFor(_ n: Int) -> Set<Int> {
        // returns points that leave player n with a
        // win no matter what the opponent does
        var checks: Set<Int> = []
        var checkmates: Set<Int> = []
        for l in doubles[n] {
            for p in pointsInLine[l] {
                if ((board[n] &>> p) & 1) == 0 {
                    let (duplicate,_) = checks.insert(p)
                    if duplicate { checkmates.insert(p) }
                    break
                }
            }
        }
        return checkmates
    }
    
    func has1stOrderCheck(_ n: Int) -> Bool {
        // returns true if player n has
        // at least one option for a win next move
        let o = inc(n)
        for l in 0..<76 {
            if status[n][l] == 3 && status[o][l] == 0 {
                return true
            }
        }
        return false
    }
    
    func get1stOrderChecksFor(_ n: Int) -> Set<Int> {
        // returns points that leave player n with
        // at least one option for a win next move
        var checks: Set<Int> = []
        for l in doubles[n] {
            for p in pointsInLine[l] {
                if ((board[n] &>> p) & 1) == 0 {
                    checks.insert(p)
                    break
                }
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
        addMove(p: wins.first!) // only works if the next player is o
        // TODO make this callable no matter who's move it is
        // TODO check for o getting check with their move
        return !get2ndOrderWinsFor(n).isEmpty
    }
    
    func get2ndOrderWinsFor(_ n: Int) -> Set<Int> {
        // returns the points give player n a 1st order check,
        // and will eventually allow them to get a 2nd order win
        
        // TODO check the state of the board?
        // or state clearly what I'm assuming about the board
        var wins: Set<Int> = []
        let o = inc(n)
        dTable = []
        
        for m in move[n] {
            dTable.append((m, nil, 1 << m, 0, nil))
        }

        var start = 1
        var finish = dTable.count
        repeat {
            for (i,d0) in dTable[start..<finish].enumerated() {
                for d1 in dTable[0..<i] {
                    if let (l, p0, p1) = inLine[d0.gain][d1.gain], l != d0.line && l != d1.line {
                        // check that the cost cubes only overlap if the gain cubes for that one overlaps
                        // TODO fuck im not doing this at all
                        // okay the fix for this is too also track it with a cost dictionary, which would be lit cuz it also avoids recursion later
                        if d0.allCosts & d1.allCosts != 0 {
                            let gains = d0.allGains | d1.allGains
                            let costs = d0.allCosts | d1.allCosts
                            // check that the gain cubes and cost cubes are separate
                            if gains & costs == 0 {
                                if ((board[o] | gains | costs) & ((1 &<< p0) + (1 &<< p1))) == 0 {
                                    // consider adding a separate table that tracks d's by points
                                    dTable.append((p0, p1, gains | (1 &<< p0) , costs | (1 &<< p1), l))
                                    dTable.append((p1, p0, gains | (1 &<< p1) , costs | (1 &<< p0), l))
                                }
                            }
                        }
                    }
                }
            }
//            if let win = findWins(n: n) {
//                wins.append(win) // TODO make this only return one thing and then make a full function that finds all of them
//            }
            start = finish
            finish = dTable.count
        } while (start != finish)
        return Set<Int>()
    }
    
    func noConflict(_ costs0: Dictionary<Int,Int>, _ costs1: Dictionary<Int,Int>) -> Bool {
        // check that the cost cubes only overlap if the gain cubes for that one overlaps
        var conflict: Bool = false
        let costs = costs0.merging(costs1) { (g0, g1) in
            conflict = conflict || (g0 != g1)
            return g1
        }
        if conflict { return false }
        // check that the gain cubes and cost cubes are separate
        return Set(costs.keys).isDisjoint(with: costs.values)
    }
    
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
