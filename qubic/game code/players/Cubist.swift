//
//  Cubist.swift
//  qubic
//
//  Created by 4 on 10/11/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Cubist: Player {
	let corners = [0, 3, 12, 15, 48, 51, 60, 63]
	let centers = [21, 22, 25, 26, 37, 38, 41, 42]
	let adjacents: [Int: Set<Int>] = [
		0: [3, 12, 48],
		3: [0, 15, 51],
		12: [0, 15, 60],
		15: [3, 12, 63],
		48: [0, 60, 51],
		51: [48, 3, 63],
		60: [63, 12, 48],
		63: [60, 51, 15],
		21: [22, 25, 37],
		22: [21, 26, 38],
		25: [26, 21, 41],
		26: [25, 22, 42],
		37: [38, 41, 25],
		38: [37, 42, 22],
		41: [42, 37, 25],
		42: [41, 38, 26]
	]
	let cornerSquares: [Set<Int>] = [
		[0, 3, 12, 15],
		[0, 3, 60, 63],
		[0, 3, 48, 51],
		[12, 15, 48, 51],
		[12, 15, 60, 63],
		[0, 12, 48, 60],
		[0, 12, 51, 63],
		[3, 15, 48, 60],
		[3, 15, 51, 63],
		[48, 51, 60, 63],
		[0, 15, 48, 63],
		[3, 12, 51, 60]
	]
	let centerSquares: [Set<Int>] = [
		[21, 22, 25, 26],
		[21, 22, 41, 42],
		[21, 22, 37, 38],
		[25, 26, 37, 38],
		[25, 26, 41, 42],
		[21, 25, 37, 41],
		[21, 25, 38, 42],
		[22, 26, 37, 41],
		[22, 26, 38, 42],
		[37, 38, 41, 42],
		[21, 26, 37, 42],
		[22, 25, 38, 41]
	]
	func opposite(_ p: Int) -> Int { 63 - p }
	let mainDiagonal: [Int: Set<Int>] = [
		0:  [21, 42, 63],
		3:  [3, 22, 41, 60],
		12: [12, 25, 38, 51],
		15: [15, 26, 37, 48],
		48: [15, 26, 37, 48],
		51: [12, 25, 38, 51],
		60: [3, 22, 41, 60],
		63: [0, 21, 42, 63],
		21: [0, 21, 42, 63],
		22: [3, 22, 41, 60],
		25: [12, 25, 38, 51],
		26: [15, 26, 37, 48],
		37: [15, 26, 37, 48],
		38: [12, 25, 38, 51],
		41: [3, 22, 41, 60],
		42: [0, 21, 42, 63]
	]
	func adjacent(_ p1: Int, _ p2: Int) -> Bool {
		let difference = abs(p1 - p2)
		return difference == 3 || difference == 12 || difference == 48 || difference == 1 || difference == 4 || difference == 16
	}
	
	init(b: Board, n: Int, id: String = "cubist", name: String = "cubist", color: Int = 8) {
		super.init(b: b, n: n, id: id, name: name, color: color)
    }
	
	override func move() {
		cancelMove()
		let moveBoard = Board(b)
		let setup = moveBoard.getSetup()
		
		moveQueue.async { [self] in
			if moveBoard.hasW1(n) { go(in: moveBoard.getW1(for: n)) }
			
			else if moveBoard.hasW1(o) { go(in: moveBoard.getW1(for: o)) }
			
			else if moveBoard.hasW2(n, depth: 12, time: 4, valid: { gameNum == Game.main.gameNum }) == true {
				let wins = moveBoard.getW2(for: n, depth: moveBoard.cachedHasW2[n] ?? 12, time: 20, valid: { gameNum == Game.main.gameNum })
				if wins == nil { print("error - empty win after finding one") }
				go(in: wins ?? [])
			}
			
			else {
				let myMoves = moveBoard.move[n]
				let opMoves = moveBoard.move[o]
				
				if moveBoard.numMoves() < 2 {
					
					// FIRST MOVE
					go(in: Set(Board.rich).filter({ moveBoard.pointEmpty($0) }))
					return
				}
				
				if moveBoard.numMoves() == 3 {
					
					// SECOND MOVE AS P2
					go(in: Set(Board.rich).filter({ moveBoard.pointEmpty($0) && !adjacents[$0]!.contains(myMoves[0]) }))
					return
				}
				
				if n == 0 && myMoves.count < 5 {
					let allMoves = myMoves + opMoves
					var allCorners = true
					var allCenters = true
					
					for move in allMoves {
						if !corners.contains(move) { allCorners = false }
						if !centers.contains(move) { allCenters = false }
					}
					
					if allCorners || allCenters {
						if myMoves.count == 1 {
							
							// SECOND MOVE
							go(in: (adjacents[myMoves[0]] ?? Set(0..<64)).filter({ moveBoard.pointEmpty($0) }))
							return
						} else if myMoves.count == 2 {
							if opMoves.count != 2 { return }
							if adjacent(opMoves[0], opMoves[1]) {
								
								// THIRD MOVE, OP MOVED ADJ
								let opposite0 = myMoves.contains(opposite(opMoves[0]))
								let opposite1 = myMoves.contains(opposite(opMoves[1]))
								if opposite0 && opposite1 {
									go(in: Set(allCorners ? corners : centers).filter({ moveBoard.pointEmpty($0) }))
								} else if opposite0 || opposite1 {
									go(in: Set([opposite(opMoves[opposite0 ? 1 : 0])]))
								} else {
									go(in: Set(myMoves.map { opposite($0) }))
								}
							} else if opposite(opMoves[0]) == opMoves[1] {
								
								// THIRD MOVE, OP MOVED MD
								go(in: Set(myMoves.map { opposite($0) }))
							} else if opMoves.contains(opposite(myMoves[0])) {
								
								// THIRD MOVE, OP BLOCKED YOUR 1st MD
								go(in: adjacents[myMoves[0]]!.filter({ moveBoard.pointEmpty($0) }))
							} else if opMoves.contains(opposite(myMoves[1])) {
								
								// THIRD MOVE, OP BLOCKED YOUR 2nd MD
								go(in: adjacents[myMoves[1]]!.filter({ moveBoard.pointEmpty($0) }))
							} else {
								
								// THIRD MOVE, OP MOVED DIA ADJ TO YOU
								if adjacent(myMoves[0], opMoves[0]) {
									go(in: Set([opposite(myMoves[0])]))
								} else {
									go(in: Set([opposite(myMoves[1])]))
								}
							}
							return
						} else {
							let op1Diagonal = opMoves.contains(where: { adjacents[$0]!.subtracting(opMoves).count == 1 })
							let my1Diagonal = myMoves.contains(where: { adjacents[$0]!.subtracting(myMoves).count == 1 })
							if op1Diagonal && my1Diagonal {
								
								// FOURTH MOVE, BOTH IN 1-DIAGONAL
								go(in: Set(myMoves.map { opposite($0) }).filter { moveBoard.pointEmpty($0) })
							} else if op1Diagonal {
								
								// FOURTH MOVE, OP IN 1-DIAGONAL
								go(in: Set(allCorners ? corners : centers).filter({ moveBoard.pointEmpty($0) }))
							} else if my1Diagonal {
								
								// FOURTH MOVE, CUBIST IS IN 1-DIAGONAL
								go(in: Set(allCorners ? centers : corners).filter({ mainDiagonal[$0]!.subtracting(opMoves).count != 1 }))
							} else {
								
								// FOURTH MOVE, BOTH HAVE 2-DIAGONALS
								go(in: Set(allCorners ? corners : centers).filter({ moveBoard.pointEmpty($0) && adjacents[$0]!.subtracting(myMoves).count == 2 }))
							}
							return
						}
					}
				}
				
				var best = Int.min
				var bestOptions: Set<Int> = []
				let minimaxBoard = Board(b)
//				var tried = 0
				let options = getOptions(board: minimaxBoard, depth: 12, time: 10, needsOptions: true)
				var alpha = Int.min
				
				for option in options {
//					tried += 1
//					print("MAIN", tried, "out of", options.count)
//					if n != minimaxBoard.getTurn() { print("WRONG ADD MAIN") }
					minimaxBoard.addMove(option, for: n)
					let m = minimax(on: minimaxBoard, depth: 1, alpha: alpha, beta: Int.max)
					alpha = max(alpha, m)
					if m > best {
						bestOptions = [option]
						best = m
					}
					else if m == best { bestOptions.insert(option) }
					minimaxBoard.undoMove(for: n)
				}
				
				print("going on minimax!", best, bestOptions)
				go(in: bestOptions)
			}
		}
		
		func go(in set: Set<Int>) {
			let move: Int
			if let choice = set.randomElement() { move = choice }
			else {
				print("error - empty set")
				move = (0..<64).first(where: { moveBoard.pointEmpty($0) }) ?? 0
			}
			
			DispatchQueue.main.async {
				self.moveTimer = Timer.after(1) {
					Game.main.processMove(move, for: self.n, setup: setup)
				}
			}
		}
	}
	
	func minimax(on board: Board, depth: Int, alpha: Int, beta: Int) -> Int {
		var a = alpha
		var b = beta
		
		var value: Int = board.getTurn() == n ? Int.min : Int.max
		
		if depth == 0 {
			if board.hasW1(n) { return Int.min }
			if board.hasW2(n, depth: 2, time: 1) == true {
				let blocks = board.getW2Blocks(for: o, depth: 2, time: 10)
//				print("found a win!", board.move[n].last ?? -1, blocks ?? [-1])
				if blocks == nil {
//					print("ran out of time finding blocks!")
					value = Int.min
				} else if blocks == [] {
//					print("unblockable!", board.move[n][3])
					value = Int.max
				} else {
					value = 0
					for block in blocks ?? [] {
						value += Board.rich.contains(block) ? 2 : 1
					}
//					print("value!", value, board.move[n].last ?? -1)
				}
			} else {
				value = 0
			}
		} else if board.getTurn() == n {
			if board.hasW1(o) {
				let w1Blocks = board.getW1(for: o)
				if w1Blocks.count > 1 {
					value = Int.min
				} else {
					board.addMove(w1Blocks.first ?? 0, for: n)
					value = minimax(on: board, depth: depth-1, alpha: a, beta: b)
					board.undoMove(for: n)
				}
			} else {
				let options = getOptions(board: board, depth: 2, time: 1, needsOptions: false)
//				var tried = 0
				for option in options {
//					tried += 1
//					print("in 2!", tried, "out of", options.count)
					board.addMove(option, for: n)
					value = max(value, minimax(on: board, depth: depth-1, alpha: a, beta: b))
					board.undoMove(for: n)
					a = max(a, value)
					if value >= b {
//						print("breaking 2", value == Int.min ? "min" : value == Int.max ? "max" : String(value), a, b)
						break
					}
				}
			}
		} else {
			if board.hasW1(n) {
				let w1Blocks = board.getW1(for: n)
				if w1Blocks.count > 1 {
//					print("is this it?", board.move[n][3])
					value = Int.max
				} else {
					board.addMove(w1Blocks.first ?? 0, for: o)
					value = minimax(on: board, depth: depth, alpha: a, beta: b)
					board.undoMove(for: o)
				}
			} else {
				let options = getOptions(board: board, depth: 2, time: 1, needsOptions: false)
//				var tried = 0
				for option in options {
//					tried += 1
//					print("in 1!", tried, "out of", options.count)
					board.addMove(option, for: o)
					value = min(value, minimax(on: board, depth: depth, alpha: a, beta: b))
					board.undoMove(for: o)
					b = min(b, value)
					if value <= a {
//						print("breaking 1", value == Int.min ? "min" : value == Int.max ? "max" : String(value), a, b)
						break
					}
				}
			}
		}
		
//		if value == Int.max {
//			print("returning max", depth, board.getTurn() == n, board.move[n])
//		}
		return value
	}
	
	func getOptions(board: Board, depth: Int, time: Double, needsOptions: Bool) -> Set<Int> {
		var options = Set((0..<64).filter { board.pointEmpty($0) })
		let turn = board.nextTurn() == 0 ? 0 : 1 // I was getting errors without this when undoing
		if board.hasW2(turn, depth: depth, time: time/10, valid: { gameNum == Game.main.gameNum }) == true {
			if let blocks = board.getW2Blocks(for: turn^1, depth: depth, time: time, valid: { gameNum == Game.main.gameNum }) {
				if !needsOptions || !blocks.isEmpty {
					options = blocks
					if needsOptions { print("succeeded at", depth, "depth") }
				} else {
					print("failed at", depth, "depth, going to", depth/2)
					options = getOptions(board: board, depth: depth/2, time: time/2, needsOptions: true)
				}
			} else {
				if needsOptions {
					print("ran out of time at", depth, "depth, going to", depth/2)
					options = getOptions(board: board, depth: depth/2, time: time/2, needsOptions: true)
				}
			}
		}
		let richOptions = options.intersection(Board.rich)
		if !richOptions.isEmpty { options = richOptions }
		
		return options
	}
}

