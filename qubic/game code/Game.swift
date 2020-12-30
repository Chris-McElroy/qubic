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

enum HintValue {
    case w1, w2, w2d1
    case c1, cm1, cm2, c2d1, c2
}

class Game: ObservableObject {
    @Published var turn: Int = 0
    @Published var hintCard: Bool = false
    @Published var hintText: [[String]]? = nil
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
        winner = nil
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
        turn = board.getTurn()
    }
    
    func processMove(_ move: Int, for n: Int) {
        guard n == turn else { print("Invalid turn!"); return }
        guard let wins = board.processMove(move) else { print("Invalid move!"); return }
        boardScene?.showMove(move)
        turn = board.getTurn()
        hintText = nil
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
    
    func getHints(for n: Int) -> HintValue? {
        if n == turn {
            if board.hasW1(n) { return .w1 }
            else if board.hasW2(n, depth: 1) == true { return .w2d1 }
            else if board.hasW2(n) == true { return .w2 }
        } else {
            if board.hasW1(n) { return .c1 }
            else if board.hasW2(n) == true {
                if board.getW2Blocks(for: n^1) == nil { return .cm2 }
                else if board.hasW2(n, depth: 1) == true { return .c2d1 }
                else { return .c2 }
            }
        }
        return nil
    }
    
    func updateHintText() {
        guard hints && hintCard && hintText == nil else { return }
        var text = [[""],[""]]
        switch getHints(for: myTurn) {
        case .w1:   text[1] = ["3 in a row","You have 3 in a row, so now you can fill in the last move in that line and win!"]
        case .w2d1: text[1] = ["checkmate", "You can get two checks with your next move, and your opponent can’t block both!"]
        case .w2:   text[1] = ["second order win", "You can get to a checkmate using a series of checks!"]
        case .c1:   text[1] = ["check", "You have 3 in a row, so you can win next turn unless it’s blocked!"]
        case .cm1:  text[1] = ["checkmate", "You have more than one check, and your opponent can’t block them all!"]
        case .cm2:  text[1] = ["second order checkmate", "You have more than one second order check, and your opponent can’t block them all!"]
        case .c2d1: text[1] = ["second order check", "You can get checkmate next move if your opponent doesn’t stop you!"]
        case .c2:   text[1] = ["second order check", "You can get checkmate through a series of checks if your opponent doesn’t stop you!"]
        case nil:   text[1] = ["no wins", "You don't have any forced wins right now, keep working to set one up!"]
        }
        
        switch getHints(for: myTurn^1) {
        case .w1:   text[0] = ["3 in a row","Your opponent has 3 in a row, so now they can fill in the last move in that line and win!"]
        case .w2d1: text[0] = ["checkmate", "Your opponent can get two checks with their next move, and you can’t block both!"]
        case .w2:   text[0] = ["second order win", "Your opponent can get to a checkmate using a series of checks!"]
        case .c1:   text[0] = ["check", "Your opponent has 3 in a row, so you should block their line to prevent them from winning!"]
        case .cm1:  text[0] = ["checkmate", "Your opponent has more than one check, and you can’t block them all!"]
        case .cm2:  text[0] = ["second order checkmate", "Your opponent has more than one second order check, and you can’t block them all!"]
        case .c2d1: text[0] = ["second order check", "Your opponent can get checkmate next move if you don’t stop them!"]
        case .c2:   text[0] = ["second order check", "Your opponent can get checkmate through a series of checks if you don’t stop them!"]
        case nil:   text[0] = ["no wins", "Your opponent doesn't have any forced wins right now, keep it up!"]
        }
        
        hintText = text
    }
    
    func showMoves(for n: Int?) {
        var list: Set<Int> = []
        if let t = n {
            if t == turn {
                if board.hasW1(t) { list = board.getW1(for: t) }
                else if board.hasW2(t, depth: 1) == true { list = board.getW2(for: t, depth: 1) ?? [] }
                else if board.hasW2(t) == true { list = board.getW2(for: t) ?? [] }
            } else {
                if board.hasW1(t) { list = board.getW1(for: t) }
                else if board.hasW2(t) == true {
                    if board.getW2Blocks(for: t^1) == nil { list = [] }
                    else if board.hasW2(t, depth: 1) == true { list = board.getW2Blocks(for: t^1, depth: 1) ?? [] }
                    else { list = board.getW2Blocks(for: t^1) ?? [] }
                }
            }
        }
        boardScene?.spinDots(list)
    }
}
