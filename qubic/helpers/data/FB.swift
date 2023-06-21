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

class FB {
    static let main = FB()
	
    var ref = Database.database().reference()
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
				self.loadPastGames()
				self.startActiveTimer()
				self.checkOnlineGames()
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
					PlayerData.all[entry.key] = PlayerData(from: entry.value, id: entry.key)
				}
            }
			Storage.set(PlayerData.all.mapValues { $0.toDict() }, for: .players)
			GameSummary.updatePastGames()
        })
    }
    
	func loadPastGames() {
		// TODO when was/is this being called? when do i want it to be called
		// TODO this should load past games from the local games list
//		for entry in dict.sorted(by: { $0.key < $1.key }) {
//			
//			// TODO this should be game summary
//			let data = GameData(from: entry.value, gameID: Int(entry.key) ?? 0)
//			guard data.state.ended else { continue }
//			// order is preserved even when entries are updated
//			let i = FB.getPastGameCategory(for: data.mode)
//			self.pastGamesDict[i][data.gameID] = data
//		}
	}
		
	func checkOnlineGames() {
		let gameRef = ref.child("games/\(myID)")
		gameRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			guard let dict = snapshot.value as? [String: [String: Any]] else { return }
			GameData.all.merge(dict, uniquingKeysWith: {
				// TODO i don't have access to the keys here and that kinda sucks
				let localData = GameData(from: $0, gameID: 0)
				let onlineData = GameData(from: $1, gameID: 0)
				if localData == onlineData {
					return $0
				}
				// TODO if they're not equal i should post the updated version to the cloud, but i can't because i don't have the fucking keys
				// consider just setting the value of the full dict to what the local one is
				// oof even if that's okay data wise i don't like rewriting that much willy nilly
				// maybe i won't even do this at all? i dunno
				print("got overlapping games")
				print("local game:", localData)
				print("oneline game:", onlineData)
				return $0 // $0 is current local value
			})
		})
	}
	
	func getPastGame(userID: String, gameID: Int, completion: @escaping (GameData) -> Void) {
		if let rawGameData = GameData.all[String(gameID)], userID == myID {
			completion(GameData(from: rawGameData, gameID: gameID))
			return
		}
		let gameRef = ref.child("games/\(userID)/\(gameID)")
		gameRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			if let data = snapshot.value as? [String: Any] {
				let gameData = GameData(from: data, gameID: gameID)
				guard gameData.state.ended else { return }
				completion(gameData)
			}
		})
	}
	
	func getPlayerData(for userID: String) -> PlayerData {
		if let data = PlayerData.all[userID] {
			return data
		}
			
		if userID.count < 10 {
			if userID.hasPrefix("bot") {
				let i = Int(userID.dropFirst(3)) ?? 0
				let bot = Bot.bots[i]
				return PlayerData(id: userID, name: bot.name, color: bot.color)
			} else {
				var color: Int = 4
				if userID == "novice" {
					color = 6
				} else if userID == "defender" {
					color = 5
				} else if userID == "warrior" {
					color = 0
				} else if userID == "tyrant" {
					color = 3
				} else if userID == "oracle" {
					color = 2
				} else if userID == "cubist" {
					color = 8
				} else if userID.hasPrefix("daily") {
					color = 4
				} else if userID.hasPrefix("simple") {
					color = 7
				} else if userID.hasPrefix("common") {
					color = 8
				} else if userID.hasPrefix("tricky") {
					color = 1
				}
				
				return PlayerData(id: userID, name: userID, color: color)
			}
		}
			
		return PlayerData(id: "error", name: "unknown", color: 4)
	}
	
    func updateMyData() {
        let myPlayerRef = ref.child("players/\(myID)")
        let name = Storage.string(.name) ?? ""
        let color = Storage.int(.color)
		myPlayerRef.setValue([Key.name.rawValue: name, Key.color.rawValue: color] as [String : Any])
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
		] as [String : Any])
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
	
	func setGameValue(to dict: [String: Any], gameID: Int) {
		ref.child("games/\(myID)/\(gameID)").setValue(dict)
		GameData.all[String(gameID)] = dict
		Storage.set(GameData.all, for: .myGames)
	}
	
	func uploadGame(_ game: Game) {
		let startTime = Date.ms
		let gameData = GameData(from: game, gameID: startTime)
		setGameValue(to: gameData.toDict(), gameID: startTime)
		myGameData = gameData
	}
    
	func getOnlineMatch(onMatch: @escaping () -> Void) {
		Layout.main.searchingOnline = true
        onlineInviteState = .invited
        myGameData = nil
        opGameData = nil
		
		let timeLimit: Double = [15, 30, 180, -1][Layout.main.playSelection[2]]
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
			// laterDO fold this into a timer list
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
                        // laterDO do i need to check for newer here? think out 4 person example
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
            var myData = GameData(myInvite: myInvite, opInvite: opInvite)
            myGameData = myData
			setGameValue(to: myData.toDict(), gameID: myData.gameID)
            
            // search for their post
            let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
            opGameRef.removeAllObservers()
            opGameRef.observe(DataEventType.value, with: { snapshot in
                guard var myData = self.myGameData else {
					myData.state = .error
					self.setGameValue(to: myData.toDict(), gameID: myData.gameID)
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
                        guard let op = PlayerData.all[myData.opID] else { return }
                        myData.state = .active
                        self.myGameData = myData
                        self.opGameData = opData
                        self.op = op
						self.setGameValue(to: myData.toDict(), gameID: myData.gameID)
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
							self.setGameValue(to: myData.toDict(), gameID: myData.gameID)
                            
                            self.gotOnlineMove?(newMove, newTime, myData.myMoves.count + myData.opMoves.count - 3)
                        }
                    }
                }
            })
        }
    }
    
	func sendMyMove(p: Int, time: Double) {
        guard var myData = myGameData else { return }
        myData.myMoves.append(p)
        myData.myTimes.append(time)
		myData.myMoveTimes.append(Date.ms)
        self.myGameData = myData
		setGameValue(to: myData.toDict(), gameID: myData.gameID)
    }
	
	func sendOpMove(p: Int, time: Double) {
		guard var myData = myGameData else { return }
		myData.opMoves.append(p)
		myData.opTimes.append(time)
		myData.opMoveTimes.append(Date.ms)
		self.myGameData = myData
		setGameValue(to: myData.toDict(), gameID: myData.gameID)
	}
	
	func undoMyMove(p: Int) {
		guard var myData = myGameData else { return }
		guard myData.myMoves.last == p else {
			print("FB undo move error", p, myData.myMoves.last ?? -2, myData.myMoves, myData)
			return
		}
		myData.myMoves = myData.myMoves.dropLast()
		myData.myTimes = myData.myTimes.dropLast()
		myData.myMoveTimes = myData.myMoveTimes.dropLast()
		self.myGameData = myData
		setGameValue(to: myData.toDict(), gameID: myData.gameID)
	}
	
	func undoOpMove(p: Int) {
		guard var myData = myGameData else { return }
		guard myData.opMoves.last == p else {
			print("FB undo move error", p, myData.opMoves.last ?? -2, myData.opMoves, myData)
			return
		}
		myData.opMoves = myData.opMoves.dropLast()
		myData.opTimes = myData.opTimes.dropLast()
		myData.opMoveTimes = myData.opMoveTimes.dropLast()
		self.myGameData = myData
		setGameValue(to: myData.toDict(), gameID: myData.gameID)
	}
    
	func finishedGame(with state: GameState, newHints: Bool = false) {
        guard var myData = myGameData else { return }
        let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
        myData.state = state
		myData.endTime = Date.ms
		myData.hints = myData.hints || newHints
        op = nil
        myGameData = nil
        opGameData = nil
        opGameRef.removeAllObservers()
		setGameValue(to: myData.toDict(), gameID: myData.gameID)
		
		// updating game summary here, so it updates each time a game ends
		let i = GameSummary.getPastGameCategory(for: myData.mode)
		GameSummary.pastGames[i][myData.gameID] = GameSummary(gameID: myData.gameID, mode: myData.mode, myTurn: myData.myTurn, opID: myData.opID, state: state, timeLimit: myData.totalTime ?? -1)
		
		loadPastGames()
    }
	
	func uploadBots() {
		for (i, bot) in Bot.bots.enumerated() {
			ref.child("bots/\(i)").setValue(bot.toDict())
		}
	}
    
    enum MatchingState {
        case invited, offered, matched, stopped
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
