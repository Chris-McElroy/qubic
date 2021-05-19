//
//  Online.swift
//  qubic
//
//  Created by Chris McElroy on 3/24/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation

class Online: Player {
    let op: FB.PlayerData?
    let bot: Bot?
    
    override init(b: Board, n: Int) {
        if let op = FB.main.op {
            self.op = op
            bot = nil
            
            super.init(b: b, n: n, name: op.name, color: op.color, rounded: true)
        } else {
            op = nil
            bot = Online.bots.randomElement() ?? Bot("o", 0, 0)
//            print(bot?.name ?? "", bot?.skill ?? 0)
            
            let skill = bot?.skill ?? 0
            let squaredSkill = (2-skill)*skill
            
            super.init(b: b, n: n, name: bot?.name ?? "o", color: bot?.color ?? 0,
                       // TODO keep toyin
                       lineP: [3: squaredSkill, -3: squaredSkill, 2: squaredSkill],
                       dirStats: Array(repeating: squaredSkill, count: 76),
                       depth: Int(skill*10),
                       w2BlockP: skill,
                       // my points on the left
                       lineScore: [0,2,5-skill*7,1+skill*4,1,2+skill*5,2-skill*10+squaredSkill*10,2,0],
                       bucketP: skill
            )
        }
    }
    
    override func move() {
        if self.op != nil {
            FB.main.gotOnlineMove = { move, time in
                Game.main.processMove(move, for: self.n, num: self.b.numMoves())
            }
        } else {
            super.move()
        }
    }
    
    override func getPause() -> Double {
        if b.move[0].count < 2 {
            return range(from: (1,1), to: (2,5))
        } else if b.move[0].count < 5 {
            return range(from: (1,5), to: (4,15))
        } else if b.hasW1(0) || b.hasW1(1) {
            return range(from: (1,4), to: (3,15))
        } else if b.hasW2(0, depth: 2) == true || b.hasW2(1, depth: 2) == true {
            return range(from: (1,3), to: (8,20))
        } else if b.hasW2(0, depth: 10, deadline: 2) != false || b.hasW2(1, depth: 10, deadline: 2) != false {
            return range(from: (5,10), to: (30,30))
        } else {
            return range(from: (3,7), to: (20,30))
        }
    }
    
    private func range(from low: (Double, Double), to high: (Double, Double)) -> Double {
        guard let skill = bot?.skill else { return 1 }
        return .random(in: (low.0 - (low.1 - low.0)*skill)...(high.0 + (high.1 - high.0)*skill))
    }
    
    struct Bot {
        let name: String
        let color: Int
        let skill: Double
        
        init(_ name: String, _ color: Int, _ skill: Double) {
            self.name = name
            self.color = color
            self.skill = skill
        }
    }
}
