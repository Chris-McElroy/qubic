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
    var gotOnlineMove: ((Int, Int) -> Void)? = nil
    var cancelOnlineSearch: (() -> Void)? = nil
    
    func start() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                UserDefaults.standard.setValue(user.uid, forKey: Key.uuid)
                self.observePlayers()
                self.updateMyData()
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
    
    func observePlayers() {
        ref.child("players").removeAllObservers()
        ref.child("players").observe(DataEventType.value, with: { snapshot in
            if let dict = snapshot.value as? [String: [String: Any]] {
                for entry in dict {
                    self.playerDict[entry.key] = PlayerData(from: entry.value)
                }
            }
        })
    }
    
    func updateMyData() {
        let myPlayerRef = ref.child("players/\(myID)")
        let name = UserDefaults.standard.string(forKey: Key.name) ?? ""
        let color = 0
        myPlayerRef.setValue([Key.name: name, Key.color: color])
    }
    
    func postFeedback(name: String, email: String, feedback: String) {
        let feedbackRef = ref.child("feedback/\(myID)/\(Date.ms)")
        feedbackRef.setValue([Key.name: name, Key.email: email, Key.feedback: feedback])
    }
    
    func uploadSolveBoard(_ string: String, key: String) {
        let solveRef = ref.child("solveBoards/\(myID)/\(key)/\(Date.ms)")
        solveRef.setValue(string)
    }
    
    func getOnlineMatch(timeLimit: Int, humansOnly: Bool, onMatch: @escaping () -> Void, onCancel: @escaping () -> Void) {
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
                    myGameRef.child(Key.state).setValue(GameData.GameState.error.rawValue)
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
                        if opData.state == .error || opData.state == .myLeave {
                            self.finishedOnlineGame(with: opData.state.mirror())
                        } else if opData.myMoves.count == nextCount && opData.myTimes.count == nextCount {
                            guard let newMove = opData.myMoves.last else { return }
                            guard let newTime = opData.myTimes.last else { return }
                            
                            myData.opMoves.append(newMove)
                            myData.opTimes.append(newTime)
                            self.myGameData = myData
                            myGameRef.setValue(myData.toDict())
                            
                            self.gotOnlineMove?(newMove, newTime)
                        }
                    }
                }
            })
        }
    }
    
    func sendOnlineMove(p: Int, time: Int) {
        guard var myData = myGameData else { return }
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
        myData.myMoves.append(p)
        myData.myTimes.append(time)
        self.myGameData = myData
        myGameRef.setValue(myData.toDict())
    }
    
    func finishedOnlineGame(with state: GameData.GameState) {
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
        var myTimes: [Int]       // times remaining on my clock after each of my moves
        var opTimes: [Int]       // times remaining on op clock after each of their moves
        var myMoves: [Int]      // my moves
        var opMoves: [Int]      // op moves
        let valid: Bool         // whether the given dict was valid
        
        init(from dict: [String: Any], gameID: Int) {
            valid = (
                dict[Key.myTurn] as? Int != nil &&
                    dict[Key.opID] as? String != nil &&
                    dict[Key.opGameID] as? Int != nil &&
                    dict[Key.hints] as? Int != nil &&
                    dict[Key.state] as? Int != nil &&
                    dict[Key.myTimes] as? [Int] != nil &&
                    dict[Key.opTimes] as? [Int] != nil &&
                    dict[Key.myMoves] as? [Int] != nil &&
                    dict[Key.opMoves] as? [Int] != nil
            )
            
            self.gameID = gameID
            myTurn = dict[Key.myTurn] as? Int ?? 0
            opID = dict[Key.opID] as? String ?? ""
            opGameID = dict[Key.opGameID] as? Int ?? 0
            hints = 1 == dict[Key.hints] as? Int ?? 0
            state = GameState(rawValue: dict[Key.state] as? Int ?? 0) ?? .error
            myTimes = dict[Key.myTimes] as? [Int] ?? []
            opTimes = dict[Key.opTimes] as? [Int] ?? []
            myMoves = dict[Key.myMoves] as? [Int] ?? []
            opMoves = dict[Key.opMoves] as? [Int] ?? []
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
                Key.myTurn: myTurn,
                Key.opID: opID,
                Key.opGameID: opGameID,
                Key.hints: hints ? 1 : 0,
                Key.state: state.rawValue,
                Key.myTimes: myTimes,
                Key.opTimes: opTimes,
                Key.myMoves: myMoves,
                Key.opMoves: opMoves
            ]
        }
        
        enum GameState: Int {
            // each one is 1 more
            case error = 0, new, active, myWin, opWin, myTimeout, opTimeout, myLeave, opLeave, draw
            
            func mirror() -> GameState {
                switch self {
                case .myWin: return .opWin
                case .opWin: return .myWin
                case .myTimeout: return .opTimeout
                case .opTimeout: return .myTimeout
                case .myLeave: return .opLeave
                case .opLeave: return .myLeave
                case .draw: return .draw
                default: return .error
                }
            }
        }
    }
    
    struct PlayerData {
        let name: String
        let color: Int
        
        init(from dict: [String: Any]) {
            name = dict[Key.name] as? String ?? "no name"
            color = dict[Key.color] as? Int ?? 0
        }
    }
    
    struct OnlineInviteData: Comparable {
        let ID: String
        let gameID: Int
        let timeLimit: Int
        var opID: String
        let valid: Bool
        
        init(from entry: Dictionary<String, [String: Any]>.Element) {
            self.init(from: entry.value, ID: entry.key)
        }
        
        init(from dict: [String: Any], ID: String) {
            valid = (
                dict[Key.gameID] as? Int != nil &&
                    dict[Key.timeLimit] as? Int != nil &&
                    dict[Key.opID] as? String != nil
            )
            
            self.ID = ID
            gameID = dict[Key.gameID] as? Int ?? 0
            timeLimit = dict[Key.timeLimit] as? Int ?? 0
            opID = dict[Key.opID] as? String ?? ""
        }
        
        init(timeLimit: Int) {
            ID = myID
            gameID = Date.ms
            self.timeLimit = timeLimit
            opID = ""
            valid = true
        }
        
        func toDict() -> [String: Any] {
            [
                Key.gameID: gameID,
                Key.timeLimit: timeLimit,
                Key.opID: opID
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

