//
//  GameData.swift
//  qubic
//
//  Created by Chris McElroy on 6/21/23.
//  Copyright © 2023 XNO LLC. All rights reserved.
//

import Foundation
import OrderedCollections

struct GameData: Equatable {
	// theoretically kept identically to the online game dict
	// game IDs as Strings to comply with PList formatting
	static var all: [String: [String: Any]] = Storage.dictionary(.myGames) as? [String: [String: Any]] ?? [:]
	
	let gameID: Int         // my gameID
	let mode: GameMode		// the game mode (note that earlier versions weren't posting this, but they should all correctly be updated to online)
	let myTurn: Int         // 0 for moves first
	let opID: String        // op id
	let opGameID: Int       // op gameID
	var hints: Bool         // true for sandbox mode
	var state: GameState    // current state of the game
	var setupNum: Int    	// the setup number for the game (earlier versions didn't post this, but they should be all correctly updated to 0)
	var presetCount: Int  	// the number of preset moves in the game (earlier versions didn't post this, but they should be all correctly updated to 0)
	var myMoves: [Int]      // my moves
	var opMoves: [Int]      // op moves
	var myTimes: [Double] 	// times remaining on my clock after each of my moves
	var opTimes: [Double]  	// times remaining on op clock after each of their moves
	var myMoveTimes: [Int]	// datetime when each move is made (note that earlier versions were not posting these, so this may be just [gameID])
	var opMoveTimes: [Int]	// datetime when each move is made (note that earlier versions were not posting these, so this may be just [gameID])
	var endTime: Int		// time the game ended (note that this can be -1 if connection was lost/on earlier versions)
	var valid: Bool         // whether the given dict was valid
	var updated: Bool       // whether the given dict includes the newest fields
	
	var totalTime: Double? {
		myTimes.first == -1 ? nil : myTimes.first
	}
	
	init(from dict: [String: Any], gameID: Int) {
		valid = (
			dict[Key.myTurn.rawValue] as? Int != nil &&
			dict[Key.opID.rawValue] as? String != nil &&
			dict[Key.opGameID.rawValue] as? Int != nil &&
			dict[Key.hints.rawValue] as? Int != nil &&
			dict[Key.state.rawValue] as? Int != nil &&
			dict[Key.myTimes.rawValue] as? [Double] != nil &&
			dict[Key.opTimes.rawValue] as? [Double] != nil &&
			dict[Key.myMoves.rawValue] as? [Int] != nil &&
			dict[Key.opMoves.rawValue] as? [Int] != nil
		)
		
		// laterDO move these to valid once everything's updated
		updated = (
			dict[Key.mode.rawValue] as? Int != nil &&
			dict[Key.myMoveTimes.rawValue] as? [Int] != nil &&
			dict[Key.opMoveTimes.rawValue] as? [Int] != nil &&
			dict[Key.endTime.rawValue] as? Int != nil &&
			dict[Key.presetCount.rawValue] as? Int != nil &&
			dict[Key.setupNum.rawValue] as? Int != nil
		)
		
		self.gameID = gameID
		mode = GameMode(rawValue: dict[Key.mode.rawValue] as? Int ?? 12) ?? .online // 12 is online
		myTurn = dict[Key.myTurn.rawValue] as? Int ?? 0
		opID = dict[Key.opID.rawValue] as? String ?? ""
		opGameID = dict[Key.opGameID.rawValue] as? Int ?? 0
		hints = 1 == (dict[Key.hints.rawValue] as? Int ?? 0)
		state = GameState(rawValue: dict[Key.state.rawValue] as? Int ?? 0) ?? .error // 0 is error
		presetCount = dict[Key.presetCount.rawValue] as? Int ?? 0
		setupNum = dict[Key.setupNum.rawValue] as? Int ?? 0
		myTimes = dict[Key.myTimes.rawValue] as? [Double] ?? [-1]
		opTimes = dict[Key.opTimes.rawValue] as? [Double] ?? [-1]
		let myMoves = dict[Key.myMoves.rawValue] as? [Int] ?? [-1]
		let opMoves = dict[Key.opMoves.rawValue] as? [Int] ?? [-1]
		self.myMoves = myMoves
		self.opMoves = opMoves
		if myMoves.contains(where: { $0 != -1 && opMoves.contains($0) }) { valid = false }
		myMoveTimes = dict[Key.myMoveTimes.rawValue] as? [Int] ?? [gameID]
		opMoveTimes = dict[Key.opMoveTimes.rawValue] as? [Int] ?? [gameID]
		endTime = dict[Key.endTime.rawValue] as? Int ?? -1
	}
	
	init(myInvite: OnlineInviteData, opInvite: OnlineInviteData) {
		gameID = myInvite.gameID
		mode = .online
		myTurn = myInvite > opInvite ? myInvite.gameID % 2 : (opInvite.gameID % 2)^1
		opID = myInvite.opID
		opGameID = opInvite.gameID
		hints = false
		state = .new
		presetCount = 0
		setupNum = 0
		myTimes = [myInvite.timeLimit]
		opTimes = [myInvite.timeLimit]
		myMoves = [-1]
		opMoves = [-1]
		myMoveTimes = [gameID]
		opMoveTimes = [gameID]
		endTime = -1
		valid = true
		updated = true
	}
	
	init(from game: Game, gameID: Int) {
		valid = true
		updated = true
		self.gameID = gameID
		mode = game.mode
		myTurn = game.myTurn
		let op = game.player[game.myTurn^1]
		opID = op.id
		opGameID = 0
		hints = game.hints
		state = game.gameState
		presetCount = game.preset.count
		setupNum = game.setupNum
		myTimes = [game.totalTime ?? -1]
		opTimes = [game.totalTime ?? -1]
		myMoves = [-1]
		opMoves = [-1]
		myMoveTimes = [gameID]
		opMoveTimes = [gameID]
		for (i, p) in game.preset.enumerated() {
			if i % 2 == game.myTurn {
				myTimes.append(game.totalTime ?? -1)
				myMoves.append(p)
				myMoveTimes.append(gameID)
			} else {
				opTimes.append(game.totalTime ?? -1)
				opMoves.append(p)
				opMoveTimes.append(gameID)
			}
		}
		endTime = -1
	}
	
	func toDict() -> [String: Any] {
		[
			Key.mode.rawValue: mode.rawValue,
			Key.myTurn.rawValue: myTurn,
			Key.opID.rawValue: opID,
			Key.opGameID.rawValue: opGameID,
			Key.hints.rawValue: hints ? 1 : 0,
			Key.state.rawValue: state.rawValue,
			Key.presetCount.rawValue: presetCount,
			Key.setupNum.rawValue: setupNum,
			Key.myTimes.rawValue: myTimes,
			Key.opTimes.rawValue: opTimes,
			Key.myMoves.rawValue: myMoves,
			Key.opMoves.rawValue: opMoves,
			Key.myMoveTimes.rawValue: myMoveTimes,
			Key.opMoveTimes.rawValue: opMoveTimes,
			Key.endTime.rawValue: endTime
		]
	}
	
	func orderedMoves() -> [Int] {
		if myMoves.isEmpty || opMoves.isEmpty { return [] }
		
		var firstMoves = myTurn == 0 ? myMoves.dropFirst() : opMoves.dropFirst()
		var secondMoves = myTurn == 1 ? myMoves.dropFirst() : opMoves.dropFirst()
		let diff = firstMoves.count - secondMoves.count
		
		guard diff == 0 || diff == 1 else { return [] }
		
		var list: [Int] = []
		while !firstMoves.isEmpty {
			list.append(firstMoves.removeFirst())
			if !secondMoves.isEmpty {
				list.append(secondMoves.removeFirst())
			}
		}
		return list
	}
	
	func getTimes() -> [[Double]] {
		return myTurn == 0 ? [myTimes, opTimes] : [opTimes, myTimes]
	}
}

struct GameSummary {
	// updated when the app is loaded or a game is ended
	// 		(updated when app is loaded in PastGamesView, on appear of button)
	// i could either have this be one big dict or 5 separate variables but i see no reason to unless performance becomes an issue
	static var pastGames: [OrderedDictionary<Int, GameSummary>] = [[:], [:], [:], [:], [:]]
	
	// updated when the app is loaded or a game is exited // laterDO do this
//	static var myActiveGames: [OrderedDictionary<Int, GameSummary>] = [[:], [:], [:], [:], [:]]
	
	let gameID: Int         // my gameID
	let mode: GameMode		// the game mode
	let myTurn: Int         // 0 for moves first
	var op: PlayerData		// op data
	var state: GameState    // current state of the game
	var timeLimit: Double	// time limit of the game
	
	init(gameID: Int, mode: GameMode, myTurn: Int, opID: String, state: GameState, timeLimit: Double) {
		self.gameID = gameID
		self.mode = mode
		self.myTurn = myTurn
		self.state = state
		self.timeLimit = timeLimit
		self.op = PlayerData.getData(for: opID, mode: mode)
	}
	
	init(from dict: [String: Any], id: Int) {
		gameID = id
		mode = GameMode(rawValue: dict[Key.mode.rawValue] as? Int ?? 12) ?? .online
		myTurn = dict[Key.myTurn.rawValue] as? Int ?? 0
		state = GameState(rawValue: dict[Key.state.rawValue] as? Int ?? 0) ?? .error
		timeLimit = (dict[Key.myTimes.rawValue] as? [Double] ?? [-1]).first ?? -1
		op = PlayerData.getData(for: dict[Key.opID.rawValue] as? String ?? "", mode: mode)
	}
	
	static func updatePastGames() {
		for (id, game) in GameData.all {
			let summary = GameSummary(from: game, id: Int(id) ?? 0)
			let i = getPastGameCategory(for: summary.mode)
			pastGames[i][summary.gameID] = summary
		}
	}
	
	static func getPastGameCategory(for mode: GameMode) -> Int {
		if mode == .local { return 0 }
		else if mode == .bot { return 1 }
		else if mode == .online { return 2 }
		else if mode.train { return 3 }
		else if mode.solve { return 4 }
		else { print("game category error", mode); return 2 }
	}
}

