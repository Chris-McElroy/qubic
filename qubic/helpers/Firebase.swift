//
//  Firebase.swift
//  qubic
//
//  Created by Chris McElroy on 3/28/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation

struct Firebase {
    
    struct Game: Codable {
        let created: Int
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
    
    struct Player: Codable {
        let name: String
        let color: Int
        let time: Int
    }
    
    struct onlineInvite: Codable {
        let created: Int
        let myTurn: Int
        let time: Int
        let accepted: [[UUID: Int]]
    }
}


