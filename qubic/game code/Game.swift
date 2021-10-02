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
	case picture1, picture2, picture3, picture4
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
    var nHint: HintValue? = nil
    var oHint: HintValue? = nil
    var nAllMoves: Set<Int>? = nil
	var oAllMoves: Set<Int>? = nil
	var nBestMoves: Set<Int>? = nil
	var oBestMoves: Set<Int>? = nil
	var winLen: Int = 0
    var solveType: SolveType? = nil
    
    init(_ p: Int) {
        self.p = p
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
//    @Published var newStreak: Int? = nil
    @Published var undoOpacity: Opacity = .clear
    @Published var prevOpacity: Opacity = .clear
    @Published var nextOpacity: Opacity = .clear
    @Published var moves: [Move] = []
    @Published var hints: Bool = false
    @Published var showHintFor: Int? = nil
	@Published var showAllHints: Bool = true
    @Published var currentTimes: [Int] = [0,0]
	@Published var gameEndPopup: Bool = false
    
	var gameNum: Int = 0
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
	var lastDC: Int = 0
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
	var animatingWin: Bool = false
    var timers: [Timer] = []
    var premoves: [Int] = []
	var rematchRequested: Bool = false
	var mostRecentGame: (GameMode, Int, Int?, Bool, Double?) = (.novice, 0, nil, false, nil)
    var currentHintMoves: Set<Int>? {
		guard let hintFor = showHintFor else { return nil }
		if (hintFor == 1) == (myTurn == turn) {
			return showAllHints ? currentMove?.nAllMoves : currentMove?.nBestMoves
		} else {
			return showAllHints ? currentMove?.oAllMoves : currentMove?.oBestMoves
		}
    }
    
    init() {
        hintQueue.qualityOfService = .userInitiated
    }
    
    func load(mode: GameMode, boardNum: Int = 0, turn: Int? = nil, hints: Bool = false, time: Double? = nil) {
		mostRecentGame = (mode, boardNum, turn, hints, time)
        board = Board()
        BoardScene.main.reset()
		gameNum += 1
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
        gameState = .new
        currentMove = nil
        moves = []
        totalTime = time
        if let total = time {
            currentTimes = [Int(total),Int(total)]
            times = [[total],[total]]
            lastStart = [0,0]
        }
		if mode == .picture1 {
			totalTime = 200
			currentTimes = [185, 156]
			times = [[185], [156]]
			lastStart = [0,0]
		}
        movesBack = 0
        ghostMoveStart = 0
        ghostMoveCount = 0
        hintCard = false
        replayMode = false
        premoves = []
        showHintFor = nil
		showAllHints = true
		gameEndPopup = false
		animatingWin = false
//        newStreak = nil
		dayInt = Date.int
		lastDC = Storage.int(.lastDC)
		solveBoard = boardNum
        setPreset(for: mode)
		if !preset.isEmpty { myTurn = preset.count % 2 }
		else if let givenTurn = turn { myTurn = givenTurn }
		else { myTurn = .random(in: 0...1) }
		if mode == .picture2 {
			myTurn ^= 1
		}
		if mode == .picture3 {
			myTurn ^= 1
			Timer.after(0.2, run: { BoardScene.main.rotate(right: true); BoardScene.main.rotate(right: true) })
		}
        self.mode = mode
        self.hints = hints
        var me = User(b: board, n: myTurn)
        let op = getOp(boardNum: boardNum, myColor: me.color)
		if mode == .picture1 {
			me = User(b: board, n: myTurn, name: "𝓽𝓪𝓷𝓰𝓸")
			me.color = 1
			op.name = "Vimz"
			op.color = 2
			op.rounded = true
		} else if mode == .picture2 {
			me = User(b: board, n: myTurn, name: "Patashnik")
			me.color = 5
		} else if mode == .picture3 {
			me = User(b: board, n: myTurn, name: "4Dliner")
			me.color = 6
		} else if mode == .picture4 {
			me = User(b: board, n: myTurn, name: "Sam")
			me.color = 0
		}
		player = myTurn == 0 ? [me, op] : [op, me]
        for p in preset { loadMove(p) }
        newHints()
        
        func setPreset(for mode: GameMode) {
			if mode == .picture1 {
				preset = expandMoves("HRVDGqlJdhmiv9") // move anywhere
				solved = false
				return
			} else if mode == .picture2 {
				preset = expandMoves("Vqhsv9dHtRCDT") // ends on its own
				solved = false
				return
			} else if mode == .picture3 {
				preset = expandMoves("MRVQCJmDOXsvuN") // ends on its own
				solved = true
				return
			} else if mode == .picture4 {
				preset = expandMoves("DH-QYmKr90FPs2v1faRiVhelMb") // get the 4 in a row
				solved = false
				return
			}
			let oldPreset = preset
			
			if mode == .daily { getInfo(key: .daily) }
            else if mode == .simple { getInfo(key: .simple) }
            else if mode == .common { getInfo(key: .common) }
            else if mode == .tricky { getInfo(key: .tricky) }
            else {
                preset = []
                solved = false
            }
			
			if rematchRequested {
				rematchRequested = false
				preset = oldPreset
				return
			}
            
            func getInfo(key: Key) {
				let boards = solveBoards[key] ?? [""]
                if solveBoard < boards.count {
                    preset = expandMoves(boards[solveBoard])
					solved = (Storage.array(key) as? [Bool])?[solveBoard] ?? true
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
			case .picture1: op = Online(b: board, n: myTurn^1)
			case .picture2: op = Tricky(b: board, n: myTurn^1, num: 22)
			case .picture3: op = Cubist(b: board, n: myTurn^1)
			case .picture4: op = Daily(b: board, n: myTurn^1, num: 3)
            default:        op = Novice(b: board, n: myTurn^1)
            }
            if myColor == op.color { op.color = [4, 4, 1, 4, 6, 7, 4, 5, 7][myColor] }
            return op
        }
    }
	
	func loadRematch() {
		rematchRequested = true
		load(mode: mostRecentGame.0, boardNum: mostRecentGame.1, turn: mostRecentGame.2, hints: mostRecentGame.3, time: mostRecentGame.4)
	}
	
	func loadNextGame() {
		let newMode: GameMode
		switch mostRecentGame.0 {
		case .novice: newMode = .defender
		case .defender: newMode = .warrior
		case .warrior: newMode = .tyrant
		case .tyrant: newMode = .oracle
		case .oracle: newMode = .cubist
		case .picture1: newMode = .picture2
		case .picture2: newMode = .picture3
		case .picture3: newMode = .picture4
		default: newMode = mostRecentGame.0
		}
		if newMode.train && mostRecentGame.0 != .cubist {
			Layout.main.trainSelection[0] += 1
		}
		
		var newBoardNum: Int = mostRecentGame.1
		if newMode.solve {
			let key: Key = [.simple: .simple, .common: .common, .tricky: .tricky][newMode, default: .daily]
			if newBoardNum < solveBoardCount(key) {
				newBoardNum += 1
				Layout.main.solveSelection[0] += 1
			}
		}
		
		load(mode: newMode, boardNum: newBoardNum, turn: mostRecentGame.2, hints: mostRecentGame.3, time: mostRecentGame.4)
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
		gameState = .active
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
		if [.picture2, .picture3, .picture4].contains(mode) && turn != myTurn || mode == .picture1 {
			Timer.after(mode == .picture2 ? 1.5 : mode == .picture3 ? 5 : 0, run: { self.endGame(with: .myWin) })
			return
		}
        let move = Move(p)
        guard gameState == .active else { return }
        guard turn == realTurn && num == moves.count else { print("Invalid turn!"); return }
        guard !moves.contains(move) && (0..<64).contains(move.p) else { print("Invalid move!"); return }
        moves.append(move)
        if movesBack != 0 { movesBack += 1 }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		if !player[turn^1].local {
			FB.main.sendOnlineMove(p: move.p, time: times[turn].last ?? -1)
		}
        getHints(for: moves, time: time)
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
		let num = gameNum
        
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
            else if b.hasW2(turn, depth: 1, valid: { num == self.gameNum }) == true { nHint = .w2d1 }
			else if b.hasW2(turn, valid: { num == self.gameNum }) == true { nHint = .w2; moves.last?.winLen = (b.cachedHasW2[turn] ?? 0) + 1 }
			guard num == self.gameNum else { return }
            moves.last?.nHint = nHint

            if solveButtonsEnabled {
                if nHint == .w1 {
                    moves.last?.solveType = .d1
                } else if nHint == .w2d1 {
                    moves.last?.solveType = .d2
                } else if nHint == .w2 {
                    if b.hasW2(turn, depth: 2, valid: { num == self.gameNum }) == true {
                        moves.last?.solveType = .d3
                    } else if b.hasW2(turn, depth: 3, valid: { num == self.gameNum }) == true {
                        moves.last?.solveType = .d4
                    } else if b.hasW2(turn, depth: 5, valid: { num == self.gameNum }) == false {
                        moves.last?.solveType = .tr
                    } else {
                        moves.last?.solveType = .si
                    }
                } else {
                    moves.last?.solveType = .no
                }
            }
			guard num == self.gameNum else { return }
            DispatchQueue.main.async { self.newHints() }

            var oHint: HintValue = .noW
            if b.hasW0(turn^1) { oHint = .w0 }
            else if b.getW1(for: turn^1).count > 1 { oHint = .cm1 }
            else if b.hasW1(turn^1) { oHint = .c1 }
			else if b.hasW2(turn^1, valid: { num == self.gameNum }) == true {
				if b.getW2Blocks(for: turn, valid: { num == self.gameNum }) == nil { oHint = .cm2 }
                else if b.hasW2(turn^1, depth: 1, valid: { num == self.gameNum }) == true { oHint = .c2d1 }
                else { oHint = .c2 }
            }
			
			guard num == self.gameNum else { return }
			moves.last?.oHint = oHint
            DispatchQueue.main.async { self.newHints() }

            var nAllMoves: Set<Int> = []
			var nBestMoves: Set<Int> = []
            switch nHint {
            case .w1:
				nAllMoves = b.getW1(for: turn)
				nBestMoves = nAllMoves
			case .w2:
				nAllMoves = b.getW2(for: turn, valid: { num == self.gameNum }) ?? []
				nBestMoves = b.getW2(for: turn, depth: b.cachedHasW2[turn] ?? 0, valid: { num == self.gameNum }) ?? []
			case .w2d1:
				nAllMoves = b.getW2(for: turn, valid: { num == self.gameNum }) ?? []
				nBestMoves = b.getW2(for: turn, depth: 1, valid: { num == self.gameNum }) ?? []
            default: break
            }
			
			guard num == self.gameNum else { return }
			moves.last?.nAllMoves = nAllMoves
			moves.last?.nBestMoves = nBestMoves
			// show hint for == 1 -> my wins
			// if i go first then that's showHintFor = 0
			// no what i'm testing for here is that showHintFor is equal to the person who's move it is
			if self.myTurn == turn ? self.showHintFor == 0 : self.showHintFor == 1 {
                DispatchQueue.main.async { BoardScene.main.spinMoves() }
            }

			var oAllMoves: Set<Int> = []
			var oBestMoves: Set<Int> = []
            switch oHint {
            case .c1, .cm1:
				oAllMoves = b.getW1(for: turn^1)
				oBestMoves = oAllMoves
            case .c2d1:
				oAllMoves = b.getW2Blocks(for: turn, valid: { num == self.gameNum }) ?? []
				oBestMoves = oAllMoves
			case .c2:
				oAllMoves = b.getW2Blocks(for: turn, valid: { num == self.gameNum }) ?? []
				oBestMoves = oAllMoves
            default: break
            }
			
			guard num == self.gameNum else { return }
			moves.last?.oAllMoves = oAllMoves
			moves.last?.oBestMoves = oBestMoves
			if self.myTurn == turn ? self.showHintFor == 1 : self.showHintFor == 0 {
                DispatchQueue.main.async { BoardScene.main.spinMoves() }
            }
        }
    }
    
	func showHintCard() {
		if animatingWin { return }
        withAnimation {
            hintCard = true
        }
    }
    
    @discardableResult func hideHintCard() -> Bool {
        if !hintCard { return false }
        withAnimation {
            hintCard = false
        }
        return true
    }
	
	func showGameEndPopup() {
		Layout.main.halfBack = true
		withAnimation {
			gameEndPopup = true
		}
	}
	
	@discardableResult func hideGameEndPopup() -> Bool {
		if !gameEndPopup { return false }
		FB.main.cancelOnlineSearch?()
		animatingWin = false
		Layout.main.halfBack = false
		withAnimation {
			gameEndPopup = false
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
		board.undoMove(for: turn^1)
		premoves = []
        currentMove = moves.last
        newHints()
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
		BoardScene.main.spinMoves()
		animatingWin = true
		hideHintCard()
		
		let feedback = UINotificationFeedbackGenerator()
		feedback.prepare()
		
		if end.myWin {
			if mode == .daily {
				// keeping this custom so that it uses dayInt instead of Date.int
				var dailyHistory = Storage.dictionary(.dailyHistory) as? [String: [Bool]] ?? [:]
				dailyHistory[String(dayInt), default: [false, false, false, false]][solveBoard] = true
				Storage.set(dailyHistory, for: .dailyHistory)
				
				if dailyHistory[String(dayInt)] == [true, true, true, true] && dayInt > Storage.int(.lastDC) {
					verifyDailyData()
					Notifications.ifUndetermined {
						DispatchQueue.main.async {
							self.showDCAlert = true
						}
					}
					Notifications.setBadge(justSolved: true, dayInt: dayInt)
//					withAnimation { newStreak = Storage.int(.streak) }
//					timers.append(Timer.after(2.4, run: { withAnimation { self.newStreak = nil } }))
					updateDailyData() // turns off red dot
				}
				
				FB.main.updateMyStats()
			}
			else if mode == .simple { recordSolve(type: .simple, index: solveBoard) }
			else if mode == .common { recordSolve(type: .common, index: solveBoard) }
			else if mode == .tricky { recordSolve(type: .tricky, index: solveBoard) }
			else if let index = [.novice, .defender, .warrior, .tyrant, .oracle, .cubist].firstIndex(of: mode), !hints {
				recordSolve(type: .train, index: index)
			}
		}
		
        if !mode.solve || end.myWin { hints = true }
        withAnimation { undoOpacity = .clear }
    
        if !player[myTurn^1].local {
            FB.main.finishedOnlineGame(with: gameState)
        }
        
        if end == .myTimeout || end == .opTimeout { BoardScene.main.spinBoard() }
        
        if end == .myLeave { turnOff() }
		else {
			timers.append(Timer.after(1) {
				self.showGameEndPopup()
				feedback.notificationOccurred(end.myWin ? .error : .warning)
			})
		}
        
		func recordSolve(type: Key, index: Int) {
			guard var solvesForType = Storage.array(type) as? [Bool] else { print("Can't record solve"); return }
			if index == solvesForType.count { return }
			solvesForType[index] = true
			Storage.set(solvesForType, for: type)
			
			if mode.solve {
				var allSolves = Storage.array(.solvedBoards) as? [String] ?? []
				let solveString = compressMoves(preset)
				if !allSolves.contains(solveString) { allSolves.append(solveString) }
				Storage.set(allSolves, for: .solvedBoards)
			}
			
			FB.main.updateMyStats()
        }
    }
    
    func turnOff() {
        guard mode != .off else { return }
		
		self.mode = .off
		
//		timers.append(Timer.after(1) {
//			self.hintCard = false
//			self.gameEndPopup = false
//			self.animatingWin = false
//		})
		
		cancelActions()
        
        undoOpacity = .clear
        prevOpacity = .clear
        nextOpacity = .clear
    }
	
	func cancelActions() {
		for timer in timers {
			timer.invalidate()
		}
		timers = []
		hintQueue.cancelAllOperations()
		
		player[0].cancelMove()
		player[1].cancelMove()
	}
    
    func uploadSolveBoard(_ key: String) {
        FB.main.uploadSolveBoard(board.getMoveString(), key: key)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
