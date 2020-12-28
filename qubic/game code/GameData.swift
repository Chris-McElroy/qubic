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
    case novice, defender, warrior, tyrant, oracle, cubist
    case daily, simple, common, tricky
    case play
}

class GameData: ObservableObject {
    // provided
    let myTurn: Int
    let player: [Player]
    let preset: [Int]
    let mode: GameMode
    let dayInt: Int?
    
    // created
    @Published var turn: Int
    private let board = Board()
    var winner: Int? = nil
    var leaving: Bool = false
    
    init() {
        myTurn = 0
        turn = 0
        mode = .play
        player = [Player(b: board, n: myTurn), Player(b: board, n: myTurn)]
        preset = []
        dayInt = nil
    }
    
    init(mode: GameMode, boardNum: Int = 0, turn: Int? = nil) {
        preset = GameData.getPreset(boardNum, for: mode)
        dayInt = Date().getInt()
        myTurn = turn != nil ? turn! : preset.count % 2
        self.turn = 0
        self.mode = mode
        let me = User(b: board, n: myTurn)
        let op = GameData.getOp(for: mode, b: board, n: myTurn^1, num: boardNum)
        if me.color == op.color { op.color = GameData.getDefaultColor(for: me.color) }
        player = myTurn == 0 ? [me, op] : [op, me]
    }
    
    static private func getOp(for mode: GameMode, b: Board, n: Int, num: Int) -> Player {
        switch mode {
        case .novice:   return Novice(b: b, n: n)
        case .defender: return Defender(b: b, n: n)
        case .warrior:  return Warrior(b: b, n: n)
        case .tyrant:   return Tyrant(b: b, n: n)
        case .oracle:   return Oracle(b: b, n: n)
        case .cubist:   return Cubist(b: b, n: n)
        case .daily:    return Daily(b: b, n: n)
        case .tricky:   return Tricky(b: b, n: n, num: num)
        default:        return User(b: b, n: n)
        }
    }

    func nextTurn() -> Int { board.nextTurn() }
    
    func processMove(_ p: Int) -> [WinLine]? {
        let wins = board.processMove(p)
        turn = wins?.count == 0 ? board.getTurn() : turn
        return wins
    }
    
    private static func getPreset(_ board: Int, for mode: GameMode) -> [Int] {
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
    
    private static func getDefaultColor(for n: Int) -> Int {
        return n == 0 ? 2 : 0
    }
}
