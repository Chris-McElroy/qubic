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

class Game: ObservableObject {
    @Published var turn: Int = 0
    @Published var hintCard: Bool = false
    @Published var showDCAlert: Bool = false
    @Published var newStreak: Int? = nil
    @Published var undoOpacity: Double = 0
    @Published var redoOpacity: Double = 0
    
    var goBack: () -> Void = {}
    var cancelBack: () -> Bool = { true }
    var myTurn: Int = 0
    var player: [Player] = [Player(b: Board(), n: 0), Player(b: Board(), n: 0)]
    var preset: [Int] = []
    var mode: GameMode = .play
    var dayInt: Int? = nil
    var winner: Int? = nil
    var hints: Bool = false
    var leaving: Bool = false
    private var board = Board()
    var boardScene: BoardScene? = nil
    
    init() {
        boardScene = BoardScene(game: self)
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
    
    func load(mode: GameMode, boardNum: Int = 0, turn: Int? = nil, hints: Bool = false) {
        board = Board()
        boardScene?.reset()
        undoOpacity = 0
        redoOpacity = 0
        hintCard = false
        preset = Game.getPreset(boardNum, for: mode)
        dayInt = Date().getInt()
        myTurn = turn != nil ? turn! : preset.count % 2
        self.turn = 0
        self.mode = mode
        self.hints = hints
        let me = User(b: board, n: myTurn)
        let op = Game.getOp(for: mode, b: board, n: myTurn^1, num: boardNum)
        if me.color == op.color { op.color = Game.getDefaultColor(for: me.color) }
        player = myTurn == 0 ? [me, op] : [op, me]
        for p in preset { loadMove(p) }
        player[self.turn].move(with: processMove)
        withAnimation { undoOpacity = hints ? 0.3 : 0.0 }
    }
    
    func loadMove(_ move: Int) {
        // Assumes no wins!
        guard board.processMove(move) != nil else { print("Invalid load move!"); return }
        boardScene?.addCube(move: move, color: .primary(player[turn].color))
    }
    
    func processMove(_ move: Int, for n: Int) {
        guard n == turn else { print("Invalid turn!"); return }
        guard let wins = board.processMove(move) else { print("Invalid move!"); return }
        boardScene?.showMove(move)
        turn = board.getTurn()
        if hints { withAnimation { undoOpacity = 1 } }
        if wins.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                self.player[self.turn].move(with: self.processMove)
            })
        } else {
            withAnimation { undoOpacity = 0 }
            winner = turn^1
            if winner == myTurn { updateWins() }
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                self.boardScene?.showWin(wins)
            })
        }
    }
    
    func undoMove() {
        print("starting undo", turn)
        winner = nil
        board.undoMove(for: turn^1)
        boardScene?.undoMove()
        turn = board.getTurn()
        print("got turn", turn)
        let oldCount = board.move[0].count + board.move[1].count
        if hints { withAnimation { undoOpacity = oldCount == 0 ? 0.3 : 1 } }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.player[self.turn].move(with: self.processMove)
        })
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
    
    func updateWins() {
        if mode == .daily && dayInt != UserDefaults.standard.integer(forKey: lastDCKey) {
            Notifications.ifUndetermined {
                DispatchQueue.main.async {
                    self.showDCAlert = true
                }
            }
            Notifications.setBadge(justSolved: true, dayInt: dayInt ?? Date().getInt())
            withAnimation { newStreak = UserDefaults.standard.integer(forKey: streakKey) }
            Timer.scheduledTimer(withTimeInterval: 2.4, repeats: false, block: { _ in
                withAnimation { self.newStreak = nil }
            })
        } else if mode == .tricky {
            UserDefaults.standard.setValue([1], forKey: trickyKey)
        } else if let index = [.novice, .defender, .warrior, .tyrant, .oracle, .cubist].firstIndex(of: mode) {
            var beaten = UserDefaults.standard.array(forKey: trainKey) as? [Int] ??  [0,0,0,0,0,0]
            beaten[index] = 1
            UserDefaults.standard.setValue(beaten, forKey: trainKey)
        }
    }
}
