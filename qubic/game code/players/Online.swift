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
            
            super.init(b: b, n: n, name: op.name, color: op.color, rounded: true, local: false)
        } else {
            op = nil
            let bot = Online.bots.randomElement()!
            self.bot = bot
            
            print(bot)
            
//            let skill = bot.skill ?? 0
//            let squaredSkill = (2-skill)*skill
            
            super.init(b: b, n: n, name: bot.name, color: bot.color, rounded: false,
                       lineP: [3: bot.offAtt*3, -3: bot.defAtt, 2: bot.offAtt],
                       dirStats: Player.setStats(hs: min(1, bot.care*6), vs: min(1, bot.care*2.4), hd: min(1, bot.care*2), vd: min(1, bot.care*1.2), md: min(1, bot.care*1.8)),
                       depth: bot.depth,
                       w2BlockP: bot.defAtt,
                       // my points on the left
                       lineScore: [0,0,bot.offAtt*2-bot.defAtt*3,3+bot.offAtt*5,1,3+bot.defAtt*5,2-bot.defAtt*3,0,0],
                       bucketP: 1-bot.randomness*bot.randomness
            )
        }
    }
    
    override func move() {
		let setup = b.getSetup()
        if self.op != nil {
            FB.main.gotOnlineMove = { move, time, num in
				Game.main.processMove(move, for: self.n, setup: setup, time: time)
            }
        } else {
            let rush = Game.main.totalTime == nil ? 1 : max(1, 1+4*(1-(Game.main.times[n].last ?? 1)/50))
            self.depth = Int(Double(bot?.depth ?? 1)/rush)
            super.move()
        }
    }
    
    override func getPause() -> Double {
		let rush = Game.main.totalTime == nil ? 1 : max(1, 1+4*(1-(Game.main.times[n].last ?? 1)/50))
        if b.move[0].count < 2 {
            return range(from: (1,1), to: (2,5))/rush
        } else if b.move[0].count < 5 {
            return range(from: (1,5), to: (4,15))/rush
        } else if b.hasW1(0) || b.hasW1(1) {
            return range(from: (1,2), to: (3,10))/rush
        } else if b.hasW2(0, depth: 2) == true || b.hasW2(1, depth: 2) == true {
            return range(from: (1,3), to: (2,15))/rush
		} else if b.hasW2(0, depth: 10, time: 2, valid: { gameNum == Game.main.gameNum }) != false || b.hasW2(1, depth: 10, time: 2, valid: { gameNum == Game.main.gameNum }) != false {
            return range(from: (2,3), to: (8,20))/rush
        } else {
            return range(from: (2,1), to: (8,15))/rush
        }
    }
    
    private func range(from low: (Double, Double), to high: (Double, Double)) -> Double {
        guard let bot = bot else { return 1 }
        return .random(in: (low.1 + (low.0 - low.1)*bot.speed)...(high.1 + (high.0 - high.1)*bot.speed))
    }
    
    struct Bot {
        let name: String
        let color: Int
        let speed: Double
        let offAtt: Double
        let defAtt: Double
        let depth: Int
        let randomness: Double
        
        var care: Double { (offAtt + defAtt)/2 }
    }
}
