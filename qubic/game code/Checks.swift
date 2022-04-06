//
//  WinHelper.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

extension Board {
	func inDict() -> Bool {
		if let ans = cachedInDict { return ans }
		let autos = Board.getAllAutomorphisms(for: board)
		for (i, a) in autos.enumerated() {
			if let (numMoves, moveList) = Board.positionDict[a] {
				cachedInDict = true
				cachedDictMoves = (numMoves, Set(Board.getAutomorphism(for: moveList, a: Board.reverseAutomorphisms[i])))
				return true
			}
		}
		cachedInDict = false
		return false
	}
	
    func hasW0(_ n: Int) -> Bool {
        // returns true if player n has won
        return !open[8*n].isEmpty
    }
    
    func getW0(for n: Int) -> Set<Int> {
        // returns the lines where player n has won
        return Set(open[8*n].keys)
    }
    
    func hasW1(_ n: Int) -> Bool {
        // returns true if player n has a win
        return !open[1+6*n].isEmpty
    }
    
    func getW1(for n: Int) -> Set<Int> {
        // returns points that give player n a win
        var wins: Set<Int> = []
        for p in open[1+6*n].values {
            wins.insert(p.first!)
        }
        return wins
    }
    
    func hasC1(_ n: Int) -> Bool {
        // returns true if player n has
        // at least one option for a check
        return !open[2+4*n].isEmpty
    }
    
    func getC1(for n: Int) -> Set<Int> {
        // returns points that leave player n with
        // at least one option for a win next move
        var wins: Set<Int> = []
        for p in open[2+4*n].values {
            wins.insert(p.first!)
        }
        return wins
    }
    
    private struct W2Board: Hashable {
        let board: Board
        let n: Int
        var starts: Set<Int>
        
        init(board: Board, n: Int, starts: Set<Int>) {
            self.board = Board(board)
            self.n = n
            self.starts = starts
        }
        
        static func == (lhs: Board.W2Board, rhs: Board.W2Board) -> Bool {
            lhs.board.board[lhs.n] == rhs.board.board[rhs.n]
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(board.board[n])
        }
        
        func addCheckMove(_ n: Int, _ stack: inout Set<W2Board>, _ first: Bool) -> Set<Int>? {
            let o = n^1
            if let check = board.open[1+6*o].values.first?[0] {
                if let back = checkBack(n, check) {
                    let b1 = W2Board(board: board, n: n, starts: first ? [check] : starts)
                    b1.board.addMove(check, for: n)
                    if b1.board.hasW1(o) { return nil }
                    b1.board.addMove(back, for: o)
                    if b1.board.hasW1(n) { return b1.starts }
                    
                    if var other = stack.update(with: b1) {
                        other.starts.formUnion(b1.starts)
                        stack.update(with: other)
                    }
                }
            }
            return nil  // board.move[n][first]
        }
        
        func checkBack(_ n: Int, _ p: Int) -> Int? {
            for pair in board.open[2+4*n].values {
                for i in [0,1] {
                    if pair[i] == p { return pair[i^1] }
                }
            }
            return nil
        }
        
        func addAllForces(_ n: Int, _ stack: inout Set<W2Board>, _ first: Bool) -> Set<Int>? {
			var winningStarts: Set<Int> = []
            for pair in board.open[2+4*n].values {
                let b1 = W2Board(board: board, n: n, starts: first ? [pair[0]] : starts)
                b1.board.addMove(pair[0], for: n)
                b1.board.addMove(pair[1], for: n^1)
				if b1.board.hasW1(n) { winningStarts.formUnion(b1.starts) }
                
                let b2 = W2Board(board: board, n: n, starts: first ? [pair[1]] : starts)
                b2.board.addMove(pair[1], for: n)
                b2.board.addMove(pair[0], for: n^1)
				if b2.board.hasW1(n) { winningStarts.formUnion(b2.starts) }
                
                if var other1 = stack.update(with: b1) {
                    other1.starts.formUnion(b1.starts)
                    stack.update(with: other1)
                }
                if var other2 = stack.update(with: b2) {
                    other2.starts.formUnion(b2.starts)
                    stack.update(with: other2)
                }
            }
			return winningStarts.isEmpty ? nil : winningStarts
        }
	}
    
	func hasW2(_ n: Int, depth: Int = 32, time: TimeInterval = 30, valid: () -> Bool = { true }) -> Bool? {
		if depth == 0 { return false }
		guard valid() else { return nil }
		if let w2 = cachedHasW2[n] { return w2 <= depth }
        let o = n^1
        var stack: Set<W2Board> = [W2Board(board: self, n: n, starts: [])]
        var nextStack: Set<W2Board> = []
		let start = Date.now
        
		for d in 1...depth {
            for b in stack {
				guard nextStack.count < 40000 else { break }
				guard valid() else {
//					print("tripped hasW2")
					return nil
				}
                if b.board.hasW1(o) {
                    if b.addCheckMove(n, &nextStack, d == 1) != nil {
						cachedHasW2[n] = d
                        return true
                    }
                } else {
                    if b.addAllForces(n, &nextStack, d == 1) != nil {
						cachedHasW2[n] = d
                        return true
                    }
                }
            }
            stack = nextStack
            nextStack = []
			if Date.now > start + time { return nil }
        }
		if depth >= 32 { cachedHasW2[n] = Int.max }
        return false
    }
    
	func getW2(for n: Int, depth: Int = 32, time: TimeInterval = 30, valid: () -> Bool = { true }) -> Set<Int>? {
		if depth == 0 { return [] }
		if let w2 = cachedGetW2[n][depth] { return w2 }
        let o = n^1
        var stack: Set<W2Board> = [W2Board(board: self, n: n, starts: [])]
        var nextStack: Set<W2Board> = []
        var wins: Set<Int> = []
		let start = Date.now
        
		for d in 1...depth {
            for b in stack {
				guard nextStack.count < 10000 else { break }
				guard valid() else {
//					print("tripped getW2")
					return nil
				}
				if b.board.hasW1(o) {
					if let p = b.addCheckMove(n, &nextStack, d == 1) {
						wins.formUnion(p)
					}
				} else {
					if let p = b.addAllForces(n, &nextStack, d == 1) {
						wins.formUnion(p)
					}
				}
            }
            stack = nextStack
            nextStack = []
			if Date.now > start + time { return wins }
			cachedGetW2[n][d] = wins
        }
        return wins
    }
    
	func getW2Blocks(for n: Int, depth: Int = 32, time: TimeInterval = 30, valid: () -> Bool = { true }) -> Set<Int>? {
		if let w2 = cachedGetW2Blocks[n][depth] { return w2 }
		let checkBoard = Board(self)
        var blocks: Set<Int> = []
        let o = n^1
        if hasW1(n) { return nil } // I should handle this case but I'm not
        if hasW2(o) == false { return nil }
        let checks = open[2+4*n].values.joined() // same for removing checks below
        let options = Array(0..<64).filter({ pointEmpty($0) && !checks.contains($0) })
		let start = Date.now
        for p in options.shuffled() {
			guard valid() else {
//				print("tripped getW2Blocks")
				return nil
			}
			checkBoard.addMove(p, for: n)
			if checkBoard.hasW2(o, depth: depth, time: time - (Date.now - start)) == false { blocks.insert(p) }
			checkBoard.undoMove(for: n)
            if Date.now > start + time { break }
        }
		if time >= 30 { cachedGetW2Blocks[n][depth] = blocks }
//        if blocks.isEmpty { print("threatmate") }
        return blocks.isEmpty ? nil : blocks
    }
	
//	func hasW2P(for n: Int, depth: Int) -> Bool {
//		if depth == 0 { return false }
//		let o = n^1
//		if let w2 = cachedHasW2[n] { return w2 <= depth }
//		var forces: [Force] = move[n].map { Force(p: $0) }
//		var forceBoard: [[Int]] = Array(repeating: [], count: 64)
//		var force1 = 0
//
//		while force1 < forces.count {
//			if findWins() { return true } // TODO try switching to happen immediately when the force is found
//			findForces()
//			forceBoard[forces[force1].g].append(force1)
//			force1 += 1
//		}
//
//		func findWins() -> Bool {
//			for force2 in forceBoard[forces[force1].g] {
//				// check that force1 and force2 do not conflict
//				guard noConflict(force2) else { continue }
//
//				// see if the sequence creates check
//				var checks: [(g: Int, c: Int, r: UInt64)] = []
//				fillChecks(force: force1)
//				fillChecks(force: force2)
//
//				let checkBoard = Board(self)
//				let path: [Int] = [] // TODO change to var when i'm writing this again
//
//				while path.count < checks.count {
//					let opWins = checkBoard.getW1(for: o)
//					if !opWins.isEmpty {
//						let gain = opWins.first!
//						if let check = checks.first(where: { $0.g == gain }),
//						   (check.r & checkBoard.board[n] == check.r) && (opWins.count == 1) {
//							// the check is solvable
//							checkBoard.addMove(check.g, for: n)
//							checkBoard.addMove(check.c, for: o)
//						} else {
//							// give up and reset
//
//							// wrong — there are more cases tham this
//						}
//					} else {
//
////						checkBoard.addMove(gain)
////						checkBoard.addMove(cost)
//					}
//				}
//
//
//
////				if checkBoard.hasW1(o) || checkBoard.hasW0(o) {
////					continue // we can't stop these wins
////				} else if hadCheck {
////					// see if you can order it to block the check on the next move
////				} else {
////					// checks.count is wrong now bc i flipped checks
////					if checks.count < (cachedHasW2[n] ?? 64) { cachedHasW2[n] = checks.count }
////					if checks.count < depth { return true }
////				}
//
//				@discardableResult func fillChecks(force: Int) -> UInt64 {
//					guard let cost = forces[force].c else { return 0 }
//					let r = (1 &<< forces[force].g)
//						| fillChecks(force: forces[force].from1!)
//						| fillChecks(force: forces[force].from2!)
//					checks.append((forces[force].g, cost, r))
//					return r
//				}
//			}
//
//			return false
//		}
//
//		func findForces() {
//			let opBoard = forces[force1].costs | board[o]
//			let f1Board = forces[force1].all | board[n]
//			for line in Board.linesThruPoint[forces[force1].g] {
//				guard Board.linePoints[line] & opBoard == 0 else { continue }
//				let points = Board.pointsInLine[line]
//				for p in points where p != forces[force1].g {
//					guard let (_, c3, c4) = Board.inLine[forces[force1].g][p] else { print("wrote this wrong"); break }
//
//					// check that c3 and c4 are empty and are not part of force1
//					guard f1Board & ((1 &<< c3) | (1 &<< c4)) == 0 else { continue }
//
//					for force2 in forceBoard[p] {
//						// check that c3 and c4 are not part of force2
//						guard forces[force2].all & ((1 &<< c3) | (1 &<< c4)) == 0 else { continue }
//
//						// check that force1 and force2 do not conflict
//						guard noConflict(force2) else { continue }
//
//						// add the two resulting forces
//						let all = forces[force1].all | forces[force2].all | (1 &<< c3) | (1 &<< c4)
//						let gains = forces[force1].gains | forces[force2].gains
//						let costs = forces[force1].costs | forces[force2].costs
//						forces.append(Force(g: c3, c: c4, all: all, gains: gains | (1 &<< c3), costs: costs | (1 &<< c4), from1: force1, from2: force2))
//						forces.append(Force(g: c4, c: c3, all: all, gains: gains | (1 &<< c4), costs: costs | (1 &<< c3), from1: force1, from2: force2))
//					}
//				}
//			}
//		}
//
//		func noConflict(_ force2: Int) -> Bool {
//			// check that the gain cubes and cost cubes are separate
//			if (forces[force1].gains & forces[force2].costs) | (forces[force1].costs & forces[force2].gains) != 0 { return false }
//
//			// if the costs don't overlap, you're all good
//			if forces[force1].costs & forces[force2].costs == 0 { return true }
//
//			// otherwise, check that the cost cubes have the same gain cubes
//			var costsDict: [Int: Int] = [:]
//
//			func fillDict(force: Int) {
//				guard let cost = forces[force].c else { return }
//				costsDict[cost] = forces[force].g
//				fillDict(force: forces[force].from1 ?? 0)
//				fillDict(force: forces[force].from2 ?? 0)
//			}
//
//			func checkDict(force: Int) -> Bool {
//				guard let cost = forces[force].c else { return true }
//				if let oldGain = costsDict.updateValue(forces[force].g, forKey: cost), oldGain != forces[force].g {
//					return false
//				}
//				return checkDict(force: forces[force].from1 ?? 0)
//					&& checkDict(force: forces[force].from2 ?? 0)
//			}
//
//			fillDict(force: force1)
//			return checkDict(force: force2)
//		}
//
//		return false
//	}
//
//	struct Force: Hashable {
//		let g: Int
//		let c: Int?
//		let all: UInt64
//		let gains: UInt64
//		let costs: UInt64
//		let from1: Int?
//		let from2: Int?
//
//		init(p: Int) {
//			g = p
//			c = nil
//			all = 0
//			gains = 0
//			costs = 0
//			from1 = nil
//			from2 = nil
//		}
//
//		init(g: Int, c: Int, all: UInt64, gains: UInt64, costs: UInt64, from1: Int, from2: Int) {
//			self.g = g
//			self.c = c
//			self.all = all
//			self.gains = gains
//			self.costs = costs
//			self.from1 = from1
//			self.from2 = from2
//		}
//	}
    
//    func hasO2Win(_ n: Int) -> Bool {
//        // returns true if player n has 1st order check,
//        // and they have a string of checks available that
//        // leads to a 1st order checkmate
//        let wins = getO1WinsFor(n)
//        if wins.count != 1 { return false }
//        addMove(wins.first!) // only works if the next player is o
//        // TODO make this callable no matter who's move it is
//        // TODO check for o getting check with their move
//        if get2ndOrderWinFor(n) != nil {
//            undoMove()
//            return true
//        }
//        undoMove()
//        return false
//    }
    
//    func get2ndOrderWinFor(_ n: Int) -> Int? {
//        // if possible, returns a point that will give player n a 1st order check,
//        // and will eventually allow them to get a 2nd order win
//
//        // TODO check the state of the board?
//        // or state clearly what I'm assuming about the board
//        let o = n^1
//        dTable = []
//        var dQueue: Set<D> = []
//        var dBoard: [Set<D>] = Array(repeating: [], count: 64)
//        move[n].forEach { m in dQueue.insert(D(given: m)) }
//
//        while let d0 = dQueue.popFirst() {
//            // try to find wins
//            for d1 in dBoard[d0.gain] {
//                if let winPairs = worksSansChecks(d0: d0, d1: d1) {
//                    let gains2 = d0.gains | d1.gains
//                    let costs2 = d0.costs | d1.costs
//                    // check that no checks will form
//                    var checkPoint: Int? = nil
//                    var checkStatus: [[Int]] = status
//                    for cost in winPairs.keys {
//                        if checkPoint != nil { break }
//                        for l in Board.linesThruPoint[cost] {
//                            if checkStatus[o][l] == 2 && checkStatus[n][l] == 0 {
//                                var points = Board.pointsInLine[l]
//                                points.remove(at: cost)
//                                for p in points {
//                                    if (board[o] | costs2) & (1 &<< p) == 0 {
//                                        checkPoint = p
//                                        break
//                                    }
//                                }
//                                break
//                            }
//                            checkStatus[o][l] += 1
//                        }
//                    }
//                    // TODO make sure that if the check has a check on the way, that it also finds that
//                    // if no checks, you're good!
//                    guard let forcedPoint = checkPoint else {
//                        // yay we found one! (checkPoint was nil)
//                        return getFirstMove(i: 4, printMoves: false)
//                    }
//                    // otherwise, see if the forced point is left open
//                    if gains2 & (1 &<< forcedPoint) == 0 {
//                        // if they are open, see if the natural blocks work
//                    }
//                        // if they are closed, see if you can build up to that block without the thing that causes it
//                        // also consider seeing if you can stop the check from being a check at all?
//                }
//            }
//            // try to find new deductions
//            let opBoard = d0.costs | board[o]
//            for l in Board.linesThruPoint[d0.gain] {
//                // check that the line seems clear
//                if Board.linePoints[l] & opBoard == 0 {
//                    let points = Board.pointsInLine[l] //.subtracting([d0.gain])
//                    for p in points {
//                        for d1 in dBoard[p] {
//                            // check that the gain cubes and cost cubes are separate
//                            if (d0.gains & d1.costs) | (d0.costs & d1.gains) == 0 {
//                                var newPoints = points//.subtracting([p])
//                                let p0 = newPoints[0]
//                                let p1 = newPoints[0]
//                                let gains = d0.gains | d1.gains
//                                let costs = d0.costs | d1.costs
//                                // check that p0 and p1 are open
//                                if ((board[n] | gains | costs) & ((1 &<< p0) | (1 &<< p1))) == 0 {
//                                    // check that the cost cubes only overlap if the gain cubes for that one overlaps
//                                    var allPairs: Dictionary<Int,Int> = d0.pairs
//                                    var mergable: Bool = true
//                                    for pair in d1.pairs {
//                                        if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
//                                            if prevGain != pair.value {
//                                                mergable = false
//                                                break
//                                            }
//                                        }
//                                    }
//                                    if mergable {
//                                        dQueue.insert(D(gain: p0, cost: p1, gains: gains | (1 &<< p0) , costs: costs | (1 &<< p1), pairs: allPairs.add((key: p1, value: p0)), line: l))
//                                        dQueue.insert(D(gain: p1, cost: p0, gains: gains | (1 &<< p1) , costs: costs | (1 &<< p0), pairs: allPairs.add((key: p0, value: p1)), line: l))
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            dBoard[d0.gain].insert(d0)
//        }
//        return nil
//    }
    
//    func noConflict(n: Int, d0: D, d1: D, p0: Int, p1: Int) -> (UInt64, UInt64, Dictionary<Int,Int>)? {
//        // check that the gain cubes and cost cubes are separate
//        if (d0.gains & d1.costs) | (d0.costs & d1.gains) != 0 {
//            return nil
//        }
//        let gains = d0.gains | d1.gains
//        let costs = d0.costs | d1.costs
//        // check that p0 and p1 are open
//        if ((board[n] | gains | costs) & ((1 &<< p0) | (1 &<< p1))) != 0 {
//            return nil
//        }
//        // check that the cost cubes only overlap if the gain cubes for that one overlaps
//        var allPairs: Dictionary<Int,Int> = d0.pairs
//        for pair in d1.pairs {
//            if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
//                if prevGain != pair.value {
//                    return nil
//                }
//            }
//        }
//        // success!
//        return (gains, costs, allPairs)
//    }
//
//    func worksSansChecks(d0: D, d1: D) -> Dictionary<Int,Int>? {
//        // check that the gain cubes and cost cubes are separate
//        if (d0.gains & d1.costs) | (d0.costs & d1.gains) != 0 {
//            return nil
//        }
//        // check that the cost cubes only overlap if the gain cubes for that one overlaps
//        var allPairs: Dictionary<Int,Int> = d0.pairs
//        for pair in d1.pairs {
//            if let prevGain = allPairs.updateValue(pair.value, forKey: pair.key) {
//                if prevGain != pair.value {
//                    return nil
//                }
//            }
//        }
//        return allPairs
//    }
//
//    func checkCombos(n: Int, plyLimit: Int) -> Int? {
//        // check for non-conflicting deductions on the same point
//        let opTurn = inc(n)
//        let undoNum = move.count
//        for i in 0..<dTable.count {
//            for j in 0..<i {
//                // if the two points are the same
//                if dTable[i].gain == dTable[j].gain {
//                    let i1 = dTable[i].line
//                    let i2 = dTable[i].line
//                    // add all the first ones, should never fail (not adding j/i itself)
//                    let _ = addDMoves(i: i1, myTurn: n, opTurn: opTurn)
//                    let _ = addDMoves(i: i2, myTurn: n, opTurn: opTurn)
//
//                    let j1 = dTable[j][2]
//                    let j2 = dTable[j][3]
//                    // try adding all the second ones (again not adding j/i itself)
//                    if addDMoves(i: j1, myTurn: n, opTurn: opTurn) {
//                        if addDMoves(i: j2, myTurn: n, opTurn: opTurn) {
//                            // make sure the two sets don't create checks with each other
//                            if getMyLines(n: opTurn, k: 3) == 0 && b.getMyLines(n: opTurn, k: 4) == 0 {
//                                // if we got here, they're compatible, so go for it
//                                undoDMoves(undoNum: undoNum)
//                                return getFirstMove(i: i, printMoves: false)
//                                }
//                            }
//                        }
//                    }
//                    undoDMoves(undoNum: undoNum)
//                }
//            }
//        }
//        return nil
//    }
//
//    func getFirstMove(i: Int, printMoves: Bool) -> Int {
//        var possMove = dTable[i][0]
//        var nextD = i
//        while dTable[nextD][2] != dLen {
//            if printMoves {
//                print(possMove)
//            }
//            possMove = dTable[nextD][0]
//            nextD = dTable[nextD][2]
//        }
//        return possMove
//    }
    
    
    
//    func hasO1Checkmate(_ n: Int) -> Bool {
//        // returns true if player n will have a win
//        // available no matter what the opponent does
//        for p in (0..<64).filter({ pointEmpty($0) }) {
//            if Board.linesThruPoint[p].filter({ status[$0] == 2*(1 + 4*n) }).count > 1 {
//                return true
//            }
//        }
//        return false
//    }
//
//    func getO1CheckmatesFor(_ n: Int) -> [Int] {
//        // returns points that leave player n with a
//        // win no matter what the opponent does
//        var checkmates: [Int] = []
//        for p in (0..<64).filter({ pointEmpty($0) }) {
//            if Board.linesThruPoint[p].filter({ status[$0] == 2*(1 + 4*n) }).count > 1 {
//                checkmates.append(p)
//            }
//        }
//        return checkmates
//    }
}

//    // TODO consider removing
//    func getMyLines(_ n: Int) -> [Int] {
//        return set[n].map({ s in s.count })
//
//
//        var myMove: Bool = n == 1
//        for p in move {
//            if myMove {
//                for l in linesThruPoint[p] {
//                    linesArray[l] += 1
//                }
//            } else {
//                for l in linesThruPoint[p] {
//                    linesArray[l] = 5 // invalidates
//                }
//            }
//            myMove.toggle()
//        }
//        var numLines = Array(repeating: 0, count: 4)
//        for c in linesArray {
//            if (0..<4).contains(c) {
//                numLines[c] += 1
//            }
//        }
//        return numLines
//    }
//
//    func getMyLinesArray(_ n: Int) -> ([Int], [[Int]]) {
//        var linesArray: [Int] = Array(repeating: 0, count: 76)
//        var myMove: Bool = n == 1
//        for p in move {
//            if myMove {
//                for l in linesThruPoint[p] {
//                    linesArray[l] += 1
//                }
//            } else {
//                for l in linesThruPoint[p] {
//                    linesArray[l] = 5 // invalidates
//                }
//            }
//            myMove.toggle()
//        }
//        var numLines = Array(repeating: 0, count: 4)
//        var linesList = Array(repeating: [Int](), count: 4)
//        for (c, i) in linesArray.enumerated() {
//            if (0..<4).contains(c) {
//                numLines[c] += 1
//                linesList[c].append(i)
//            }
//        }
//        return (numLines, linesList)
//    }

//
//    // return number of open points on lines with k of n's points
//    func getMyPointsArray(n: Int, k: Int) -> (Int, [Bool]) {
//        var array = Array(repeating: false, count: 64)
//        var numPoints = 0
//
//        if (k == 0) {
//            for i in 0...75 {
//                if self.line[i][0] == 0 {
//                    for p in 0...3 {
//                        // all points are open
//                        array[pointsInLine[i][p]] = true
//                    }
//                }
//            }
//        } else {
//            for i in 0...75 {
//                if self.line[i][0] == n {
//                    if self.line[i][1] == k {
//                        for p in 0...3 {
//                            let currentPoint = pointsInLine[i][p]
//                            if self.point[currentPoint] != n {
//                                array[currentPoint] = true
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        for i in 0...63 {
//            if array[i] {
//                numPoints += 1
//            }
//        }
//
//        return (numPoints, array)
//    }
