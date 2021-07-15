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

enum GameState: Int {
    // each one is 1 more
    case error = 0, new, active, myWin, opWin, myTimeout, opTimeout, myLeave, opLeave, draw
    
    func mirror() -> GameState {
        switch self {
        case .myWin: return .opWin
        case .opWin: return .myWin
        case .myTimeout: return .opTimeout
        case .opTimeout: return .myTimeout
        case .myLeave: return .opLeave
        case .opLeave: return .myLeave
        case .draw: return .draw
        default: return .error
        }
    }
    
    var myWin: Bool {
        self == .myWin || self == .opTimeout || self == .opLeave
    }
    
    var opWin: Bool {
        self == .opWin || self == .myTimeout || self == .myLeave
    }
}

enum HintValue {
    case w0, w1, w2, w2d1
    case c1, cm1, cm2, c2d1, c2
    case noW
}

enum SolveType {
    case d1, d2, d3, d4, si, tr, no
}

class Move: Equatable {
    let p: Int
    var myHint: HintValue?
    var opHint: HintValue?
    var myMoves: Set<Int>?
    var opMoves: Set<Int>?
    var solveType: SolveType?
    
    init(_ p: Int) {
        self.p = p
        myHint = nil
        opHint = nil
        solveType = nil
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
    @Published var hints: Bool = false
    @Published var showHintFor: Int? = nil
    @Published var currentTimes: [Int] = [0,0]
    
    var turn: Int { board.getTurn() }
    var realTurn: Int { gameState == .active ? moves.count % 2 : (gameState.myWin ? myTurn : (gameState.opWin ? myTurn^1 : 2)) }
    var goBack: () -> Void = {}
    var cancelBack: () -> Bool = { true }
    var myTurn: Int = 0
    var player: [Player] = [Player(b: Board(), n: 0), Player(b: Board(), n: 0)]
    var times: [[Double]] = [[], []]
    var totalTime: Double? = nil
    var lastStart: [Double] = [0,0]
    var preset: [Int] = []
    var mode: GameMode = .local
    var dayInt: Int = Date.int
    var solveBoard: Int = 0
    var gameState: GameState = .new
    var replayMode: Bool = false
    var solved: Bool = false
    var leaving: Bool = false
    private var board = Board()
	let hintQueue = OperationQueue()
    var movesBack: Int = 0
    var ghostMoveStart: Int = 0
    var ghostMoveCount: Int = 0
    var newHints: () -> Void = {}
    var timers: [Timer] = []
    var premoves: [Int] = []
    var currentHintMoves: Set<Int>? {
        if showHintFor == 1 {
            return currentMove?.myMoves
        } else if showHintFor == 0 {
            return currentMove?.opMoves
        }
        return nil
    }
    
    init() {
        hintQueue.qualityOfService = .userInitiated
    }
    
    func load(mode: GameMode, boardNum: Int = 0, turn: Int? = nil, hints: Bool = false, time: Double? = nil) {
        board = Board()
        BoardScene.main.reset()
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
        gameState = .active
        currentMove = nil
        moves = []
        totalTime = time
        if let total = time {
            currentTimes = [Int(total),Int(total)]
            times = [[total],[total]]
            lastStart = [0,0]
        }
        movesBack = 0
        ghostMoveStart = 0
        ghostMoveCount = 0
        hintCard = false
        replayMode = false
        premoves = []
        showHintFor = nil
        newStreak = nil
        setPreset(boardNum, for: mode)
        dayInt = Date.int
        solveBoard = boardNum
        myTurn = turn != nil ? turn! : preset.count % 2
        self.mode = mode
        self.hints = hints
        let me = User(b: board, n: myTurn)
        let op = getOp(boardNum: boardNum, myColor: me.color)
        player = myTurn == 0 ? [me, op] : [op, me]
        for p in preset { loadMove(p) }
        newHints()
        
        func setPreset(_ boardNum: Int, for mode: GameMode) {
            if mode == .daily {
                let m = dayInt*dayInt*(dayInt+boardNum)
                let size = dailyBoards[boardNum].count/3
                let aNum = (m/(10000000*size)) % 192
                let bNum = ((m/1000000) % size) + size*(dayInt % 3)
                preset = expandMoves(dailyBoards[boardNum][bNum]).map { Board.automorphisms[aNum][$0] }
                solved = (Storage.array(.daily) as? [Int])?[boardNum] == dayInt
            }
            else if mode == .simple { getInfo(from: simpleBoards, key: .simple) }
            else if mode == .common { getInfo(from: commonBoards, key: .common) }
            else if mode == .tricky { getInfo(from: trickyBoards, key: .tricky) }
            else {
                preset = []
                solved = false
            }
            
            func getInfo(from boards: [String], key: Key) {
                if boardNum < boards.count {
                    preset = expandMoves(boards[boardNum])
                    solved = (Storage.array(key) as? [Int])?[boardNum] != 0
                } else {
                    preset = Board.getAutomorphism(for: expandMoves(boards.randomElement() ?? ""))
                    solved = false
                }
            }
        }
        
        func getOp(boardNum: Int, myColor: Int) -> Player {
            let op: Player
            switch mode {
            case .novice:   op = Novice(b: board, n: myTurn^1)
            case .defender: op = Defender(b: board, n: myTurn^1)
            case .warrior:  op = Warrior(b: board, n: myTurn^1)
            case .tyrant:   op = Tyrant(b: board, n: myTurn^1)
            case .oracle:   op = Oracle(b: board, n: myTurn^1)
            case .cubist:   op = Cubist(b: board, n: myTurn^1)
            case .daily:    op = Daily(b: board, n: myTurn^1, num: boardNum)
            case .simple:   op = Simple(b: board, n: myTurn^1, num: boardNum)
            case .common:   op = Common(b: board, n: myTurn^1, num: boardNum)
            case .tricky:   op = Tricky(b: board, n: myTurn^1, num: boardNum)
            case .local:    op = User(b: board, n: myTurn^1, name: "friend")
            case .online:   op = Online(b: board, n: myTurn^1)
            default:        op = Novice(b: board, n: myTurn^1)
            }
            if myColor == op.color { op.color = [4, 4, 1, 4, 6, 7, 4, 5, 7][myColor] }
            return op
        }
    }
    
    func startGame() {
        withAnimation {
            undoOpacity = hints || mode.solve ? .half : .clear
            prevOpacity = .half
            nextOpacity = .half
        }
        if totalTime != nil {
            lastStart[turn] = Date.now+2
            timers.append(Timer.every(0.1, run: getCurrentTime))
        }
        player[turn].move()
    }
    
    func getCurrentTime() {
        if gameState == .active {
            let newTime = max(0, Int(((times[realTurn].last ?? 0) + lastStart[realTurn] - Date.now).rounded()))
            if newTime < currentTimes[realTurn] {
                currentTimes[realTurn] = newTime
                if newTime == 0 && player[realTurn].local {
                    endGame(with: realTurn == myTurn ? .myTimeout : .opTimeout)
                }
            }
        }
    }
    
    func loadMove(_ p: Int) {
        // Assumes no wins!
        let move = Move(p)
        guard !moves.contains(move) && (0..<64).contains(move.p) else { return }
        board.addMove(move.p)
        moves.append(move)
        currentMove = move
        getHints(for: moves, loading: true)
        BoardScene.main.addCube(move: move.p, color: .of(n: player[turn^1].color))
    }
    
    func processMove(_ p: Int, for turn: Int, num: Int, time: Double? = nil) {
        let move = Move(p)
        guard gameState == .active else { return }
        guard turn == realTurn && num == moves.count else { print("Invalid turn!"); return }
        guard !moves.contains(move) && (0..<64).contains(move.p) else { print("Invalid move!"); return }
        moves.append(move)
        if movesBack != 0 { movesBack += 1 }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        getHints(for: moves, time: time)
        if !player[turn^1].local {
            FB.main.sendOnlineMove(p: move.p, time: times[turn].last ?? -1)
        }
        guard movesBack == 0 else { return }
        board.addMove(move.p)
        currentMove = move
        newHints()
        BoardScene.main.showMove(move.p, wins: board.getWinLines(for: move.p))
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
        BoardScene.main.showMove(move.p, wins: board.getWinLines(for: move.p), ghost: true)
        withAnimation {
            prevOpacity = .full
            nextOpacity = .half
        }
    }
    
    func getHints(for moves: [Move], loading: Bool = false, time: Double? = nil) {
        let b = Board()
        for move in moves { b.addMove(move.p) }
        let turn = b.getTurn()
        
        if gameState == .active {
            if let total = totalTime {
                let timeLeft = time ?? ((times[turn^1].last ?? 0) + lastStart[turn^1] - Date.now)
                times[turn^1].append(min(total, max(0, timeLeft)))
                currentTimes[turn^1] = Int(min(total, max(timeLeft, 0)))
                lastStart[turn] = Date.now + 0.2
            }
            if b.hasW0(turn^1) { endGame(with: turn^1 == myTurn ? .myWin : .opWin) }
            else if b.numMoves() == 64 { endGame(with: .draw) }
            else if !loading {
                timers.append(Timer.after(0.2, run: player[turn].move))
            }
        }
        
		hintQueue.addOperation {
            var nHint: HintValue = .noW
            if b.hasW0(turn) { nHint = .w0 }
            else if b.hasW1(turn) { nHint = .w1 }
            else if b.hasW2(turn, depth: 1) == true { nHint = .w2d1 }
            else if b.hasW2(turn) == true { nHint = .w2 }

            if self.myTurn == turn { moves.last?.myHint = nHint }
            else { moves.last?.opHint = nHint }

            if solveButtonsEnabled {
                if nHint == .w1 {
                    moves.last?.solveType = .d1
                } else if nHint == .w2d1 {
                    moves.last?.solveType = .d2
                } else if nHint == .w2 {
                    if b.hasW2(turn, depth: 2) == true {
                        moves.last?.solveType = .d3
                    } else if b.hasW2(turn, depth: 3) == true {
                        moves.last?.solveType = .d4
                    } else if b.hasW2(turn, depth: 5) == false {
                        moves.last?.solveType = .tr
                    } else {
                        moves.last?.solveType = .si
                    }
                } else {
                    moves.last?.solveType = .no
                }
            }
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

            var nMoves: Set<Int> = []
            switch nHint {
            case .w1: nMoves = b.getW1(for: turn)
            case .w2: nMoves = b.getW2(for: turn) ?? []
            case .w2d1: nMoves = b.getW2(for: turn, depth: 1) ?? []
            default: break
            }

            if self.myTurn == turn { moves.last?.myMoves = nMoves }
            else { moves.last?.opMoves = nMoves }
            if self.showHintFor == 1 {
                DispatchQueue.main.async { BoardScene.main.spinMoves() }
            }

            var oMoves: Set<Int> = []
            switch oHint {
            case .c1, .cm1: oMoves = b.getW1(for: turn^1)
            case .c2d1: oMoves = b.getW2Blocks(for: turn, depth: 1) ?? []
            case .c2: oMoves = b.getW2Blocks(for: turn) ?? []
            default: break
            }

            if self.myTurn == turn { moves.last?.opMoves = oMoves }
            else { moves.last?.myMoves = oMoves }
            if self.showHintFor == 0 {
                DispatchQueue.main.async { BoardScene.main.spinMoves() }
            }
        }
    }
    
    @discardableResult func showHintCard() -> Bool {
        withAnimation {
            hintCard = true
//            if undoOpacity == .full {
//                undoOpacity = .half
//            }
        }
        return false
    }
    
    @discardableResult func hideHintCard() -> Bool {
        if !hintCard { return false }
        withAnimation {
            hintCard = false
//            let emptyBoard = (board.board[0] + board.board[1] == 0)
//            if undoOpacity == .half && !emptyBoard && movesBack == 0 {
//                undoOpacity = .full
//            }
        }
        return true
    }
    
    func undoMove() {
        guard movesBack == 0 else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            for delay in stride(from: 0.0, to: 0.4, by: 0.3) {
                Game.main.timers.append(Timer.after(delay, run: { Game.main.nextOpacity = .half }))
                Game.main.timers.append(Timer.after(delay + 0.15, run: { Game.main.nextOpacity = .full }))
            }
            return
        }
        guard undoOpacity == .full else { return }
        guard gameState == .active else { return }
        guard let move = moves.popLast() else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        player[0].cancelMove()
        player[1].cancelMove()
        currentMove = moves.last
        newHints()
        premoves = []
        board.undoMove(for: turn^1)
        if totalTime != nil {
            times[turn].removeLast()
            currentTimes[turn] = max(0, Int((times[turn].last ?? 0).rounded()))
            currentTimes[turn^1] = max(0, Int((times[turn^1].last ?? 0).rounded()))
            lastStart[turn] = Date.now + 0.5
        }
        BoardScene.main.undoMove(move.p)
        if moves.count == preset.count {
            withAnimation {
                undoOpacity = .half
                prevOpacity = .half
            }
        }
        timers.append(Timer.after(0.5, run: player[turn].move))
    }
    
    func prevMove() {
        guard prevOpacity == .full else { return }
        let i = moves.count - movesBack - 1
        guard i >= ((!hints && mode.solve) ? preset.count : 0) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        movesBack += 1
        board.undoMove(for: turn^1)
        currentMove = i > 0 ? moves[i-1] : nil
        if gameState != .active {
            replayMode = true
            if totalTime != nil && ghostMoveCount == 0 {
                currentTimes[turn] = max(0, Int((times[turn][board.move[turn].count]).rounded()))
            }
        }
        BoardScene.main.undoMove(moves[i].p)
        newHints()
        if i-1 < ghostMoveStart {
            moves.removeSubrange(ghostMoveStart..<(ghostMoveStart+ghostMoveCount))
            movesBack -= ghostMoveCount
            ghostMoveCount = 0
        }
        withAnimation {
            nextOpacity = movesBack > 0 ? .full : .half
            if undoOpacity == .full { undoOpacity = .half }
            let minMoves = gameState.myWin ? 0 : preset.count
            if moves.count - movesBack == minMoves { prevOpacity = .half }
        }
    }
    
    func nextMove() {
        guard ghostMoveCount == 0 || ghostMoveStart + ghostMoveCount > moves.count - movesBack else {
            if prevOpacity == .full && movesBack != 0 {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                for delay in stride(from: 0.0, to: 0.4, by: 0.3) {
                    timers.append(Timer.after(delay, run: { self.prevOpacity = .half }))
                    timers.append(Timer.after(delay + 0.15, run: { self.prevOpacity = .full }))
                }
            }
            return
        }
        guard nextOpacity == .full else { return }
        guard movesBack > 0 else { return }
        let i = moves.count - movesBack
        guard board.pointEmpty(moves[i].p) && (0..<64).contains(moves[i].p) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        board.addMove(moves[i].p)
        movesBack -= 1
        currentMove = moves[i]
        if gameState != .active && totalTime != nil && ghostMoveCount == 0 {
            currentTimes[turn^1] = max(0, Int((times[turn^1][board.move[turn^1].count]).rounded()))
        }
        newHints()
        BoardScene.main.showMove(moves[i].p, wins: board.getWinLines(for: moves[i].p), ghost: ghostMoveCount != 0)
        withAnimation {
            prevOpacity = .full
            if movesBack == 0 {
                if undoOpacity == .half { undoOpacity = .full }
                nextOpacity = .half
            }
        }
        if gameState == .active && movesBack == 0 {
            player[turn].move()
        }
    }
    
    func endGame(with end: GameState) {
        guard gameState == .active else { turnOff(); return }
        
        gameState = end
        premoves = []
        if !mode.solve || end.myWin { hints = true }
        BoardScene.main.spinMoves()
        withAnimation { undoOpacity = .clear }
    
        if !player[myTurn^1].local {
            FB.main.finishedOnlineGame(with: gameState)
        }
        
        if end == .myTimeout || end == .opTimeout { BoardScene.main.spinBoard() }
        
        if end.myWin {
            if mode == .daily {
                recordSolve(type: .daily)
                if Storage.array(.daily) as? [Int] == [dayInt, dayInt, dayInt, dayInt] && dayInt != Storage.int(.lastDC) {
                    Notifications.ifUndetermined {
                        DispatchQueue.main.async {
                            self.showDCAlert = true
                        }
                    }
                    Notifications.setBadge(justSolved: true, dayInt: dayInt)
                    withAnimation { newStreak = Storage.int(.streak) }
                    timers.append(Timer.after(2.4, run: { withAnimation { self.newStreak = nil } }))
                    Layout.main.checkDaily()
                }
            }
            else if mode == .simple { recordSolve(type: .simple) }
            else if mode == .common { recordSolve(type: .common) }
            else if mode == .tricky { recordSolve(type: .tricky) }
            else if mode.train && !hints { recordSolve(type: .train) }
        }
        
        if end == .myLeave { turnOff() }
        
        func recordSolve(type: Key) {
            guard var solves = Storage.array(type) as? [Int], solveBoard < solves.count else { return }
            solves[solveBoard] = dayInt
            Storage.set(solves, for: type)
        }
    }
    
    func turnOff() {
        guard mode != .off else { return }
        
        for timer in timers {
            timer.invalidate()
        }
        timers = []
        hintQueue.cancelAllOperations()
        
        player[0].cancelMove()
        player[1].cancelMove()
        
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
        
        self.mode = .off
    }
    
    func uploadSolveBoard(_ key: String) {
        FB.main.uploadSolveBoard(board.getMoveString(), key: key)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
