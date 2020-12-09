//
//  GameHelper.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

enum OpponentType {
    case master
}

struct WinLine {
    let start: Int
    let end: Int
    let line: Int
}

enum GameType {
    case dc
    case train
    case solve
    case play
}

class GameData: ObservableObject {
    // provided
    let myTurn: Int
    let op: OpponentType
    let playerColor: [UIColor]
    let preset: [Int]
    let type: GameType
    
    // created
    @Published var turn: Int
    private let board = Board()
    var winner: Int? = nil
    var leaving: Bool = false
    
    init() {
        myTurn = 0
        turn = 0
        type = .play
        op = .master
        playerColor = []
        preset = []
    }
    
    init(preset givenPreset: [Int], dc: Bool) {
        preset = givenPreset
        myTurn = preset.count % 2
        turn = 0
        type = dc ? .dc : .solve
        op = .master
        let myColor = getUIColor(0)
        let opColor = getUIColor(1)
        let colorList = [myColor, opColor]
        playerColor = myTurn == 0 ? colorList : colorList.reversed()
    }
    
    func getMove() -> Int {
        switch op {
        case .master: return board.getMasterMove()
        }
    }

    func nextTurn() -> Int { board.nextTurn() }
    func pauseTime() -> Double { board.pauseTime() }
    func processMove(_ p: Int) -> [WinLine]? {
        let wins = board.processMove(p)
        turn = board.getTurn()
        return wins
    }
}
