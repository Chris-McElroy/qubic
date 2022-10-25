//
//  FB.swift
//  qubic
//
//  Created by Chris McElroy on 3/28/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import OrderedCollections

class FB: ObservableObject {
    static let main = FB()
    
    var ref = Database.database().reference()
    var playerDict: [String: PlayerData] = [:]
	@Published var pastGamesDict: [OrderedDictionary<Int, GameData>] = Array(repeating: [:], count: 5)
    var myGameData: GameData? = nil
    var opGameData: GameData? = nil
    var op: PlayerData? = nil
    var onlineInviteState: MatchingState = .stopped
    var gotOnlineMove: ((Int, Double, Int) -> Void)? = nil
    var cancelOnlineSearch: (() -> Void)? = nil
    
    func start() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                Storage.set(user.uid, for: .uuid)
				myID = user.uid
                self.checkVersion()
                self.updateMyData()
				self.updateMyStats()
				self.observePlayers()
				self.observePastGames()
				self.startActiveTimer()
				// removed finished online game
            } else {
                // should only happen once, when they first use the app
                Auth.auth().signInAnonymously() { (authResult, error) in
                    if let error = error {
                        print("Sign in error:", error)
                    }
                }
            }
        }
    }
	
	func startActiveTimer() {
		let myActiveRef = ref.child("active/\(myID)")
		myActiveRef.setValue(Date.ms)
		Timer.every(30, run: {
			myActiveRef.setValue(Date.ms)
		})
	}
    
    func checkVersion() {
		let versionRef = ref.child("newestBuild/\(versionType.rawValue)")
		versionRef.removeAllObservers()
		versionRef.observe(DataEventType.value, with: { snapshot in
			Layout.main.updateAvailable = snapshot.value as? Int ?? 0 > buildNumber
		})
    }
    
    func observePlayers() {
		let playerRef = ref.child("players")
		playerRef.removeAllObservers()
		playerRef.observe(DataEventType.value, with: { snapshot in
            if let dict = snapshot.value as? [String: [String: Any]] {
                for entry in dict {
					self.playerDict[entry.key] = PlayerData(from: entry.value, id: entry.key)
                }
            }
        })
    }
    
	func observePastGames() {
		let gameRef = ref.child("games/\(myID)")
		gameRef.removeAllObservers()
		gameRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			if let dict = snapshot.value as? [String: [String: Any]] {
				for entry in dict.sorted(by: { $0.key < $1.key }) {
					let data = GameData(from: entry.value, gameID: Int(entry.key) ?? 0)
					guard data.state.ended else { continue }
					// order is preserved even when entries are updated
					let i: Int
					if data.mode == .local { i = 0 }
					else if data.mode == .bot { i = 1 }
					else if data.mode == .online { i = 2 }
					else if data.mode.train { i = 3 }
					else if data.mode.solve { i = 4 }
					else { print("error", data.mode); i = 2 }
					self.pastGamesDict[i][data.gameID] = data
				}
			}
		})
	}
	
	func getPastGame(userID: String, gameID: Int, completion: @escaping (GameData) -> Void) {
		print("trying to get game data")
		if let gameData = pastGamesDict.first(where: { $0.keys.contains(gameID) })?[gameID], userID == myID {
			print("got it")
			completion(gameData)
			return
		}
		print("did not get it")
		let gameRef = ref.child("games/\(userID)/\(gameID)")
		gameRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			print("observing")
			if let data = snapshot.value as? [String: Any] {
				let gameData = GameData(from: data, gameID: gameID)
				guard gameData.state.ended else { return }
				completion(gameData)
			}
		})
	}
	
    func updateMyData() {
        let myPlayerRef = ref.child("players/\(myID)")
        let name = Storage.string(.name) ?? ""
        let color = Storage.int(.color)
        myPlayerRef.setValue([Key.name.rawValue: name, Key.color.rawValue: color])
    }
	
	func updateMyStats() {
		let myStatsRef = ref.child("stats/\(myID)")
		let train = Storage.array(.train) as? [Bool] ?? []
		let streak = Storage.int(.streak)
		let lastDC = Storage.int(.lastDC)
		let currentDaily = Storage.int(.currentDaily)
		let dailyHistory = Storage.dictionary(.dailyHistory) as? [String: [Bool]] ?? [:]
		let simple = Storage.array(.simple) as? [Bool] ?? []
		let common = Storage.array(.common) as? [Bool] ?? []
		let tricky = Storage.array(.tricky) as? [Bool] ?? []
		let solves = Storage.array(.solvedBoards) as? [String] ?? []
		let solveBoardVersion = Storage.int(.solveBoardsVersion)
		let tutorialPlays = Storage.int(.playedTutorial)
		myStatsRef.setValue([
			Key.buildNumber.rawValue: buildNumber,
			Key.versionType.rawValue: versionType.rawValue,
			Key.train.rawValue: train,
			Key.streak.rawValue: streak,
			Key.lastDC.rawValue: lastDC,
			Key.currentDaily.rawValue: currentDaily,
			Key.dailyHistory.rawValue: dailyHistory,
			Key.simple.rawValue: simple,
			Key.common.rawValue: common,
			Key.tricky.rawValue: tricky,
			Key.solvedBoards.rawValue: solves,
			Key.solveBoardsVersion.rawValue: solveBoardVersion,
			Key.playedTutorial.rawValue: tutorialPlays
		])
	}
    
    func postFeedback(name: String, email: String, feedback: String) {
        let feedbackRef = ref.child("feedback/\(myID)/\(Date.ms)")
        feedbackRef.setValue([Key.name.rawValue: name, Key.email.rawValue: email, Key.feedback.rawValue: feedback])
    }
    
    func uploadSolveBoard(_ string: String, key: String) {
		ref.child("solveBoards/\(myID)/\(key)/\(Date.ms)").setValue(string)
    }
	
	func uploadMisses(_ string: String, key: String) {
		ref.child("misses/\(myID)/\(key)/\(Date.ms)").setValue(string)
	}
	
	func uploadGame(_ game: Game) {
		let startTime = Date.ms
		let gameData = GameData(from: game, gameID: startTime)
		ref.child("games/\(myID)/\(startTime)").setValue(gameData.toDict())
		myGameData = gameData
	}
    
	func getOnlineMatch(onMatch: @escaping () -> Void) {
		Layout.main.searchingOnline = true
        onlineInviteState = .invited
        myGameData = nil
        opGameData = nil
		
		let timeLimit: Double = [-1, 10, 20, 30, 40, 60, 120, 180, 300, 600][Layout.main.playSelection[2]]
		let humansOnly = Layout.main.playSelection[1] == 2
        var possOp: Set<String> = []
        var myInvite = OnlineInviteData(timeLimit: timeLimit)
        
        let onlineRef = ref.child("onlineInvites")
        onlineRef.removeAllObservers()
        
        // send invite
        onlineRef.child(myID).setValue(myInvite.toDict())
        
        // set end time
        var botTimer: Timer? = nil
        if !humansOnly {
			// TODO fold this into a timer list
            botTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { _ in
                if self.onlineInviteState == .invited || self.onlineInviteState == .offered {
                    self.finishedGame(with: .error)
                    self.onlineInviteState = .stopped
                    onlineRef.child(myID).removeValue()
                    onlineRef.removeAllObservers()
					Layout.main.searchingOnline = false
					onMatch()
                }
            })
        }
        
        // set cancel func
        cancelOnlineSearch = {
            self.onlineInviteState = .stopped
            botTimer?.invalidate()
            onlineRef.removeAllObservers()
            onlineRef.child(myID).removeValue()
			Layout.main.searchingOnline = false
            self.cancelOnlineSearch = nil
        }
        
        // check for others
        onlineRef.observe(DataEventType.value, with: { snapshot in
            guard let dict = snapshot.value as? [String: [String: Any]] else { return }
            switch self.onlineInviteState {
            case .invited:
                for entry in dict where entry.key != myID {
                    let opInvite = OnlineInviteData(from: entry)
                    if opInvite.valid && opInvite.timeLimit == timeLimit {
                        // possOp guards for those who went offline without
                        // deleting an offer to you
                        if opInvite.opID != myID { possOp.insert(opInvite.ID) }
                        if opInvite > myInvite && opInvite.opID == "" {
                            self.onlineInviteState = .offered
                            myInvite.opID = entry.key
                            onlineRef.child(myID).setValue(myInvite.toDict())
                            break
                        }
                        if opInvite < myInvite && opInvite.opID == myID && possOp.contains(opInvite.ID) {
                            self.onlineInviteState = .matched
                            myInvite.opID = entry.key
                            onlineRef.child(myID).setValue(myInvite.toDict())
                            playGame(opInvite: opInvite)
                            break
                        }
                    }
                }
                break
            case .offered:
                for entry in dict where entry.key != myID {
                    let opInvite = OnlineInviteData(from: entry)
                    if opInvite.valid && opInvite.timeLimit == timeLimit &&
                        opInvite.opID == myID && (myInvite.opID == opInvite.ID || myInvite.opID == "") &&
                        possOp.contains(opInvite.ID) {
                        // TODO do i need to check for newer here? think out 4 person example
                        self.onlineInviteState = .matched
                        myInvite.opID = opInvite.ID
                        onlineRef.child(myID).setValue(myInvite.toDict())
                        playGame(opInvite: opInvite)
                        break
                    }
                }
                let offeredOp = OnlineInviteData(from: dict[myInvite.opID] ?? [:], ID: myInvite.opID)
                if !offeredOp.valid || offeredOp.timeLimit != timeLimit || !["", myID].contains(offeredOp.opID) {
                    self.onlineInviteState = .invited
                    myInvite.opID = ""
                    onlineRef.child(myID).setValue(myInvite.toDict())
                }
                break
            case .matched:
                if self.myGameData?.state == .new {
                    let offeredOp = OnlineInviteData(from: dict[myInvite.opID] ?? [:], ID: myInvite.opID)
                    if !offeredOp.valid || offeredOp.timeLimit != timeLimit || !["", myID].contains(offeredOp.opID) {
                        self.onlineInviteState = .invited
                        self.myGameData = nil
                        self.opGameData = nil
                        myInvite.opID = ""
                        onlineRef.child(myID).setValue(myInvite.toDict())
                    }
                }
                break
            case .stopped:
                onlineRef.child(myID).removeValue()
                onlineRef.removeAllObservers()
                break
            }
        })
        
        func playGame(opInvite: OnlineInviteData) {
            // post game
            let myData = GameData(myInvite: myInvite, opInvite: opInvite)
            let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
            myGameData = myData
            myGameRef.setValue(myData.toDict())
            
            // search for their post
            let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
            opGameRef.removeAllObservers()
            opGameRef.observe(DataEventType.value, with: { snapshot in
                guard var myData = self.myGameData else {
                    myGameRef.child(Key.state.rawValue).setValue(GameState.error.rawValue)
                    self.myGameData = nil
                    self.opGameData = nil
                    opGameRef.removeAllObservers()
                    return
                }
                guard let dict = snapshot.value as? [String: Any] else { return }
                let opData = GameData(from: dict, gameID: myData.opGameID)
                if opData.valid && opData.opID == myID && opData.opGameID == myData.gameID {
                    if opData.state == .active && self.onlineInviteState != .stopped {
                        // they've seen your game post so you can take down your invite
                        self.onlineInviteState = .stopped
                        onlineRef.child(myID).removeValue()
                        onlineRef.removeAllObservers()
                    }
                    if myData.state == .new {
                        guard let op = self.playerDict[myData.opID] else { return }
                        myData.state = .active
                        self.myGameData = myData
                        self.opGameData = opData
                        self.op = op
                        myGameRef.setValue(myData.toDict())
                        botTimer?.invalidate()
						Layout.main.searchingOnline = false
						onMatch()
                    }
                    if myData.state == .active {
                        self.opGameData = opData
                        let nextCount = myData.opMoves.count + 1
                        // don't include other end states because those are implicit with the moves
                        if opData.state == .error || opData.state == .myResign || opData.state == .myTimeout {
                            Game.main.endGame(with: opData.state.mirror())
                        } else if opData.myMoves.count == nextCount && opData.myTimes.count == nextCount {
                            guard let newMove = opData.myMoves.last else { return }
                            guard let newTime = opData.myTimes.last else { return }
                            
                            myData.opMoves.append(newMove)
                            myData.opTimes.append(newTime)
                            self.myGameData = myData
                            myGameRef.setValue(myData.toDict())
                            
                            self.gotOnlineMove?(newMove, newTime, myData.myMoves.count + myData.opMoves.count - 3)
                        }
                    }
                }
            })
        }
    }
    
	func sendMyMove(p: Int, time: Double) {
        guard var myData = myGameData else { return }
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
        myData.myMoves.append(p)
        myData.myTimes.append(time)
		myData.myMoveTimes.append(Date.ms)
        self.myGameData = myData
        myGameRef.setValue(myData.toDict())
    }
	
	func sendOpMove(p: Int, time: Double) {
		guard var myData = myGameData else { return }
		let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
		myData.opMoves.append(p)
		myData.opTimes.append(time)
		myData.opMoveTimes.append(Date.ms)
		self.myGameData = myData
		myGameRef.setValue(myData.toDict())
	}
	
	func undoMyMove(p: Int) {
		guard var myData = myGameData else { return }
		let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
		guard myData.myMoves.last == p else {
			print("FB undo move error", p, myData.myMoves.last ?? -2, myData.myMoves, myData)
			return
		}
		myData.myMoves = myData.myMoves.dropLast()
		myData.myTimes = myData.myTimes.dropLast()
		myData.myMoveTimes = myData.myMoveTimes.dropLast()
		self.myGameData = myData
		myGameRef.setValue(myData.toDict())
	}
	
	func undoOpMove(p: Int) {
		guard var myData = myGameData else { return }
		let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
		guard myData.opMoves.last == p else {
			print("FB undo move error", p, myData.opMoves.last ?? -2, myData.opMoves, myData)
			return
		}
		myData.opMoves = myData.opMoves.dropLast()
		myData.opTimes = myData.opTimes.dropLast()
		myData.opMoveTimes = myData.opMoveTimes.dropLast()
		self.myGameData = myData
		myGameRef.setValue(myData.toDict())
	}
    
	func finishedGame(with state: GameState, newHints: Bool = false) {
        guard var myData = myGameData else { return }
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
        let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
        myData.state = state
		myData.endTime = Date.ms
		myData.hints = myData.hints || newHints
        op = nil
        myGameData = nil
        opGameData = nil
        opGameRef.removeAllObservers()
        myGameRef.setValue(myData.toDict())
		observePastGames()
    }
	
	func uploadBots() {
		for (i, bot) in Bot.bots.enumerated() {
			ref.child("bots/\(i)").setValue(bot.toDict())
		}
	}

    struct GameData {
        let gameID: Int         // my gameID
		let mode: GameMode		// the game mode
        let myTurn: Int         // 0 for moves first
        let opID: String        // op id
        let opGameID: Int       // op gameID
        var hints: Bool         // true for sandbox mode
        var state: GameState    // current state of the game
		var setupNum: Int    	// the setup number for the game
		var presetCount: Int  	// the number of preset moves in the game
		var myMoves: [Int]      // my moves
		var opMoves: [Int]      // op moves
        var myTimes: [Double] 	// times remaining on my clock after each of my moves
        var opTimes: [Double]  	// times remaining on op clock after each of their moves
		var myMoveTimes: [Int]	// time each move is made
		var opMoveTimes: [Int]	// time each move is made
		var endTime: Int	// time the game ended
        let valid: Bool         // whether the given dict was valid
		
		var totalTime: Double? {
			myTimes.first == -1 ? nil : myTimes.first
		}
        
		init(from dict: [String: Any], gameID: Int) {
			// TODO handle better if their dict is invalid (esp if they have an old version)
            valid = (
//				dict[Key.mode.rawValue] as? Int != nil &&
				dict[Key.myTurn.rawValue] as? Int != nil &&
				dict[Key.opID.rawValue] as? String != nil &&
				dict[Key.opGameID.rawValue] as? Int != nil &&
				dict[Key.hints.rawValue] as? Int != nil &&
				dict[Key.state.rawValue] as? Int != nil &&
				dict[Key.myTimes.rawValue] as? [Double] != nil &&
				dict[Key.opTimes.rawValue] as? [Double] != nil &&
				dict[Key.myMoves.rawValue] as? [Int] != nil &&
				dict[Key.opMoves.rawValue] as? [Int] != nil // &&
//				dict[Key.myMoveTimes.rawValue] as? [Int] != nil &&
//				dict[Key.opMoveTimes.rawValue] as? [Int] != nil &&
//				dict[Key.endTime.rawValue] as? Int != nil &&
//				dict[Key.presetCount.rawValue] as? Int != nil &&
//				dict[Key.setupNum.rawValue] as? Int != nil
            )
            
            self.gameID = gameID
			mode = GameMode(rawValue: dict[Key.mode.rawValue] as? Int ?? 12) ?? .online
            myTurn = dict[Key.myTurn.rawValue] as? Int ?? 0
            opID = dict[Key.opID.rawValue] as? String ?? ""
            opGameID = dict[Key.opGameID.rawValue] as? Int ?? 0
            hints = 1 == dict[Key.hints.rawValue] as? Int ?? 0
            state = GameState(rawValue: dict[Key.state.rawValue] as? Int ?? 0) ?? .error
			presetCount = dict[Key.presetCount.rawValue] as? Int ?? 0
			setupNum = dict[Key.setupNum.rawValue] as? Int ?? 0
            myTimes = dict[Key.myTimes.rawValue] as? [Double] ?? []
            opTimes = dict[Key.opTimes.rawValue] as? [Double] ?? []
            myMoves = dict[Key.myMoves.rawValue] as? [Int] ?? []
            opMoves = dict[Key.opMoves.rawValue] as? [Int] ?? []
			myMoveTimes = dict[Key.myMoveTimes.rawValue] as? [Int] ?? []
			opMoveTimes = dict[Key.opMoveTimes.rawValue] as? [Int] ?? []
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
        }
		
		init(from game: Game, gameID: Int) {
			valid = true
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
    
    struct PlayerData {
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
    }
    
    struct OnlineInviteData: Comparable {
        let ID: String
        let gameID: Int
        let timeLimit: Double
        var opID: String
        let valid: Bool
        
        init(from entry: Dictionary<String, [String: Any]>.Element) {
            self.init(from: entry.value, ID: entry.key)
        }
        
        init(from dict: [String: Any], ID: String) {
            valid = (
                dict[Key.gameID.rawValue] as? Int != nil &&
                    dict[Key.timeLimit.rawValue] as? Double != nil &&
                    dict[Key.opID.rawValue] as? String != nil
            )
            
            self.ID = ID
            gameID = dict[Key.gameID.rawValue] as? Int ?? 0
            timeLimit = dict[Key.timeLimit.rawValue] as? Double ?? 0
            opID = dict[Key.opID.rawValue] as? String ?? ""
        }
        
        init(timeLimit: Double) {
            ID = myID
            gameID = Date.ms
            self.timeLimit = timeLimit
            opID = ""
            valid = true
        }
        
        func toDict() -> [String: Any] {
            [
                Key.gameID.rawValue: gameID,
                Key.timeLimit.rawValue: timeLimit,
                Key.opID.rawValue: opID
            ]
        }
        
        static func <(lhs: Self, rhs: Self) -> Bool {
            if lhs.gameID == rhs.gameID {
                return lhs.ID < rhs.ID
            } else {
                return lhs.gameID < rhs.gameID
            }
        }
        
        static func >(lhs: Self, rhs: Self) -> Bool {
            if lhs.gameID == rhs.gameID {
                return lhs.ID > rhs.ID
            } else {
                return lhs.gameID > rhs.gameID
            }
        }
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.gameID == rhs.gameID && lhs.ID == rhs.ID
        }
    }
    
    enum MatchingState {
        case invited, offered, matched, stopped
    }
}


