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
        signIn()
        observePlayers()
        updateMyData()
    }
    
    func signIn() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                UserDefaults.standard.setValue(user.uid, forKey: Key.uuid)
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
                    self.playerDict[entry.key] = PlayerData(from: entry.value, uuid: entry.key)
                }
            }
        })
    }
    
    func updateMyData() {
        let myPlayerRef = ref.child("players/\(myUUID)")
        let name = UserDefaults.standard.string(forKey: Key.name) ?? ""
        let color = 0
        myPlayerRef.setValue([Key.name: name, Key.color: color])
    }
    
    func observeGame(op: UUID, created: Int) {
        let gameRef = ref.child("games/\(myUUID)/\(created)")
        gameObserver = gameRef.observe(DataEventType.value, with: { (snapshot) in
            self.myGameData = snapshot.value as? GameData
        })
    }
    
    func stopObservingGame() {
        if let handle = gameObserver {
            ref.removeObserver(withHandle: handle)
            gameObserver = nil
        }
    }
    
    func postOnlineInvite(time: Int) {
        let myInvite: [String: Any] = [
            Key.created: Date.ms,
            Key.myTurn: Int.random(in: 0...1),
            Key.time: time
        ]
        
        self.ref.child("onlineInvites/\(myUUID)").setValue(myInvite)
        
        // TODO REMOVE
        op = PlayerData(from: ["name": "succ", "color": 5], uuid: "")
        
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
        let op: String      // op uuid
        let hints: Bool     // true for sandbox mode
        let time: Int       // time mode in ms
        let state: Int      // current state of the game
        let lastMove: Int   // time of last move in ms
        var myTime: [Int]   // times remaining on my clock after each of my moves
        var opTime: [Int]   // times remaining on op clock after each of their moves
        var moves: [Int]    // moves
        let created: Int    // time the invite was created in ms
        
        let valid: Bool     // whether the given dict was valid
        
        init(from dict: [String: Any], created: Int) {
            valid = (
                dict[Key.myTurn] as? Int != nil &&
                    dict[Key.op] as? String != nil &&
                    dict[Key.hints] as? Int != nil &&
                    dict[Key.time] as? Int != nil &&
                    dict[Key.state] as? Int != nil &&
                    dict[Key.lastMove] as? Int != nil &&
                    dict[Key.myTime] as? [Int] != nil &&
                    dict[Key.opTime] as? [Int] != nil &&
                    dict[Key.moves] as? String != nil
            )
            
            self.created = created
            myTurn = dict[Key.myTurn] as? Int ?? 0
            op = dict[Key.op] as? String ?? ""
            hints = 1 == dict[Key.hints] as? Int ?? 0
            time = dict[Key.time] as? Int ?? 0
            state = dict[Key.state] as? Int ?? 0
            lastMove = dict[Key.lastMove] as? Int ?? 0
            myTime = dict[Key.myTime] as? [Int] ?? []
            opTime = dict[Key.opTime] as? [Int] ?? []
            moves = dict[Key.moves] as? [Int] ?? []
        }
    }
    
    struct PlayerData {
        let uuid: String
        let name: String
        let color: Int
        
        init(from dict: [String: Any], uuid: String) {
            self.uuid = uuid
            name = dict[Key.name] as? String ?? "no name"
            color = dict[Key.color] as? Int ?? 0
        }
    }
    
    struct onlineInviteData {
        let uuid: String
        let created: Int
        let myTurn: Int
        let time: Int
        let valid: Bool
        
        init(from dict: [String: Any], uuid: String) {
            valid = (
                dict[Key.created] as? Int != nil &&
                    dict[Key.myTurn] as? Int != nil &&
                    dict[Key.time] as? Int != nil
            )
            
            self.uuid = uuid
            created = dict[Key.created] as? Int ?? 0
            myTurn = dict[Key.myTurn] as? Int ?? 0
            time = dict[Key.time] as? Int ?? 0
        }
    }
}


