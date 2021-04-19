//
//  Game.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

enum GameMode: Int {
    case novice, defender, warrior, tyrant, oracle, cubist
    case daily, simple, common, tricky
    case local, online, invite
    case off
    
    var train: Bool { [.novice, .defender, .warrior, .tyrant, .oracle, .cubist].contains(self) }
    var solve: Bool { [.daily, .simple, .common, .tricky].contains(self) }
    var play: Bool { [.local, .online, .invite].contains(self) }
    
    var trainValue: Int { self.rawValue - GameMode.novice.rawValue }
}

enum HintValue {
    case w0, w1, w2, w2d1
    case c1, cm1, cm2, c2d1, c2
    case noW
}

class Move: Equatable {
    let p: Int
    var myHint: HintValue?
    var opHint: HintValue?
    
    init(_ p: Int) {
        self.p = p
        myHint = nil
        opHint = nil
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        lhs.p == rhs.p
    }
}

class Game: ObservableObject {
    static let main = Game()
    
    @Published var hintCard: Bool = false
    @Published var currentMove: Move? = nil
    @Published var showDCAlert: Bool = false
    @Published var newStreak: Int? = nil
    @Published var undoOpacity: Opacity = .clear
    @Published var prevOpacity: Opacity = .clear
    @Published var nextOpacity: Opacity = .clear
    @Published var moves: [Move] = []
    
    var turn: Int { board.getTurn() }
    var goBack: () -> Void = {}
    var cancelBack: () -> Bool = { true }
    var myTurn: Int = 0
    var player: [Player] = [Player(b: Board(), n: 0), Player(b: Board(), n: 0)]
    var preset: [Int] = []
    var mode: GameMode = .local
    var dayInt: Int? = nil
    var winner: Int? = nil
    var replayMode: Bool = false
    var hints: Bool = false
    var leaving: Bool = false
    private var board = Board()
    let hintQueue = DispatchQueue(label: "hint queue", qos: .userInitiated)
    var movesBack: Int = 0
    var ghostMoveStart: Int = 0
    var ghostMoveCount: Int = 0
    var newHints: () -> Void = {}
    
    init() { }
    
//    func turnOff() {
//        guard mode != .off else { return }
//        undoOpacity = .clear
//        prevOpacity = .clear
//        nextOpacity = .clear
//        self.mode = .off
//    }
    
    func load(mode: GameMode, boardNum: Int = 0, turn: Int? = nil, hints: Bool = false) {
        board = Board()
        BoardScene.main.reset()
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
        winner = nil
        currentMove = nil
        moves = []
        movesBack = 0
        ghostMoveStart = 0
        ghostMoveCount = 0
        hintCard = false
        replayMode = false
        preset = Game.getPreset(boardNum, for: mode)
        dayInt = Date().getInt()
        myTurn = turn != nil ? turn! : preset.count % 2
        self.mode = mode
        self.hints = hints
        let me = User(b: board, n: myTurn)
        let op: Player
        switch mode {
        case .novice:   op = Novice(b: board, n: myTurn^1)
        case .defender: op = Defender(b: board, n: myTurn^1)
        case .warrior:  op = Warrior(b: board, n: myTurn^1)
        case .tyrant:   op = Tyrant(b: board, n: myTurn^1)
        case .oracle:   op = Oracle(b: board, n: myTurn^1)
        case .cubist:   op = Cubist(b: board, n: myTurn^1)
        case .daily:    op = Daily(b: board, n: myTurn^1)
        case .tricky:   op = Tricky(b: board, n: myTurn^1, num: boardNum)
        case .local:    op = User(b: board, n: myTurn^1, name: "friend")
        case .online:   op = Online(b: board, n: myTurn^1)
        default:        op = Daily(b: board, n: myTurn^1)
        }
        if me.color == op.color { op.color = Game.getDefaultColor(for: me.color) }
        player = myTurn == 0 ? [me, op] : [op, me]
        for p in preset { loadMove(p) }
        newHints()
        player[self.turn].move()
        withAnimation {
            undoOpacity = hints ? .half : .clear
            prevOpacity = .half
            nextOpacity = .half
        }
    }
    
    func loadMove(_ p: Int) {
        // Assumes no wins!
        let move = Move(p)
        guard !moves.contains(move) && (0..<64).contains(move.p) else { return }
        board.addMove(move.p)
        moves.append(move)
        currentMove = move
        getHints(for: moves)
        BoardScene.main.addCube(move: move.p, color: .primary(player[turn^1].color))
    }
    
    func processMove(_ p: Int, for turn: Int, num: Int) {
        let move = Move(p)
        guard winner == nil else { return }
        guard turn == moves.count % 2 && num == moves.count else { print("Invalid turn!"); return }
        guard !moves.contains(move) && (0..<64).contains(move.p) else { return }
        moves.append(move)
        if movesBack != 0 { movesBack += 1 }
        if player[turn].rounded {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        if player[turn^1] as? Online != nil {
            FB.main.sendOnlineMove(p: move.p, time: -1)
        }
        getHints(for: moves)
        guard !hintCard && movesBack == 0 else { return }
        board.addMove(move.p)
        if board.hasW0(turn) {
            winner = turn
            print("updating wins")
            updateWins()
            if !mode.solve || winner == myTurn { hints = true }
            withAnimation { undoOpacity = .clear }
        } else {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                self.player[turn^1].move()
            })
        }
        currentMove = move
        newHints()
        BoardScene.main.showMove(move.p, wins: board.getWinLines())
        if undoOpacity == .half { withAnimation { undoOpacity = .full } }
        withAnimation { prevOpacity = .full }
    }
    
    func processGhostMove(_ p: Int) {
        let move = Move(p)
        guard board.pointEmpty(move.p) && (0..<64).contains(move.p) else { return }
        guard replayMode else { return }
        board.addMove(move.p)
        if ghostMoveCount == 0 {
            ghostMoveStart = moves.count - movesBack
        }
        while ghostMoveStart + ghostMoveCount != moves.count - movesBack && movesBack > 0 {
            ghostMoveCount -= 1
            movesBack -= 1
            moves.remove(at: ghostMoveStart+ghostMoveCount)
        }
        moves.insert(move, at: ghostMoveStart+ghostMoveCount)
        currentMove = move
        newHints()
        ghostMoveCount += 1
        getHints(for: moves.dropLast(movesBack))
        BoardScene.main.showMove(move.p, wins: board.getWinLines(), ghost: true)
        withAnimation {
            prevOpacity = .full
            nextOpacity = .half
        }
    }
    
    func showHintCard() -> Bool {
        withAnimation {
            hintCard = true
            if undoOpacity == .full {
                undoOpacity = .half
            }
        }
        return false
    }
    
    func hideHintCard() -> Bool {
        if !hintCard { return false }
        withAnimation {
            hintCard = false
            let emptyBoard = (board.board[0] + board.board[1] == 0)
            if undoOpacity == .half && !emptyBoard && movesBack == 0 {
                undoOpacity = .full
            }
        }
        return true
    }
    
    func undoMove() {
        guard undoOpacity == .full else { return }
        guard movesBack == 0 else { return }
        guard winner == nil else { return }
        guard !hintCard else { return }
        guard let move = moves.popLast() else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        currentMove = moves.last
        newHints()
        board.undoMove(for: turn^1)
        BoardScene.main.undoMove(move.p, wins: board.getWinLines())
        if moves.count == preset.count {
            withAnimation {
                undoOpacity = .half
                prevOpacity = .half
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.player[self.turn].move()
        })
    }
    
    func prevMove() {
        guard prevOpacity == .full else { return }
        let i = moves.count - movesBack - 1
        guard i >= ((!hints && mode.solve) ? preset.count : 0) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        movesBack += 1
        if winner != nil { replayMode = true }
        board.undoMove(for: turn^1)
        BoardScene.main.undoMove(moves[i].p, wins: board.getWinLines())
        currentMove = i > 0 ? moves[i-1] : nil
        newHints()
        if i-1 < ghostMoveStart {
            moves.removeSubrange(ghostMoveStart..<(ghostMoveStart+ghostMoveCount))
            movesBack -= ghostMoveCount
            ghostMoveCount = 0
        }
        withAnimation {
            nextOpacity = movesBack > 0 ? .full : .half
            if undoOpacity == .full { undoOpacity = .half }
            let minMoves = winner == myTurn ? 0 : preset.count
            if moves.count - movesBack == minMoves { prevOpacity = .half }
        }
    }
    
    func nextMove() {
        guard nextOpacity == .full else { return }
        guard movesBack > 0 else { return }
        guard ghostMoveCount == 0 || ghostMoveStart + ghostMoveCount > moves.count - movesBack else { return }
        let i = moves.count - movesBack
        guard board.pointEmpty(moves[i].p) && (0..<64).contains(moves[i].p) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        board.addMove(moves[i].p)
        movesBack -= 1
        currentMove = moves[i]
        newHints()
        BoardScene.main.showMove(moves[i].p, wins: board.getWinLines(), ghost: ghostMoveCount != 0)
        withAnimation {
            prevOpacity = .full
            if movesBack == 0 {
                if undoOpacity == .half { undoOpacity = .full }
                nextOpacity = .half
            }
        }
        if winner == nil && movesBack == 0 {
            player[turn].move()
        }
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
        if player[turn] as? Online != nil {
            FB.main.finishedOnlineGame(with: winner == myTurn ? .myWin : .opWin)
        }
        if winner == myTurn {
            if mode == .daily && dayInt != UserDefaults.standard.integer(forKey: Key.lastDC) {
                Notifications.ifUndetermined {
                    DispatchQueue.main.async {
                        self.showDCAlert = true
                    }
                }
                Notifications.setBadge(justSolved: true, dayInt: dayInt ?? Date().getInt())
                withAnimation { newStreak = UserDefaults.standard.integer(forKey: Key.streak) }
                Timer.scheduledTimer(withTimeInterval: 2.4, repeats: false, block: { _ in
                    withAnimation { self.newStreak = nil }
                })
            } else if mode == .tricky {
                UserDefaults.standard.setValue([1], forKey: Key.train) // TODO WHAT WHY IS THIS ALSO TRAIN
            } else if mode.train && !hints {
                var beaten = UserDefaults.standard.array(forKey: Key.train) as? [Int] ?? [0,0,0,0,0,0]
                beaten[mode.trainValue] = 1
                UserDefaults.standard.setValue(beaten, forKey: Key.train)
            }
        }
    }
    
    func getHints(for moves: [Move]) {
        hintQueue.async {
            let b = Board()
            for move in moves { b.addMove(move.p) }
            let turn = b.getTurn()
            var nHint: HintValue = .noW
            if b.hasW0(turn) { nHint = .w0 }
            else if b.hasW1(turn) { nHint = .w1 }
            else if b.hasW2(turn, depth: 1) == true { nHint = .w2d1 }
            else if b.hasW2(turn) == true { nHint = .w2 }
            
            if self.myTurn == turn { moves.last?.myHint = nHint }
            else { moves.last?.opHint = nHint }
            DispatchQueue.main.async { self.newHints() }
            
            var oHint: HintValue = .noW
            if b.hasW0(turn^1) { oHint = .w0 }
            else if b.getW1(for: turn^1).count > 1 { oHint = .cm1 }
            else if b.hasW1(turn^1) { oHint = .c1 }
            else if b.hasW2(turn^1) == true {
                if b.getW2Blocks(for: turn) == nil { oHint = .cm2 }
                else if b.hasW2(turn^1, depth: 1) == true { oHint = .c2d1 }
                else { oHint = .c2 }
            }
            
            if self.myTurn == turn { moves.last?.opHint = oHint }
            else { moves.last?.myHint = oHint }
            DispatchQueue.main.async { self.newHints() }
        }
    }
    
    func requestHints() {
        getHints(for: moves.dropLast(movesBack))
    }
    
    func showMoves(for n: Int?) {
        var list: Set<Int> = []
        if let t = n {
            if t == turn {
                if board.hasW0(t) { list = [] }
                else if board.hasW1(t) { list = board.getW1(for: t) }
                else if board.hasW2(t, depth: 1) == true { list = board.getW2(for: t, depth: 1) ?? [] }
                else if board.hasW2(t) == true { list = board.getW2(for: t) ?? [] }
            } else {
                if board.hasW0(t) { list = [] }
                else if board.hasW1(t) { list = board.getW1(for: t) }
                else if board.hasW2(t, depth: 1) == true {
                    list = board.getW2Blocks(for: t^1, depth: 1) ?? []
                } else if board.hasW2(t) == true {
                    list = board.getW2Blocks(for: t^1) ?? []
                }
            }
        }
        BoardScene.main.spinSpaces(list)
    }
}
