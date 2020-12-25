//
//  Defender.swift
//  qubic
//
//  Created by 4 on 12/12/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Defender: Player {
    override init(b: Board, n: Int) {
        super.init(b: b, n: n, name: "defender", color: 4,
                   lineP: [3: 1.96, -3: 2.2, 2: 0.20],
                   dirStats: Player.setStats(hs: 1.0, vs: 0.5, hd: 0.75, vd: 0.3, md: 0.4),
                   depth: 2,
                   w2BlockP: 0.6,
                   lineScore: [0,1,1,1,1,3,15,20,0], // my points on the left
                   bucketP: 0.8)
//                   w1: [Player.setStats(hs: 0.99, vs: 0.99, hd: 0.98, vd: 0.85, md: 0.80),
//                        Player.setStats(hs: 1.0,  vs: 1.0,  hd: 1.0,  vd: 0.95, md: 0.9)],
//                   w2: [Player.setStats(hs: 0.20, vs: 0.10, hd: 0.10, vd: 0.05, md: 0.05), // was 0.7 total
//                        Player.setStats(hs: 0.20, vs: 0.10, hd: 0.10, vd: 0.03, md: 0.03)], // was 0.95 total
//                   c1: [Player.setStats(hs: 0.10, vs: 0.05, hd: 0.10, vd: 0.03, md: 0.02),
//                        Player.setStats(hs: 0.8,  vs: 0.6,  hd: 0.5,  vd: 0.2,  md: 0.4)])
    }
    
    override func getPause() -> Double {
        if b.getW1(for: 0).count + b.getW1(for: 0).count > 0 {
            return .random(in: 1.0..<3.0)
        }
        
//        if b.getO1CheckmatesFor(0).count + b.getO1CheckmatesFor(1).count > 0 {
//            return .random(in: 2.0..<4.0)
//        }
        
        let moves = Double(b.move[0].count)
        let bottom = 0.9 + moves/10
        let top = 2.5 + moves/6
        return .random(in: bottom..<top)
    }
    
//    override func unforcedHeuristic() -> Int {
//        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
//        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
//        let bias = 15.0*Double(rich.count)/(0.001+Double(poor.count))
//        if poor.isEmpty { return rich.randomElement() ?? 0 }
//        if rich.isEmpty { return poor.randomElement() ?? 0 }
//        return .random(in: 0...1) < (bias/(1+bias)) ? rich.randomElement() ?? 0 : poor.randomElement() ?? 0
//    }
}
