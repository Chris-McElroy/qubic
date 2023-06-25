//
//  PlayerData.swift
//  qubic
//
//  Created by Chris McElroy on 6/21/23.
//  Copyright © 2023 XNO LLC. All rights reserved.
//

import Foundation

struct PlayerData {
	// list of player data, kept updated to data posted online
	static var all: [String: PlayerData] = (Storage.dictionary(.players) as? [String: [String: Any]] ?? [:]).reduce(into: [:], {
		$0[$1.key] = PlayerData(from: $1.value, id: $1.key)
	})
	
	let id: String
	let name: String
	var color: Int
	
	init(id: String, name: String, color: Int) {
		self.id = id
		self.name = name
		self.color = color
	}
	
	init(from dict: [String: Any], id: String) {
		self.id = id
		name = dict[Key.name.rawValue] as? String ?? "no name"
		color = dict[Key.color.rawValue] as? Int ?? 0
	}
	
	func toDict() -> [String: Any] {
		[
			Key.name.rawValue: name,
			Key.color.rawValue: color
		]
	}
	
	static func getData(for id: String, mode: GameMode) -> PlayerData {
		if let storedData = all[id] { return storedData } // covers self and other online players
			
		var data: PlayerData
				
		if mode == .online {
			data = all[id] ?? PlayerData(id: id, name: "n/a", color: 4)
		} else if mode == .bot {
			let bot = Bot.bots[Int(id.dropFirst(3)) ?? Int(id) ?? 0]
			data = PlayerData(id: id, name: bot.name, color: bot.color)
		} else if mode.solve {
			let color = [.simple: 7, .common: 8, .tricky: 1][mode] ?? 4
			data = PlayerData(id: id, name: id, color: color)
		} else if mode.train {
			let color = [.novice: 6, .defender: 5, .warrior: 0, .tyrant: 3, .oracle: 2][mode] ?? 8
			data = PlayerData(id: id, name: id, color: color)
		} else {
			data = PlayerData(id: id, name: "friend", color: Storage.int(.color))
		}
		if data.color == Storage.int(.color) {
			data.color = [4, 4, 4, 8, 6, 7, 4, 5, 3][Storage.int(.color)]
		}
		
		return data
	}
}
