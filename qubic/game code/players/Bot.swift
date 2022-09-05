//
//  Bot.swift
//  qubic
//
//  Created by Chris McElroy on 6/14/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

class Bot: Player {
	let bot: BotData
	let id: Int
	
	init(b: Board, n: Int, id: Int) {
		self.id = id
		bot = Bot.bots[id]
		
//   	let skill = bot.skill ?? 0
//  	let squaredSkill = (2-skill)*skill
		
		super.init(b: b, n: n, name: bot.name, color: bot.color, rounded: false,
				   lineP: [3: bot.offAtt*4.5, -3: bot.defAtt*3.5, 2: bot.offAtt],
				   dirStats: Player.setStats(hs: min(1, bot.care*6), vs: min(1, bot.care*2.4), hd: min(1, bot.care*2), vd: min(1, bot.care*1.5), md: min(1, bot.care*1.7)),
				   depth: bot.depth,
				   w2BlockP: bot.defAtt,
				   // my points on the left
				   lineScore: [0,0,bot.offAtt*2-bot.defAtt*3,3+bot.offAtt*5,1,3+bot.defAtt*5,2-bot.defAtt*3,0,0],
				   bucketP: 1-bot.randomness*bot.randomness
		)
		
		print("bot", "off:", Int(self.bot.offAtt*1000), "/", Int((lineP[3]!)*1000), "def:", Int(self.bot.defAtt*1000), "/", Int((lineP[-3])!*1000), "care", Int(self.bot.care*1000))
		for l in [0, 32, 48, 56, 72] {
			let to = Int((lineP[3]!)*dirStats[l]*1000)
			let td = Int((lineP[-3]!)*dirStats[l]*1000)
			let dub = Int((lineP[2]!)*dirStats[l]*1000)
			print(l, "dir:", Int(self.dirStats[l]*1000), "\ttotal off:", to >= 1000 ? "max" : to, "\ttotal def:", td >= 1000 ? "max" : td, "\tdub", dub >= 1000 ? "max" : dub)
		}
	}
	
	override func move() {
		let rush = Game.main.totalTime == nil ? 1 : max(1, 1+4*(1-(Game.main.times[n].last ?? 1)/50))
		self.depth = Int(Double(bot.depth)/rush)
		super.move()
	}
	
	override func getPause() -> Double {
		let rush = Game.main.totalTime == nil ? 1 : max(1, 1+4*(1-(Game.main.times[n].last ?? 1)/50))
		if b.move[0].count < 2 {
			return range(from: (1,1), to: (2,5))/rush
		} else if b.move[0].count < 5 {
			return range(from: (1,5), to: (4,8))/rush
		} else if b.hasW1(0) || b.hasW1(1) {
			return range(from: (1,2), to: (3,10))/rush
		} else if b.hasW2(0, depth: 2) == true || b.hasW2(1, depth: 2) == true {
			return range(from: (1,3), to: (2,10))/rush
		} else if b.hasW2(0, depth: 10, time: 2, valid: { gameNum == Game.main.gameNum }) != false || b.hasW2(1, depth: 10, time: 2, valid: { gameNum == Game.main.gameNum }) != false {
			return range(from: (2,3), to: (5,10))/rush
		} else {
			return range(from: (2,1), to: (5,10))/rush
		}
	}
	
	private func range(from low: (Double, Double), to high: (Double, Double)) -> Double {
		return .random(in: (low.1 + (low.0 - low.1)*bot.speed)...(high.1 + (high.0 - high.1)*bot.speed))
	}
	
	struct BotData {
		let name: String
		let color: Int
		let speed: Double
		let offAtt: Double
		let defAtt: Double
		let depth: Int
		let randomness: Double
		
		var care: Double { (offAtt + defAtt)/2 }
		
		func toDict() -> [String: Any] {
			[
				Key.name.rawValue: name,
				Key.color.rawValue: color,
				Key.speed.rawValue: speed,
				Key.offAtt.rawValue: offAtt,
				Key.defAtt.rawValue: defAtt,
				Key.depth.rawValue: depth,
				Key.randomness.rawValue: randomness
			]
		}
		
		init(name: String, color: Int, speed: Double, offAtt: Double, defAtt: Double, depth: Int, randomness: Double) {
			self.name = name
			self.color = color
			self.speed = speed
			self.offAtt = offAtt
			self.defAtt = defAtt
			self.depth = depth
			self.randomness = randomness
		}
		
		init (from dict: [String: Any]) {
			name = dict[Key.name.rawValue] as? String ?? "bot"
			color = dict[Key.color.rawValue] as? Int ?? 2
			speed = dict[Key.speed.rawValue] as? Double ?? 0.5
			offAtt = dict[Key.offAtt.rawValue] as? Double ?? 0.5
			defAtt = dict[Key.defAtt.rawValue] as? Double ?? 0.5
			depth = dict[Key.depth.rawValue] as? Int ?? 4
			randomness = dict[Key.randomness.rawValue] as? Double ?? 0.5
		}
	}
}
