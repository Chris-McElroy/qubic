//
//  Game.swift
//  qubicMessage
//
//  Created by 4 on 1/9/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation
import UIKit

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
    var sendMessage: (Character) -> Void = { _ in }
    var moved: Bool = false
    
    var turn: Int { board.getTurn() }
    var goBack: () -> Void = {}
    var cancelBack: () -> Bool = { true }
    var myTurn: Int = 0
    var player: [Player] = [Player(b: Board(), n: 0), Player(b: Board(), n: 0)]
    var preset: [Int] = []
    var mode: GameMode = .local
    var replayMode: Bool = false
    var nextOpacity: Opacity = .clear
    var winner: Int? = nil
    private var board = Board()
    var moves: [Move] = []
    var timers: [Timer] = []
    
    init() { }
    
    func turnOff() {
        guard mode != .off else { return }
        board = Board()
        BoardScene.main.reset()
        self.mode = .off
    }
    
    func load(mode: GameMode, boardNum: Int = 0, turn: Int, hints: Bool = false) {
        BoardScene.main.reset()
        board = Board()
        winner = nil
        moves = []
        myTurn = turn
        self.mode = mode
        let me = User(b: board, n: myTurn)
        let op = User(b: board, n: myTurn^1, name: "friend")
        if me.color == op.color { op.color = Game.getDefaultColor(for: me.color) }
        player = myTurn == 0 ? [me, op] : [op, me]
        player[self.turn].move()
    }
    
    func load(from url: URL?, movable: Bool) -> Int {
        guard let solidUrl = url else {
            print("no url")
            return 0
        }
        guard let data = URLComponents(url: solidUrl, resolvingAgainstBaseURL: false) else {
            print("couldn't parse url")
            return 0
        }
//        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
//            print("no uuid")
//            return
//        }
//        let selfCreated = data.queryItems?[2].value ?? "" == messagesID
//        myTurn = selfCreated == (data.queryItems?[3].value ?? "" == "me") ? 0 : 1
        moved = !movable
        let gameString = String(data.queryItems?[0].value?.dropFirst() ?? "")
        preset = expandMoves(gameString)
        let currentTurn = preset.count % 2
        load(mode: .local, turn: movable ? currentTurn : currentTurn^1, hints: false)
        for p in preset.dropLast() { loadMove(p) }
        if let p = preset.last { loadMove(p, animated: true) }
        return currentTurn
//        if winner == nil { (player[self.turn] as? User)?.game = self }
    }
    
    func newMove(from url: URL?) -> Int? {
        guard let solidUrl = url else {
            print("no url")
            return nil
        }
        guard let data = URLComponents(url: solidUrl, resolvingAgainstBaseURL: false) else {
            print("couldn't parse url")
            return nil
        }
        guard moved else {
            print("wrong turn", turn, myTurn, moved)
            return nil
        }
        
        let gameString = String(data.queryItems?[0].value?.dropFirst() ?? "")
        let allMoves = expandMoves(gameString)
        guard allMoves.dropLast() == preset else {
            print("wrong moves", preset, allMoves.dropLast())
            return nil
        }
        preset = allMoves
        
        let currentTurn = preset.count % 2
        if let p = preset.last { loadMove(p, animated: true) }
        moved = false
        return currentTurn
    }
    
    func loadMove(_ move: Int, animated: Bool = false) {
        guard !moves.map({ $0.p }).contains(move) && (0..<64).contains(move) else { return }
        board.addMove(move, for: turn)
        moves.append(Move(move))
        if board.hasW0(turn^1) { winner = turn^1 }
        if animated {
            Timer.after(0.8, run: {
                BoardScene.main.showMove(move, wins: self.board.getWinLines(for: move))
            })
        } else {
            BoardScene.main.addCube(move: move, color: .primary(player[turn^1].color))
        }
    }
    
    func processMove(_ move: Int, for turn: Int, num: Int) {
        guard !moved else { print("wrong turn!"); return }
        guard turn == self.turn && num == moves.count else { print("invalid turn!"); return }
        guard !moves.map({ $0.p }).contains(move) && (0..<64).contains(move) else { return }
        moved = true
        preset.append(move)
        board.addMove(move, for: turn)
        moves.append(Move(move))
        if player[turn].rounded {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        BoardScene.main.showMove(move, wins: board.getWinLines(for: move))
        // TODO add async hint text shit
        // also i should make the next process move async as well
        if board.hasW0(turn^1) {
            winner = turn^1
        } else {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                self.player[self.turn].move()
            })
        }
        sendMessage(moveStringMap[move])
    }
    
    func processGhostMove(_ move: Int) {
    }
    
    private static func getDefaultColor(for n: Int) -> Int {
        return n == 0 ? 2 : 0
    }
}

//class Game: ObservableObject {
//    static let main = Game()
//
//    @Published var turn: Int = 0
//    @Published var hintCard: Bool = false
//    @Published var hintText: [[String]]? = nil
//    @Published var showDCAlert: Bool = false
//    @Published var newStreak: Int? = nil
//    @Published var undoOpacity: Double = 0
//    @Published var redoOpacity: Double = 0
//
//    var goBack: () -> Void = {}
//    var cancelBack: () -> Bool = { true }
//    var sendMessage: (Character) -> Void = { _ in }
//    var myTurn: Int = 0
//    var player: [Player] = [Player(b: Board(), n: 0), Player(b: Board(), n: 0)]
//    var preset: [Int] = []
//    var mode: GameMode = .play
//    var dayInt: Int? = nil
//    var winner: Int? = nil
//    var replayMode: Bool = false
//    var moved: Bool = false
////    var hints: Bool = false
//    var leaving: Bool = false
//    private var board = Board()
////    var boardScene: BoardScene? = nil
//    var pendingMove: (Int, UInt64)? = nil
//    var replayMoveCount: Int = 0
//    var undoneMoveStack: [Int] = []
//
//    init() {
//    }
//
//    func load(from url: URL?) {
//        guard let solidUrl = url else {
//            print("no url")
//            return
//        }
//        guard let data = URLComponents(url: solidUrl, resolvingAgainstBaseURL: false) else {
//            print("couldn't parse parts")
//            return
//        }
//
//        let gameString = String(data.queryItems?[0].value?.dropFirst() ?? "")
//        print(gameString)
//        preset = expandMoves(gameString)
//
//        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
//            print("no uuid")
//            return
//        }
//        let selfCreated = data.queryItems?[2].value ?? "" == uuid
//        myTurn = selfCreated == (data.queryItems?[3].value ?? "" == "me") ? 0 : 1
//        moved = preset.count % 2 != myTurn
////        moved = false // TODO switch out with above
//
////        print(selfCreated, myTurn, uuid, moved)
//
//        board = Board()
//        BoardScene.main.reset()
//        undoOpacity = 0
//        redoOpacity = 0
//        winner = nil
//        pendingMove = nil
//        replayMoveCount = 0
//        undoneMoveStack = []
//        hintCard = false
//        replayMode = false
//        dayInt = Date().getInt()
//        self.turn = 0
//        self.mode = .play
//        let me = User(b: board, n: myTurn)
//        let op = User(b: board, n: myTurn^1, name: "friend")
//        if me.color == op.color { op.color = Game.getDefaultColor(for: me.color) }
//        player = myTurn == 0 ? [me, op] : [op, me]
//        for p in preset { loadMove(p) }
//        if winner == nil { player[self.turn].move(with: processMove) }
////        undoOpacity = hints ? 0.3 : 0.0
//    }
//
//    func loadMove(_ move: Int) {
//        guard board.processMove(move) else { print("Invalid load move!"); return }
//        turn = board.getTurn()
//        if undoOpacity == 0.3 { undoOpacity = 1 }
//        if board.hasW0(turn^1) {
//            winner = turn^1
//            if winner == myTurn { updateWins() }
//            undoOpacity = 1.0
//            redoOpacity = 0.3
//            BoardScene.main.showMove(move, wins: board.getWinLines())
//        } else {
//            BoardScene.main.addCube(move: move, color: .primary(player[turn].color))
//        }
//    }
//
//    func processMove(_ move: Int, on key: UInt64) {
////        print("processing move")
//        guard !moved else { return }
//        guard !hintCard else { pendingMove = (move, key); return }
//        pendingMove = nil
//        guard key == board.board[turn] else { print("Invalid turn!"); return }
//        guard board.processMove(move) else { print("Invalid move!"); return }
//        BoardScene.main.showMove(move, wins: board.getWinLines())
//        turn = board.getTurn()
//        moved = true
//        hintText = nil
//        if undoOpacity == 0.3 { undoOpacity = 1 }
//        if board.hasW0(turn^1) {
//            winner = turn^1
//            if winner == myTurn { updateWins() }
//            if ![.daily, .simple, .common, .tricky].contains(mode) || winner == myTurn {
//                undoOpacity = 1.0
//                redoOpacity = 0.3
//            }
//        } else {
//            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
//                self.player[self.turn].move(with: self.processMove)
//            })
//        }
//        sendMessage(moveStringMap[move])
//    }
//
//    func processReplayMove(_ move: Int, on key: UInt64) {
//        guard board.processMove(move) else { print("Invalid move!"); return }
//        BoardScene.main.showMove(move, wins: board.getWinLines())
//        turn = board.getTurn()
//        replayMoveCount += 1
//        hintText = nil
//        if undoOpacity == 0.3 { undoOpacity = 1 }
//        player[myTurn].move(with: self.processReplayMove)
//    }
//
//    func showHintCard() -> Bool {
//        hintCard = true
//        if undoOpacity == 1 {
//            undoOpacity = 0.3
//        }
//        if redoOpacity == 1 {
//            redoOpacity = 0.3
//        }
//
//        if hintText == nil {
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//                self.updateHintText()
//            }
//            return true
//        }
//        return false
//    }
//
//    func hideHintCard() -> Bool {
//        if !hintCard { return false }
//        hintCard = false
//        let emptyBoard = (board.board[0] + board.board[1] == 0)
//        if undoOpacity == 0.3 && !emptyBoard {
//            undoOpacity = 1
//        }
//        let fullBoard = undoneMoveStack.isEmpty
//        if redoOpacity == 0.3 && !fullBoard {
//            redoOpacity = 1
//        }
//        if let move = pendingMove {
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//                self.processMove(move.0, on: move.1)
//            }
//        }
//        return true
//    }
//
//    func undoMove() {
//        guard !hintCard else { return }
//        if winner != nil { replayMode = true }
//        guard let move = board.move[turn^1].last else { return }
//        board.undoMove(for: turn^1)
//        BoardScene.main.undoMove(move, wins: board.getWinLines())
//        turn = board.getTurn()
//        hintText = nil
//        let emptyBoard = (board.board[0] + board.board[1] == 0)
//        undoOpacity = emptyBoard ? 0.3 : 1
//        if replayMode {
//            if replayMoveCount == 0 {
//                undoneMoveStack.append(move)
//                redoOpacity = 1
//            } else {
//                replayMoveCount -= 1
//            }
//            player[myTurn].move(with: processReplayMove)
//        } else {
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
//                self.player[self.turn].move(with: self.processMove)
//            })
//        }
//    }
//
//    func redoMove() {
//        guard !hintCard else { return }
//        replayMode = true
//        while replayMoveCount != 0 {
//            let move = board.move[turn^1].last ?? 0
//            board.undoMove(for: turn^1)
//            BoardScene.main.remove(move)
//            turn = board.getTurn()
//            replayMoveCount -= 1
//        }
//        hintText = nil
//        if let move = undoneMoveStack.popLast() {
//            guard board.processMove(move) else { print("Invalid redo!"); return }
//            BoardScene.main.showMove(move, wins: board.getWinLines())
//            turn = board.getTurn()
//            hintText = nil
//            undoOpacity = 1
//        }
//        let fullBoard = undoneMoveStack.isEmpty
//        redoOpacity = fullBoard ? 0.3 : 1
//        player[myTurn].move(with: processReplayMove)
//    }
//
//    private static func getDefaultColor(for n: Int) -> Int {
//        return n == 0 ? 2 : 0
//    }
//
//    func updateWins() {
//    }
//
//    func getHints(for n: Int) -> HintValue? {
//        if n == turn {
//            if board.hasW0(n) { return .w0 }
//            else if board.hasW1(n) { return .w1 }
//            else if board.hasW2(n, depth: 1) == true { return .w2d1 }
//            else if board.hasW2(n) == true { return .w2 }
//        } else {
//            if board.hasW0(n) { return .w0 }
//            else if board.getW1(for: n).count > 1 { return .cm1 }
//            else if board.hasW1(n) { return .c1 }
//            else if board.hasW2(n) == true {
//                if board.getW2Blocks(for: n^1) == nil { return .cm2 }
//                else if board.hasW2(n, depth: 1) == true { return .c2d1 }
//                else { return .c2 }
//            }
//        }
//        return nil
//    }
//
//    func updateHintText() {
//        guard undoOpacity != 0 && hintCard && hintText == nil else { return }
//        var text = [[""],[""]]
//        switch getHints(for: myTurn) {
//        case .w0:   text[1] = ["4 in a row", "You won the game, great job!"]
//        case .w1:   text[1] = ["3 in a row","You have 3 in a row, so now you can fill in the last move in that line and win!"]
//        case .w2d1: text[1] = ["checkmate", "You can get two checks with your next move, and your opponent can’t block both!"]
//        case .w2:   text[1] = ["second order win", "You can get to a checkmate using a series of checks!"]
//        case .c1:   text[1] = ["check", "You have 3 in a row, so you can win next turn unless it’s blocked!"]
//        case .cm1:  text[1] = ["checkmate", "You have more than one check, and your opponent can’t block them all!"]
//        case .cm2:  text[1] = ["second order checkmate", "You have more than one second order check, and your opponent can’t block them all!"]
//        case .c2d1: text[1] = ["second order check", "You can get checkmate next move if your opponent doesn’t stop you!"]
//        case .c2:   text[1] = ["second order check", "You can get checkmate through a series of checks if your opponent doesn’t stop you!"]
//        case nil:   text[1] = ["no wins", "You don't have any forced wins right now, keep working to set one up!"]
//        }
//
//        switch getHints(for: myTurn^1) {
//        case .w0:   text[0] = ["4 in a row", "Your opponent won the game, better luck next time!"]
//        case .w1:   text[0] = ["3 in a row","Your opponent has 3 in a row, so now they can fill in the last move in that line and win!"]
//        case .w2d1: text[0] = ["checkmate", "Your opponent can get two checks with their next move, and you can’t block both!"]
//        case .w2:   text[0] = ["second order win", "Your opponent can get to a checkmate using a series of checks!"]
//        case .c1:   text[0] = ["check", "Your opponent has 3 in a row, so you should block their line to prevent them from winning!"]
//        case .cm1:  text[0] = ["checkmate", "Your opponent has more than one check, and you can’t block them all!"]
//        case .cm2:  text[0] = ["second order checkmate", "Your opponent has more than one second order check, and you can’t block them all!"]
//        case .c2d1: text[0] = ["second order check", "Your opponent can get checkmate next move if you don’t stop them!"]
//        case .c2:   text[0] = ["second order check", "Your opponent can get checkmate through a series of checks if you don’t stop them!"]
//        case nil:   text[0] = ["no wins", "Your opponent doesn't have any forced wins right now, keep it up!"]
//        }
//
//        hintText = text
//    }
//
//    func showMoves(for n: Int?) {
//        var list: Set<Int> = []
//        if let t = n {
//            if t == turn {
//                if board.hasW0(t) { list = [] }
//                else if board.hasW1(t) { list = board.getW1(for: t) }
//                else if board.hasW2(t, depth: 1) == true { list = board.getW2(for: t, depth: 1) ?? [] }
//                else if board.hasW2(t) == true { list = board.getW2(for: t) ?? [] }
//            } else {
//                if board.hasW0(t) { list = [] }
//                else if board.hasW1(t) { list = board.getW1(for: t) }
//                else if board.hasW2(t, depth: 1) == true {
//                    list = board.getW2Blocks(for: t^1, depth: 1) ?? []
//                } else if board.hasW2(t) == true {
//                    list = board.getW2Blocks(for: t^1) ?? []
//                }
//            }
//        }
//        BoardScene.main.spinDots(list)
//    }
//}
