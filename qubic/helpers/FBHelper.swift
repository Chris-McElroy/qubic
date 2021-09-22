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

class FB {
    static let main = FB()
    
    var ref = Database.database().reference()
    var playerDict: [String: PlayerData] = [:]
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
                self.observePlayers()
                self.updateMyData()
				self.updateMyStats()
				self.startActiveTimer()
                self.finishedOnlineGame(with: .error)
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
		let myActiveRef = ref.child("stats/\(myID)/active")
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
                    self.playerDict[entry.key] = PlayerData(from: entry.value)
                }
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
		myStatsRef.setValue([
			Key.buildNumber.rawValue: buildNumber,
			Key.versionType.rawValue: versionType.rawValue,
			Key.active.rawValue: Date.ms,
			Key.train.rawValue: train,
			Key.streak.rawValue: streak,
			Key.lastDC.rawValue: lastDC,
			Key.currentDaily.rawValue: currentDaily,
			Key.dailyHistory.rawValue: dailyHistory,
			Key.simple.rawValue: simple,
			Key.common.rawValue: common,
			Key.tricky.rawValue: tricky,
			Key.solvedBoards.rawValue: solves,
			Key.solveBoardsVersion.rawValue: solveBoardVersion
		])
	}
    
    func postFeedback(name: String, email: String, feedback: String) {
        let feedbackRef = ref.child("feedback/\(myID)/\(Date.ms)")
        feedbackRef.setValue([Key.name.rawValue: name, Key.email.rawValue: email, Key.feedback.rawValue: feedback])
    }
    
    func uploadSolveBoard(_ string: String, key: String) {
        let solveRef = ref.child("solveBoards/\(myID)/\(key)/\(Date.ms)")
        solveRef.setValue(string)
    }
    
    func getOnlineMatch(timeLimit: Double, humansOnly: Bool, onMatch: @escaping () -> Void, onCancel: @escaping () -> Void) {
        onlineInviteState = .invited
        myGameData = nil
        opGameData = nil
        
        var possOp: Set<String> = []
        var myInvite = OnlineInviteData(timeLimit: timeLimit)
        
        let onlineRef = ref.child("onlineInvites")
        onlineRef.removeAllObservers()
        
        // send invite
        onlineRef.child(myID).setValue(myInvite.toDict())
        
        // set end time
        var botTimer: Timer? = nil
        if !humansOnly {
            botTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { _ in
                if self.onlineInviteState == .invited || self.onlineInviteState == .offered {
                    self.finishedOnlineGame(with: .error)
                    self.onlineInviteState = .stopped
                    onlineRef.child(myID).removeValue()
                    onlineRef.removeAllObservers()
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
            onCancel()
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
                        onMatch()
                    }
                    if myData.state == .active {
                        self.opGameData = opData
                        let nextCount = myData.opMoves.count + 1
                        // don't include other end states because those are implicit with the moves
                        if opData.state == .error || opData.state == .myLeave || opData.state == .myTimeout {
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
    
    func sendOnlineMove(p: Int, time: Double) {
        guard var myData = myGameData else { return }
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
        myData.myMoves.append(p)
        myData.myTimes.append(time)
        self.myGameData = myData
        myGameRef.setValue(myData.toDict())
    }
    
    func finishedOnlineGame(with state: GameState) {
        guard var myData = myGameData else { return }
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
        let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
        myData.state = state
        op = nil
        myGameData = nil
        opGameData = nil
        opGameRef.removeAllObservers()
        myGameRef.setValue(myData.toDict())
    }

    struct GameData {
        let gameID: Int         // my gameID
        let myTurn: Int         // 0 for moves first
        let opID: String        // op id
        let opGameID: Int       // op gameID
        let hints: Bool         // true for sandbox mode
        var state: GameState    // current state of the game
        var myTimes: [Double]       // times remaining on my clock after each of my moves
        var opTimes: [Double]       // times remaining on op clock after each of their moves
        var myMoves: [Int]      // my moves
        var opMoves: [Int]      // op moves
        let valid: Bool         // whether the given dict was valid
        
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
            
            self.gameID = gameID
            myTurn = dict[Key.myTurn.rawValue] as? Int ?? 0
            opID = dict[Key.opID.rawValue] as? String ?? ""
            opGameID = dict[Key.opGameID.rawValue] as? Int ?? 0
            hints = 1 == dict[Key.hints.rawValue] as? Int ?? 0
            state = GameState(rawValue: dict[Key.state.rawValue] as? Int ?? 0) ?? .error
            myTimes = dict[Key.myTimes.rawValue] as? [Double] ?? []
            opTimes = dict[Key.opTimes.rawValue] as? [Double] ?? []
            myMoves = dict[Key.myMoves.rawValue] as? [Int] ?? []
            opMoves = dict[Key.opMoves.rawValue] as? [Int] ?? []
        }
        
        init(myInvite: OnlineInviteData, opInvite: OnlineInviteData) {
            gameID = myInvite.gameID
            myTurn = myInvite > opInvite ? myInvite.gameID % 2 : (opInvite.gameID % 2)^1
            opID = myInvite.opID
            opGameID = opInvite.gameID
            hints = false
            state = .new
            myTimes = [myInvite.timeLimit]
            opTimes = [myInvite.timeLimit]
            myMoves = [-1]
            opMoves = [-1]
            valid = true
        }
        
        func toDict() -> [String: Any] {
            [
                Key.myTurn.rawValue: myTurn,
                Key.opID.rawValue: opID,
                Key.opGameID.rawValue: opGameID,
                Key.hints.rawValue: hints ? 1 : 0,
                Key.state.rawValue: state.rawValue,
                Key.myTimes.rawValue: myTimes,
                Key.opTimes.rawValue: opTimes,
                Key.myMoves.rawValue: myMoves,
                Key.opMoves.rawValue: opMoves
            ]
        }
    }
    
    struct PlayerData {
        let name: String
        let color: Int
        
        init(from dict: [String: Any]) {
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


