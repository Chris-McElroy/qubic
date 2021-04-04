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
    
    override func move(with process: @escaping (Int, UInt64) -> Void) {
        if self.op != nil {
            FB.main.gotOnlineMove = { move, time in
                process(move, self.b.board[self.n])
            }
        } else {
            super.move(with: process)
        }
    }
    
    override func getPause() -> Double {
        let skill = w2BlockP
        
        if b.move[0].count < 2 {
            return .random(in: 1..<(8-skill*5))
        } else if b.move[0].count < 5 {
            return .random(in: (8-skill*6)..<(30-skill*23))
        } else if b.hasW1(0) || b.hasW1(1) {
            return .random(in: (10-skill*9)..<(15-skill*12))
        } else if b.hasW2(0, depth: 2) == true || b.hasW2(1, depth: 2) == true {
            return .random(in: (20-skill*15)..<(30-skill*15))
        } else if b.hasW2(0, depth: 10, deadline: 2) != false || b.hasW2(1, depth: 10, deadline: 2) != false {
            return .random(in: (40-skill*20)..<(60-skill*30))
        } else {
            return .random(in: (10-skill*5)..<(40-skill*10))
        }
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
