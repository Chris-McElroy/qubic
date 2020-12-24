//
//  Player.swift
//  qubic
//
//  Created by 4 on 12/12/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Player {
    let b: Board
    let n: Int
    let o: Int
    let name: String
    var color: Int
    
    let depth: Int
    let lineP: [Double]
    let bucketP: Double
    let w2BlockP: Double
    let dirStats: [Double]
    let lineScore: [Double]
    
    init(b: Board, n: Int) {
        self.b = b
        self.n = 0
        o = 0
        name = ""
        color = 0
        
        depth = 0
        lineP = []
        bucketP = 0
        w2BlockP = 0
        dirStats = []
        lineScore = []
    }
    
    init(b: Board, n: Int, name: String, color: Int, depth: Int, lineP: [Double], bucketP: Double, w2BlockP: Double, dirStats: [Double], lineScore: [Double]) {
        self.b = b
        self.n = n
        self.o = n^1
        self.name = name
        self.color = color
        
        self.depth = depth
        self.lineP = lineP
        self.bucketP = bucketP
        self.w2BlockP = w2BlockP
        self.dirStats = dirStats
        self.lineScore = lineScore
    }
    
    func getPause() -> Double { return 0 }
    
    func move(with process: @escaping (Int) -> Void) {
        var move = 0
        
        if let m =      myW1() { move = m }
        else if let m = opW1() { move = m }
        else if let m = myW2() { move = m }
        else { move = unforcedHeuristic() }
        
        Timer.scheduledTimer(withTimeInterval: getPause(), repeats: false, block: { _ in process(move) })
    }
    
    func myW1() -> Int? { shouldMove(in: b.getW1(for: n), s: 1+6*n) }
    func opW1() -> Int? { shouldMove(in: b.getW1(for: o), s: 1+6*o) }
    func myW2() -> Int? { shouldMove(in: b.getW2(for: n, depth: depth), s: 2+4*n) }
    func opW2() -> Set<Int>? {
        if w2BlockP > .random(in: 0..<1) {
            return b.getW2Blocks(for: n, depth: depth)
        }
        return nil
    }
    
    func shouldMove(in set: Set<Int>, s: Int) -> Int? {
        for m in set.shuffled() {
            for l in Board.linesThruPoint[m].shuffled() {
                if s == b.status[l] && lineP[s]*dirStats[l] > .random(in: 0..<1) {
                    return m
                }
            }
        }
        return nil
    }
    
    func unforcedHeuristic() -> Int {
        var options: Set<Int> = Set((0..<64).filter { b.pointEmpty($0) })
        if let o = opW2() { options = o }
        
        let scores = getScores(for: options)
        
        for bucket in scores.sorted(by: { x,y in x.key > y.key }) {
            if bucketP > .random(in: 0..<1) {
                options = bucket.value
                break
            }
        }
        
        return options.randomElement() ?? 0
    }
    
    func getScores(for options: Set<Int>) -> [Int: Set<Int>] {
        var scores: [Int: Set<Int>] = [:]
        for p in options {
            var score: Double = 0
            for l in Board.linesThruPoint[p] {
                if let s = b.status[l] {
                    score += lineScore[s]*dirStats[l]
                }
            }
            scores[Int(score), default: []].insert(p)
        }
        return scores
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
}

