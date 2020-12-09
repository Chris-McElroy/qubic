//
//  GameHelper.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct WinLine {
    let start: Int
    let end: Int
    let line: Int
}

enum GameMode {
    case beginner
    case defender
    case daily
    case simple
    case common
    case tricky
    case play
}

class GameData: ObservableObject {
    // provided
    let myTurn: Int
    let playerColor: [UIColor]
    let preset: [Int]
    let mode: GameMode
    
    // created
    @Published var turn: Int
    private let board = Board()
    var winner: Int? = nil
    var leaving: Bool = false
    
    init() {
        myTurn = 0
        turn = 0
        mode = .play
        playerColor = []
        preset = []
    }
    
    init(mode: GameMode, boardNum: Int = 0, turn: Int?) {
        preset = GameData.getBoard(boardNum, for: mode)
        myTurn = turn != nil ? turn! : preset.count % 2
        self.turn = 0
        self.mode = mode
        let myColor = getUIColor(0)
        let opColor = getUIColor(1)
        let colorList = [myColor, opColor]
        playerColor = myTurn == 0 ? colorList : colorList.reversed()
    }
    
    func getMove() -> Int {
        switch mode {
        case .beginner: return board.getBeginnerMove()
        default: return board.getMasterMove()
        }
    }
    
    func getPause() -> Double {
        switch mode {
        case .beginner: return board.getBeginnerPause()
        default: return board.getMasterPause()
        }
    }

    func nextTurn() -> Int { board.nextTurn() }
    func processMove(_ p: Int) -> [WinLine]? {
        let wins = board.processMove(p)
        turn = board.getTurn()
        return wins
    }
    
    private static func getBoard(_ board: Int, for mode: GameMode) -> [Int] {
        if mode == .daily {
            let day = Calendar.current.component(.day, from: Date())
            let month = Calendar.current.component(.month, from: Date())
            let year = Calendar.current.component(.year, from: Date())
            let total = allSolveBoards.count
            let offset = (year+month+day) % (total/31 + (total%31 > day ? 1 : 0))
            return expandMoves(allSolveBoards[31*offset + day])
        } else if mode == .tricky {
            return expandMoves(allSolveBoards[21])
        } else {
            return []
        }
    }
}
