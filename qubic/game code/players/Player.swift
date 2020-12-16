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
    
    let wins: [[Double]]
    let o1CheckMates: [[Double]]
    let o1Checks: [[Double]]
    
    init(b: Board, n: Int) {
        self.b = b
        self.n = n
        o = n^1
        name = UserDefaults.standard.string(forKey: usernameKey) ?? "me"
        color = 0
        wins = []
        o1CheckMates = []
        o1Checks = []
    }
    
    init(b: Board, n: Int, name: String, color: Int, wins: [[Double]], o1CheckMates: [[Double]], o1Checks: [[Double]]) {
        self.b = b
        self.n = n
        self.o = n^1
        self.name = name
        self.color = color
        self.wins = wins
        self.o1CheckMates = o1CheckMates
        self.o1Checks = o1Checks
    }
    
    func getPause() -> Double { return 0 }
    
    func move(with process: @escaping (Int) -> Void) {
        var move = 0
        
        if let m = shouldMove(in: b.getO1WinsFor, s: 3, stats: wins) { move = m }
        else if let m = shouldMove(in: b.getO1CheckmatesFor, s: 2, stats: o1CheckMates) { move = m }
        else if let m = shouldMove(in: b.getO1ChecksFor, s: 3, stats: o1Checks) { move = m }
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
    
    private func shouldMove(in test: (Int) -> [Int], s: Int, stats: [[Double]]) -> Int? {
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

