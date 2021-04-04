//
//  FB.swift
//  qubic
//
//  Created by Chris McElroy on 3/28/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI
import Firebase

class FB {
    static let main = FB()
    
    var ref = Database.database().reference()
    var playerDict: [String: PlayerData] = [:]
    var myGameData: GameData? = nil
    var opGameData: GameData? = nil
    var op: PlayerData? = nil
    var onlineInviteState: MatchingState = .stopped
    var gotOnlineMove: ((Int, Int) -> Void)? = nil
    
    func start() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                UserDefaults.standard.setValue(user.uid, forKey: Key.uuid)
                self.observePlayers()
                self.updateMyData()
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
    
    func getOnlineMatch(timeLimit: Int, openGameView: @escaping () -> Void) {
        onlineInviteState = .invited
        var possOp: Set<String> = []
        var myInvite = OnlineInviteData(timeLimit: timeLimit)
        
        let onlineRef = ref.child("onlineInvites")
        onlineRef.removeAllObservers()
        
        // send invite
        onlineRef.child(myID).setValue(myInvite.toDict())
        
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
                            startGame(opInvite: opInvite)
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
                        startGame(opInvite: opInvite)
                        break
                    }
                }
                let offeredOp = OnlineInviteData(from: dict[myInvite.opID] ?? [:], ID: myInvite.opID)
                if !offeredOp.valid || offeredOp.timeLimit != timeLimit || offeredOp.opID != "" {
                    self.onlineInviteState = .invited
                    myInvite.opID = ""
                    onlineRef.child(myID).setValue(myInvite.toDict())
                }
                break
            case .matched:
                if self.opGameData?.state == .active {
                    // finished inviting
                    self.onlineInviteState = .stopped
                    onlineRef.child(myID).removeValue()
                    onlineRef.removeAllObservers()
                } else if self.myGameData?.state == .new {
                    // TODO check that they haven't gone with someone else
                }
                break
            case .stopped:
                onlineRef.child(myID).removeValue()
                onlineRef.removeAllObservers()
                break
            }
            
        })
        
        func startGame(opInvite: OnlineInviteData) {
            var myData = GameData(myInvite: myInvite, opInvite: opInvite)
            myGameData = myData
            
            // post game
            let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
            myGameRef.setValue(myData.toDict())
            
            // search for their post
            let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
            opGameRef.removeAllObservers()
            opGameRef.observe(DataEventType.value, with: { snapshot in
                guard let dict = snapshot.value as? [String: Any] else { return }
                let opData = GameData(from: dict, gameID: myData.opGameID)
                guard let op = self.playerDict[myData.opID] else { return }
                if opData.valid && opData.opID == myID && opData.opGameID == myData.gameID {
                    // TODO handle what happens if you receive the game and they've already moved once
                    print("success")
                    self.opGameData = opData
                    self.op = op
                    myData.state = .active
                    self.myGameData = myData
                    myGameRef.setValue(myData.toDict())
                    self.playGame()
                    openGameView() // TODO i might need to change this or do something else
                } else {
                    print("failed", opData.valid, opData.opID == myID, opData.opGameID == myData.gameID)
                    print(opData)
                    print(myData)
                }
            })
        }
    }
    
    // TODO decide where to put this function and make a better name
    func playGame() {
        guard var myData = myGameData else { return }
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
        
        // capture op game updates
        let opGameRef = ref.child("games/\(myData.opID)/\(myData.opGameID)")
        opGameRef.removeAllObservers()
        opGameRef.observe(DataEventType.value, with: { snapshot in
            guard let oldOpData = self.opGameData else { return }
            guard let dict = snapshot.value as? [String: Any] else { return }
            let opData = GameData(from: dict, gameID: myData.opGameID)
            if opData.valid && opData.opID == myID && opData.opGameID == myData.gameID {
                if opData.myTimes != oldOpData.myTimes && opData.myMoves != oldOpData.myMoves {
                    self.opGameData = opData
                        
                    myData.opTimes = opData.myTimes
                    myData.opMoves = opData.myMoves
                    self.myGameData = myData
                    myGameRef.setValue(myData.toDict())
                    
                    self.gotOnlineMove?(myData.opMoves.last ?? -1, myData.opTimes.last ?? -1)
                }
            }
        })
    }
    
    func sendOnlineMove(p: Int, time: Int) {
        print("sending move")
        guard var myData = myGameData else { return }
        myData.myMoves.append(p)
        myData.myTimes.append(time)
        self.myGameData = myData
        let myGameRef = ref.child("games/\(myID)/\(myData.gameID)")
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
            
            print("validity", dict[Key.myTurn] as? Int != nil ,
                      dict[Key.opID] as? String != nil ,
                      dict[Key.opGameID] as? Int != nil ,
                      dict[Key.hints] as? Int != nil ,
                      dict[Key.state] as? Int != nil ,
                      dict[Key.myTimes] as? [Int] != nil ,
                      dict[Key.opTimes] as? [Int] != nil ,
                      dict[Key.myMoves] as? [Int] != nil ,
                      dict[Key.opMoves] as? [Int] != nil)
            
            
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
            case error = 0, new, active, myWin, opWin, myTimeout, opTimeout, draw
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


