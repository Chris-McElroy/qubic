//
//  FB.swift
//  qubic
//
//  Created by Chris McElroy on 3/28/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation
import Firebase

class FB {
    static let main = FB()
    
    var ref = Database.database().reference()
    
    var playerObserver: UInt?
    var gameObserver: UInt?
    var gameRef: DatabaseReference?
    var playerDict: [String: PlayerData] = [:]
    var myGameData: GameData? = nil
    var opGameData: GameData? = nil
    var op: PlayerData? = nil
    
    func start() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                UserDefaults.standard.setValue(user.uid, forKey: Key.uuid)
                self.observePlayers()
                self.updateMyData()
            } else {
                Auth.auth().signInAnonymously() { (authResult, error) in
                    if let error = error {
                        print("Sign in error:", error)
                    }
                }
            }
        }
    }
    
    func observePlayers() {
        let playersRef = ref.child("players")
        playerObserver = playersRef.observe(DataEventType.value, with: { (snapshot) in
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
    
    func observeGame(op: UUID, created: Int) {
        let gameRef = ref.child("games/\(myID)/\(created)")
        gameObserver = gameRef.observe(DataEventType.value, with: { (snapshot) in
            self.myGameData = snapshot.value as? GameData
            
            // TODO it should look like this
            if let dict = snapshot.value as? [String: [String: Any]] {
                for entry in dict {
                    self.playerDict[entry.key] = PlayerData(from: entry.value)
                }
            }
            
            
        })
    }
    
    func detatch(observer: inout UInt?, from ref: DatabaseReference) {
        if let handle = observer {
            print("detaching")
            ref.removeObserver(withHandle: handle)
            observer = nil
        }
    }
    
    func getOnlineMatch(timeLimit: Int) {
        enum MatchingState {
            case invited, offered, matched
        }
        
        var possOp: Set<String> = []
        var state: MatchingState = .invited
        var myData = OnlineInviteData(timeLimit: timeLimit)
        
        let onlineRef = ref.child("onlineInvites")
        onlineRef.removeAllObservers()
        
        // send invite
        onlineRef.child(myID).setValue(myData.toDict())
        
        // check for others
        onlineRef.observe(DataEventType.value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: [String: Any]] else { return }
            switch state {
            case .invited:
                for entry in dict where entry.key != myID {
                    let opData = OnlineInviteData(from: entry.value)
                    if opData.valid && opData.timeLimit == timeLimit {
                        if opData.opID != myID { possOp.insert(entry.key) }
                        if newer(opData: opData, opID: entry.key) {
                            state = .offered
                            myData.opID = entry.key
                            onlineRef.child(myID).setValue(myData.toDict())
                            break
                        } else if opData.opID == myID && possOp.contains(entry.key) {
                            state = .matched
                            myData.opID = entry.key
                            onlineRef.child(myID).setValue(myData.toDict())
                            onlineRef.child(myID + "/timeLimit").setValue(42)
                            break
                        }
                    }
                }
                break
            case .offered:
                for entry in dict where entry.key != myID {
                    let opData = OnlineInviteData(from: entry.value)
                    if opData.valid && opData.timeLimit == timeLimit &&
                        opData.opID == myID && (myData.opID == entry.key || myData.opID == "") &&
                        possOp.contains(entry.key) {
                        // TODO do i need to check for newer hear? think out 4 person example
                            state = .matched
                            myData.opID = entry.key
                            onlineRef.child(myID).setValue(myData.toDict())
                            onlineRef.child(myID + "/timeLimit").setValue(42)
                            break
                    }
                }
                let offeredOp = OnlineInviteData(from: dict[myData.opID] ?? [:])
                if !offeredOp.valid || offeredOp.timeLimit != timeLimit || offeredOp.opID != "" {
                    state = .invited
                    myData.opID = ""
                    onlineRef.child(myID).setValue(myData.toDict())
                }
                break
            case .matched:
                break
            }
            
        })
        
        func startGame(with opID: String, data: OnlineInviteData) {
            // call this when matched
        }
        
        func newer(opData: OnlineInviteData, opID: String) -> Bool {
            if opData.myGameID == myData.myGameID {
                return opID > myID
            } else {
                return opData.myGameID > myData.myGameID
            }
        }
        
        // TODO keep adding code here to do out the whole invite process
        
        // search for others online
            // accept them if the time is right
        // search for accepted people in accepted
            // confirm them if they're the first
        
        // set up a new match once you're done
        // return an online bot???
        // no maybe this is called inside of online?
        // no idea
    }
    
    func move(on b: Board, n: Int, with process: @escaping (Int, UInt64) -> Void) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
            for i in 0..<64 {
                if b.pointEmpty(i) {
                    process(i, b.board[n])
                    break
                }
            }
        })
    }

    struct GameData {
        let myTurn: Int     // 0 for moves first
        let opID: String    // op id
        let opGameID: Int   // op gameID
        let hints: Bool     // true for sandbox mode
        let timeLimit: Int  // time mode in ms
        let state: Int      // current state of the game
        let lastMove: Int   // time of last move in ms
        var myTime: [Int]   // times remaining on my clock after each of my moves
        var opTime: [Int]   // times remaining on op clock after each of their moves
        var moves: [Int]    // moves
        
        let valid: Bool     // whether the given dict was valid
        
        init(from dict: [String: Any]) {
            valid = (
                dict[Key.myTurn] as? Int != nil &&
                    dict[Key.opID] as? String != nil &&
                    dict[Key.opGameID] as? String != nil &&
                    dict[Key.hints] as? Int != nil &&
                    dict[Key.timeLimit] as? Int != nil &&
                    dict[Key.state] as? Int != nil &&
                    dict[Key.lastMove] as? Int != nil &&
                    dict[Key.myTime] as? [Int] != nil &&
                    dict[Key.opTime] as? [Int] != nil &&
                    dict[Key.moves] as? String != nil
            )
            
            myTurn = dict[Key.myTurn] as? Int ?? 0
            opID = dict[Key.opID] as? String ?? ""
            opGameID = dict[Key.opGameID] as? Int ?? 0
            hints = 1 == dict[Key.hints] as? Int ?? 0
            timeLimit = dict[Key.timeLimit] as? Int ?? 0
            state = dict[Key.state] as? Int ?? 0
            lastMove = dict[Key.lastMove] as? Int ?? 0
            myTime = dict[Key.myTime] as? [Int] ?? []
            opTime = dict[Key.opTime] as? [Int] ?? []
            moves = dict[Key.moves] as? [Int] ?? []
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
    
    struct OnlineInviteData {
        let myGameID: Int
        let timeLimit: Int
        var opID: String
        let valid: Bool
        
        init(from dict: [String: Any]) {
            valid = (
                dict[Key.myGameID] as? Int != nil &&
                    dict[Key.timeLimit] as? Int != nil &&
                    dict[Key.opID] as? String != nil
            )
            
            myGameID = dict[Key.myGameID] as? Int ?? 0
            timeLimit = dict[Key.timeLimit] as? Int ?? 0
            opID = dict[Key.opID] as? String ?? ""
        }
        
        init(timeLimit: Int) {
            myGameID = Date.ms
            self.timeLimit = timeLimit
            opID = ""
            valid = true
        }
        
        func toDict() -> [String: Any] {
            [
                Key.myGameID: myGameID,
                Key.timeLimit: timeLimit,
                Key.opID: opID
            ]
        }
    }
}


