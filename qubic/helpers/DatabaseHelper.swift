//
//  DatabaseHelper.swift
//  qubic
//
//  Created by Chris McElroy on 3/28/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DatabaseHelper {
    var ref = Database.database().reference()
    
    var playerObserver: UInt?
    var gameObserver: UInt?
    var gameRef: DatabaseReference?
    var playerList: [UUID: PlayerData] = [:]
    var currentGame: GameData? = nil
    
    func observePlayers() {
        let playersRef = ref.child("players")
        playerObserver = playersRef.observe(DataEventType.value, with: { (snapshot) in
            self.playerList = snapshot.value as? [UUID : PlayerData] ?? [:]
        })
    }
    
    func observeGame(op: UUID, created: Int) {
        let gameRef = ref.child("games/\(myUUID)/\(created)")
        gameObserver = gameRef.observe(DataEventType.value, with: { (snapshot) in
            self.currentGame = snapshot.value as? GameData
        })
    }
    
    func stopObservingGame() {
        if let handle = gameObserver {
            ref.removeObserver(withHandle: handle)
            gameObserver = nil
        }
    }
    
    func postOnlineInvite(time: Int) {
        let data = onlineInviteData(created: Date.ms, myTurn: .random(in: 0...1), time: time)
        
        let dict: [String: Any] = [
            "created": data.created,
            "myTurn": data.myTurn,
            "time": data.time,
            "accepted": [myUUID.uuidString: 0]
        ]
        
        self.ref.child("onlineInvites/\(myUUID)").setValue(dict)
        
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

    struct GameData {
        let myTurn: Int
        let op: UUID
        let hints: Int
        let time: Int
        let state: Int
        let lastMove: Int
        let myTime: [Int]
        let opTime: [Int]
        let moves: String
    }
    
    struct PlayerData {
        let name: String
        let color: Int
    }
    
    struct onlineInviteData {
        let created: Int
        let myTurn: Int
        let time: Int
    }
}


