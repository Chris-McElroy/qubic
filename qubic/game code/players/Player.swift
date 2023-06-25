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
	let id: String
    let name: String
    var color: Int
    let rounded: Bool
    let local: Bool
    
    let lineP: [Int: Double]
    let dirStats: [Double]
    var depth: Int
    let w2BlockP: Double
    let lineScore: [Double]
    let bucketP: Double
	let gameNum: Int
    
    let moveQueue = DispatchQueue(label: "player move queue", qos: .userInitiated)
    var moveTimer: Timer? = nil
    
    init(b: Board, n: Int) {
        self.b = b
        self.n = n
        o = n^1
		id = ""
        name = ""
        color = 0
        rounded = false
        local = true
        
        lineP = [:]
        dirStats = []
        depth = 0
        w2BlockP = 0
        lineScore = []
        bucketP = 0
		gameNum = 0
    }
    
	init(b: Board, n: Int, id: String, name: String = "", color: Int = 0, rounded: Bool = false, local: Bool = true) {
        self.b = b
        self.n = n
        self.o = n^1
		self.id = id
        self.name = name
        self.color = color
        self.rounded = rounded
        self.local = local
		
        lineP = [:]
        dirStats = []
        depth = 0
        w2BlockP = 0
        lineScore = []
        bucketP = 0
		gameNum = Game.main.gameNum
    }
    
	init(b: Board, n: Int, id: String, name: String, color: Int, rounded: Bool = false, local: Bool = true, lineP: [Int: Double], dirStats: [Double], depth: Int, w2BlockP: Double, lineScore: [Double], bucketP: Double) {
        self.b = b
        self.n = n
        self.o = n^1
		self.id = id
        self.name = name
        self.color = color
        self.rounded = rounded
        self.local = local
		
        self.lineP = lineP
        self.dirStats = dirStats
        self.depth = depth
        self.w2BlockP = w2BlockP
        self.lineScore = n == 0 ? lineScore : lineScore.reversed()
        self.bucketP = bucketP
		gameNum = Game.main.gameNum
    }
    
    func getPause() -> Double { return 0 }
    
    func cancelMove() {
        moveTimer?.invalidate()
        moveTimer = nil
    }
    
    func move() {
		let startState = b.board
		let setup: [Int] = b.getSetup()
		
        cancelMove()
        
        moveQueue.async { [self] in
            let move: Int
            
            if let m =      myW1() { move = m }
            else if let m = opW1() { move = m }
            else if let m = myW2() { move = m }
            else { move = unforcedHeuristic() }
            let delay = getPause()
            
            DispatchQueue.main.async {
				self.moveTimer = Timer.after(delay) {
					if self.b.board != startState { print("GOTTEM") }
					Game.main.processMove(move, for: self.n, setup: setup)
                }
            }
        }
    }
    
    func myW1() -> Int? { shouldMove(in: b.getW1(for: n), s: 3) }
    func opW1() -> Int? { shouldMove(in: b.getW1(for: o), s: -3) }
	func myW2() -> Int? { shouldMove(in: b.getW2(for: n, depth: depth, time: 10, valid: { gameNum == Game.main.gameNum }) ?? [], s: 2) }
	func opW2() -> Set<Int>? { w2BlockP > .random(in: 0..<1) ? b.getW2Blocks(for: n, depth: depth, time: 10, valid: { gameNum == Game.main.gameNum }) : nil }
    
    func shouldMove(in set: Set<Int>, s: Int) -> Int? {
        let baseP = lineP[s] ?? 0
        let status = 4 + s*(2*n-1)
        for m in set.shuffled() {
            for l in Board.linesThruPoint[m].shuffled() {
				if status == b.status[l] && baseP*dirStats[l] > .random(in: 0..<1) {
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

