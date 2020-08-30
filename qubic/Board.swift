//
//  Board.swift
//  qubic
//
//  Created by 4 on 8/29/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation
import UIKit

let nullMove = 64
let nullLine = 76
let linesPerPoint = 7

var showChecks = false

let linesThruPoint = [
    [0, 16, 32, 48, 56, 64, 72],  [0, 17, 33, 65],
    [0, 18, 34, 66],  [0, 19, 35, 52, 60, 67, 74],
    [1, 16, 36, 57],  [1, 17, 37, 48],
    [1, 18, 38, 52],  [1, 19, 39, 61],
    [2, 16, 40, 58],  [2, 17, 41, 52],
    [2, 18, 42, 48],  [2, 19, 43, 62],
    [3, 16, 44, 52, 59, 68, 75],  [3, 17, 45, 69],
    [3, 18, 46, 70],  [3, 19, 47, 48, 63, 71, 73],
    [4, 20, 32, 49],  [4, 21, 33, 56],
    [4, 22, 34, 60],  [4, 23, 35, 53],
    [5, 20, 36, 64],  [5, 21, 37, 49, 57, 65, 72],
    [5, 22, 38, 53, 61, 66, 74],  [5, 23, 39, 67],
    [6, 20, 40, 68],  [6, 21, 41, 53, 58, 69, 75],
    [6, 22, 42, 49, 62, 70, 73],  [6, 23, 43, 71],
    [7, 20, 44, 53],  [7, 21, 45, 59],
    [7, 22, 46, 63],  [7, 23, 47, 49],
    [8, 24, 32, 50],  [8, 25, 33, 60],
    [8, 26, 34, 56],  [8, 27, 35, 54],
    [9, 24, 36, 68],  [9, 25, 37, 50, 61, 69, 73],
    [9, 26, 38, 54, 57, 70, 75],  [9, 27, 39, 71],
    [10, 24, 40, 64],[10, 25, 41, 54, 62, 65, 74],
    [10, 26, 42, 50, 58, 66, 72],[10, 27, 43, 67],
    [11, 24, 44, 54],[11, 25, 45, 63],
    [11, 26, 46, 59],[11, 27, 47, 50],
    [12, 28, 32, 51, 60, 68, 73],[12, 29, 33, 69],
    [12, 30, 34, 70],[12, 31, 35, 55, 56, 71, 75],
    [13, 28, 36, 61],[13, 29, 37, 51],
    [13, 30, 38, 55],[13, 31, 39, 57],
    [14, 28, 40, 62],[14, 29, 41, 55],
    [14, 30, 42, 51],[14, 31, 43, 58],
    [15, 28, 44, 55, 63, 64, 74],[15, 29, 45, 65],
    [15, 30, 46, 66],[15, 31, 47, 51, 59, 67, 72]
]

let pointsInLine = [
    [0,1,2,3],    [4,5,6,7],    [8,9,10,11],  [12,13,14,15],
    [16,17,18,19],[20,21,22,23],[24,25,26,27],[28,29,30,31],
    [32,33,34,35],[36,37,38,39],[40,41,42,43],[44,45,46,47],
    [48,49,50,51],[52,53,54,55],[56,57,58,59],[60,61,62,63],
    [0,4,8,12],   [1,5,9,13],   [2,6,10,14],  [3,7,11,15],
    [16,20,24,28],[17,21,25,29],[18,22,26,30],[19,23,27,31],
    [32,36,40,44],[33,37,41,45],[34,38,42,46],[35,39,43,47],
    [48,52,56,60],[49,53,57,61],[50,54,58,62],[51,55,59,63],
    [0,16,32,48], [1,17,33,49], [2,18,34,50], [3,19,35,51],
    [4,20,36,52], [5,21,37,53], [6,22,38,54], [7,23,39,55],
    [8,24,40,56], [9,25,41,57], [10,26,42,58],[11,27,43,59],
    [12,28,44,60],[13,29,45,61],[14,30,46,62],[15,31,47,63],
    [0,5,10,15],  [16,21,26,31],[32,37,42,47],[48,53,58,63],
    [3,6,9,12],   [19,22,25,28],[35,38,41,44],[51,54,57,60],
    [0,17,34,51], [4,21,38,55], [8,25,42,59], [12,29,46,63],
    [3,18,33,48], [7,22,37,52], [11,26,41,56],[15,30,45,60],
    [0,20,40,60], [1,21,41,61], [2,22,42,62], [3,23,43,63],
    [12,24,36,48],[13,25,37,49],[14,26,38,50],[15,27,39,51],
    [0,21,42,63], [15,26,37,48],[3,22,41,60], [12,25,38,51]
]

let moveStringMap = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","1","2","3","4","5","6","7","8","9","0","_","-","."]

func inc(_ n: Int) -> Int {
    return n == 1 ? 2 : 1
}

class Board {
    var point = Array(repeating: 0, count: 64)
    var move = [Int]()
    var lines: [[Set<Int>]] = [[],[[],[],[],[],[]],[[],[],[],[],[]]]
    private var status: [[Int]] = Array(repeating: [0,0,0], count: 76)
    
    func addMove(p: Int) {
        if point[p] == 0 && (0..<64).contains(p) {
            let n = move.count % 2 + 1
            point[p] = n
            move.append(p)
            incLines(around: p, n: n)
        } else {
            print("invalid move attempted!")
        }
    }
    
    func undoMove() {
        if let p = move.last {
            let n = point[p]
            point[p] = 0
            move.removeLast()
            decLines(around: p, n: n)
        }
    }
    
    private func incLines(around p: Int, n: Int) {
        let o = inc(n)
        for line in linesThruPoint[p] {
            var lineStatus = status[line]
            lineStatus[n] += 1
            switch lineStatus[0] {
            case 0:
                lineStatus[0] = n
                lines[n][1].insert(line)
                break
            case n:
                lines[n][lineStatus[n]-1].remove(line)
                lines[n][lineStatus[n]].insert(line)
                break
            case o:
                lineStatus[0] = 3
                lines[o][lineStatus[o]].remove(line)
                break
            default:
                break
            }
            status[line] = lineStatus
        }
    }
    
    private func decLines(around p: Int, n: Int) {
        let o = inc(n)
        for line in linesThruPoint[p] {
            status[line][n] -= 1
            switch status[line][0] {
            case 3 where status[line][n] == 0:
                if status[line][o] != 0 {
                    status[line][0] = o
                    lines[o][status[line][o]].insert(line)
                } else {
                    status[line][0] = 0
                }
                break
            case n:
                lines[n][status[line][n]+1].remove(line)
                if status[line][n] != 0 {
                    lines[n][status[line][n]].insert(line)
                } else {
                    status[line][0] = 0
                }
                break
            default:
                break
            }
        }
    }
    
    func pointsInLines(n: Int, k: Int) -> [Int] {
        return lines[n][k].flatMap({ l in pointsInLine[l] })
    }
    
    func getPoints(n: Int, k: Int) -> Set<Int> {
        var points: Set<Int> = []
        for p in pointsInLines(n: n, k: k) {
            if point[p] == 0 { points.insert(p) }
        }
        return points
    }
    
    func has1stOrderWin(n: Int) -> Bool {
        // returns true if player n has won
        !lines[n][4].isEmpty
    }
    
    func get1stOrderWins(n: Int) -> Set<Int> {
        // returns true if player n has a win
        getPoints(n: n, k: 3)
    }
    
    func has1stOrderCheckmate(n: Int) -> Bool {
        // returns true if player n will have a win
        // available no matter what the opponent does
        if lines[n][3].count < 2 { return false }
        var points: Set<Int> = []
        for p in pointsInLines(n: n, k: 3) {
            if point[p] == 0 {
                points.insert(p)
                if points.count != 1 { return true }
            }
        }
        return false
    }
    
    func get1stOrderCheckmates(n: Int) -> Set<Int> {
        // returns points that leave player n with a
        // win no matter what the opponent does
        var checks: Set<Int> = []
        var checkmates: Set<Int> = []
        for p in pointsInLines(n: n, k: 2) {
            if point[p] == 0 {
                let (duplicate,_) = checks.insert(p)
                if duplicate { checkmates.insert(p) }
            }
        }
        return checkmates
    }
    
    func has1stOrderCheck(n: Int) -> Bool {
        // returns true if player n has
        // at least one option for a win next move
        !lines[n][3].isEmpty
    }
    
    func get1stOrderChecks(n: Int) -> Set<Int> {
        // returns points that leave player n with
        // at least one option for a win next move
        getPoints(n: n, k: 2)
    }
    
    func has2ndOrderWin(n: Int) -> Bool {
        // returns true if player n has 1st order check,
        // and they have a string of checks available that
        // leads to a 1st order checkmate
        // TODO this
        return false
    }
    
    func get2ndOrderWins(n: Int) -> Set<Int> {
        // TODO this
        return Set<Int>()
    }
    
    func has2ndOrderCheckmate(n: Int) -> Bool {
        // returns true if player n will have a 2nd order win
        // available no matter what the opponent does
        // TODO this
        return false
    }
    
    func get2ndOrderCheckmates(n: Int) -> Set<Int> {
        // returns points that leave player n with a
        // 2nd order win no matter what the opponent does
        // TODO this
        return Set<Int>()
    }
    
    func has2ndOrderCheck(n: Int) -> Bool {
        // returns true if player n will has at least
        // one option for a 2nd order win next move
        // TODO this
        return false
    }
    
    func get2ndOrderChecks(n: Int) -> Set<Int> {
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
