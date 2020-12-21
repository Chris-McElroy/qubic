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
    
    let d: Int
    let w1: [[Double]]
    let w2: [[Double]]
    let c1: [[Double]]
    
    init(b: Board, n: Int) {
        self.b = b
        self.n = n
        o = n^1
        name = UserDefaults.standard.string(forKey: usernameKey) ?? "me"
        color = 0
        d = 0
        w1 = []
        w2 = []
        c1 = []
    }
    
    init(b: Board, n: Int, name: String, color: Int, d: Int, w1: [[Double]], w2: [[Double]], c1: [[Double]]) {
        self.b = b
        self.n = n
        self.o = n^1
        self.name = name
        self.color = color
        self.d = d
        self.w1 = w1
        self.w2 = w2
        self.c1 = c1
    }
    
    func getPause() -> Double { return 0 }
    
    func move(with process: @escaping (Int) -> Void) {
        var move = 0
        
        if let m = shouldMove(in: b.getW1(for: n), for: n, s: 3, stats: w1[0]) { move = m }
        else if let m = shouldMove(in: b.getW1(for: o), for: o, s: 3, stats: w1[1]) { move = m }
        
        else if let m = shouldMove(in: b.getW2(for: n, depth: d), for: n, s: 2, stats: w2[0]) { move = m }
        else if let m = shouldMove(in: b.getW2(for: o, depth: d), for: o, s: 2, stats: w2[1]) { move = m }
        
        else if let m = shouldMove(in: b.getC1(for: n), for: n, s: 2, stats: c1[0]) { move = m }
        else if let m = shouldMove(in: b.getC1(for: o), for: o, s: 2, stats: c1[1]) { move = m }
        
        else { move = unforcedHeuristic() }
        
        Timer.scheduledTimer(withTimeInterval: getPause(), repeats: false, block: { _ in process(move) })
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
    
    private func shouldMove(in set: Set<Int>, for n: Int, s: Int, stats: [Double]) -> Int? {
        for m in set.shuffled() {
            for l in Board.linesThruPoint[m].shuffled() {
                if b.status[l] == 4+s*(2*n-1) && .random(in: 0..<1) < stats[l] {
                    return m
                }
            }
        }
        return nil
    }
}

