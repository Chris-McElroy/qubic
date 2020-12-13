//
//  Player.swift
//  qubic
//
//  Created by 4 on 12/12/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import UIKit

class Player {
    let b: Board
    let n: Int
    let o: Int
    let name: String
    let color: UIColor
    
    let wins: [[Double]]
    let o1CheckMates: [[Double]]
    let o1Checks: [[Double]]
    
    init(b: Board, n: Int) {
        self.b = b
        self.n = n
        o = n^1
        name = "me"
        color = getUIColor(0)
        wins = []
        o1CheckMates = []
        o1Checks = []
    }
    
    init(b: Board, n: Int, name: String, color: UIColor, wins: [[Double]], o1CheckMates: [[Double]], o1Checks: [[Double]]) {
        self.b = b
        self.n = n
        self.o = n^1
        self.name = name
        self.color = color
        self.wins = wins
        self.o1CheckMates = o1CheckMates
        self.o1Checks = o1Checks
    }
    
    func getPause() -> Double {
        if b.get1stOrderWinsFor(0).count + b.get1stOrderWinsFor(1).count > 0 {
            return .random(in: 1.0..<2.0)
        }
        
        if b.get1stOrderCheckmatesFor(0).count + b.get1stOrderCheckmatesFor(1).count > 0 {
            return .random(in: 1.5..<4.0)
        }
        
        let moves = Double(b.move[0].count)
        let bottom = 0.6 + moves/6
        let top = 1.5 + moves/4
        return .random(in: bottom..<top)
    }
    
    func getMove() -> Int {
        if let m = getMove(in: b.get1stOrderWinsFor, s: 3, stats: wins) { return m }
        if let m = getMove(in: b.get1stOrderCheckmatesFor, s: 2, stats: o1CheckMates) { return m }
        if let m = getMove(in: b.get1stOrderChecksFor, s: 3, stats: o1Checks) { return m }
        
        return unforcedHeuristic()
    }
    
    func unforcedHeuristic() -> Int {
        return (0..<64).first(where: { b.pointEmpty($0) })!
    }
    
    static func setStats(hs: Double, vs: Double, hd: Double, vd: Double, md: Double) -> [Double] {
        var statsArray: [Double] = []
        for _ in (0..<32)  { statsArray.append(hs) }
        for _ in (32..<48) { statsArray.append(vs) }
        for _ in (48..<56) { statsArray.append(hd) }
        for _ in (56..<72) { statsArray.append(vd) }
        for _ in (72..<76) { statsArray.append(md) }
        return statsArray
    }
    
    private func getMove(in test: (Int) -> [Int], s: Int, stats: [[Double]]) -> Int? {
        for (i,t) in [(0,n),(1,o)] {
            for m in test(t).shuffled() {
                for l in Board.linesThruPoint[m].shuffled() {
                    if b.status[l] == s*(1 + 4*t) && .random(in: 0..<1) < stats[i][l] {
                        return m
                    }
                }
            }
        }
        return nil
    }
}

