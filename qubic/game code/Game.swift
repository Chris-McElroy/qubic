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

class Move {
    let p: Int
    var myHint: HintValue?
    var opHint: HintValue?
    
    init(_ p: Int) {
        self.p = p
        myHint = nil
        opHint = nil
    }
}

class Game: ObservableObject {
    static let main = Game()
    
//    @Published var turn: Int = 0
    @Published var hintCard: Bool = false
    @Published var currentMove: Move? = nil
    @Published var showDCAlert: Bool = false
    @Published var newStreak: Int? = nil
    @Published var undoOpacity: Opacity = .clear
    @Published var prevOpacity: Opacity = .clear
    @Published var nextOpacity: Opacity = .clear
    
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
//    var boardScene: BoardScene? = nil
    var pendingMove: (Int, UInt64)? = nil
    var moves: [Move] = []
    var movesBack: Int = 0
    var ghostMoveStart: Int = 0
    var ghostMoveCount: Int = 0
//    var replayMoveCount: Int = 0
//    var undoneMoveStack: [Int] = []
    
    init() { }
    
    func turnOff() {
        guard mode != .off else { return }
        board = Board()
        BoardScene.main.reset()
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
        self.mode = .off
    }
    
    func load(mode: GameMode, boardNum: Int = 0, turn: Int? = nil, hints: Bool = false) {
        board = Board()
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
        winner = nil
        pendingMove = nil
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
//        self.turn = 0
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
        player[self.turn].move(with: processMove)
        withAnimation {
            undoOpacity = hints ? .half : .clear
            prevOpacity = .half
            nextOpacity = .half
        }
    }
    
    func loadMove(_ move: Int) {
        // Assumes no wins!
        guard board.processMove(move) else { print("Invalid load move!"); return }
        BoardScene.main.addCube(move: move, color: .primary(player[turn].color))
//        turn = board.getTurn()
    }
    
    func processMove(_ move: Int, on key: UInt64) {
        guard movesBack == 0 && ghostMoveCount == 0 else { return }
        guard !hintCard else { pendingMove = (move, key); return }
        pendingMove = nil
        guard key == board.board[turn] else { print("Invalid turn!"); return }
        guard board.processMove(move) else { print("Invalid move!"); return }
        moves.append(Move(move))
        currentMove = moves.last
        if player[turn].rounded {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        if player[turn^1] as? Online != nil {
            FB.main.sendOnlineMove(p: move, time: -1)
        }
        BoardScene.main.showMove(move, wins: board.getWinLines())
        // TODO add async hint text shit
        // also i should make the next process move async as well
//        turn = board.getTurn()
        withAnimation { prevOpacity = .full }
        if board.hasW0(turn^1) {
            winner = turn^1
            updateWins()
            if !mode.solve || winner == myTurn { hints = true }
            withAnimation { undoOpacity = .clear }
        } else {
            if undoOpacity == .half { withAnimation { undoOpacity = .full } }
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                self.player[self.turn].move(with: self.processMove)
            })
        }
    }
    
    func processGhostMove(_ move: Int, on key: UInt64) {
        guard board.processMove(move) else { print("Invalid move!"); return }
        guard winner != nil else { return }
        if ghostMoveCount == 0 {
            ghostMoveStart = moves.count - movesBack
        }
        while ghostMoveStart + ghostMoveCount != moves.count - movesBack && movesBack > 0 {
            ghostMoveCount -= 1
            movesBack -= 1
            moves.remove(at: ghostMoveStart+ghostMoveCount)
        }
        moves.insert(Move(move), at: ghostMoveStart+ghostMoveCount)
        currentMove = moves[ghostMoveStart+ghostMoveCount]
        ghostMoveCount += 1
        // TODO add async hints shit here too
//        turn = board.getTurn()
        BoardScene.main.showMove(move, wins: board.getWinLines(), ghost: true)
        withAnimation {
            prevOpacity = .full
            nextOpacity = .half
        }
        player[myTurn].move(with: self.processGhostMove)
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
            if undoOpacity == .half && !emptyBoard {
                undoOpacity = .full
            }
        }
        if let move = pendingMove {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.processMove(move.0, on: move.1)
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
        currentMove = moves.last
        board.undoMove(for: turn^1)
        BoardScene.main.undoMove(move.p, wins: board.getWinLines())
//        turn = board.getTurn()
        let emptyBoard = (board.board[0] + board.board[1] == 0)
        if emptyBoard {
            withAnimation {
                undoOpacity = .half
                prevOpacity = .half
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.player[self.turn].move(with: self.processMove)
        })
    }
    
    func prevMove() {
        guard prevOpacity == .full else { return }
        let i = moves.count - movesBack - 1
        guard i >= 0 else { return }
        movesBack += 1
        if winner != nil { replayMode = true }
        board.undoMove(for: turn^1)
        BoardScene.main.undoMove(currentMove!.p, wins: board.getWinLines())
        currentMove = i > 0 ? moves[i-1] : nil
//        turn = board.getTurn()
        if i-1 < ghostMoveStart {
            moves.removeSubrange(ghostMoveStart..<(ghostMoveStart+ghostMoveCount))
            movesBack -= ghostMoveCount
            ghostMoveCount = 0
        }
        let emptyBoard = (board.board[0] + board.board[1] == 0)
        withAnimation {
            nextOpacity = movesBack > 0 ? .full : .half
            if undoOpacity == .full { undoOpacity = .half }
            if emptyBoard { prevOpacity = .half }
        }
        if replayMode {
            player[myTurn].move(with: processGhostMove)
        }
    }
    
    func nextMove() {
        guard nextOpacity == .full else { return }
        guard movesBack > 0 else { return }
        guard ghostMoveCount == 0 || ghostMoveStart + ghostMoveCount > moves.count - movesBack else {
            print("stopping at end of ghost moves")
            return
        }
        let i = moves.count - movesBack
        guard board.processMove(moves[i].p) else { print("Invalid redo!"); return }
        movesBack -= 1
        currentMove = moves[i]
        BoardScene.main.showMove(currentMove!.p, wins: board.getWinLines(), ghost: ghostMoveCount != 0)
//        turn = board.getTurn()
        // TODO remove replay mode
        if winner != nil { replayMode = true }
        withAnimation {
            prevOpacity = .full
            if movesBack == 0 {
                if undoOpacity == .half { undoOpacity = .full }
                nextOpacity = .half
            }
        }
        if replayMode {
            player[myTurn].move(with: processGhostMove)
        } else if movesBack == 0 {
            player[turn].move(with: processMove)
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
    
    func getHints() {
        var nHint: HintValue = .noW
        if board.hasW0(turn) { nHint = .w0 }
        else if board.hasW1(turn) { nHint = .w1 }
        else if board.hasW2(turn, depth: 1) == true { nHint = .w2d1 }
        else if board.hasW2(turn) == true { nHint = .w2 }
        
        if myTurn == turn { currentMove?.myHint = nHint }
        else { currentMove?.opHint = nHint }
        
        var oHint: HintValue = .noW
        if board.hasW0(turn^1) { oHint = .w0 }
        else if board.getW1(for: turn^1).count > 1 { oHint = .cm1 }
        else if board.hasW1(turn^1) { oHint = .c1 }
        else if board.hasW2(turn^1) == true {
            if board.getW2Blocks(for: turn) == nil { oHint = .cm2 }
            else if board.hasW2(turn^1, depth: 1) == true { oHint = .c2d1 }
            else { oHint = .c2 }
        }
        
        if myTurn == turn { currentMove?.opHint = oHint }
        else { currentMove?.myHint = oHint }
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
        BoardScene.main.spinDots(list)
    }
}
