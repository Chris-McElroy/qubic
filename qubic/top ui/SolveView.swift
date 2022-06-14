//
//  SolveView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SolveView: View {
    @ObservedObject var layout = Layout.main
    @State var typeLabels: [Any] = getTypeLabels()
	@State var solvedBoards: [Bool] = getSolves()
    @State var menuUpdateTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            if layout.current == .solve {
                GameView()
					.onAppear { game.load(mode: mode, boardNum: boardNum) }
            } else if layout.current == .solveMenu {
				HPicker(width: 100, height: 40, selection: $layout.solveSelection[1], labels: $typeLabels, onSelection: onTypeSelection)
				HPicker(width: 100, height: 40, selection: $layout.solveSelection[0], labels: .constant(SolveView.getBoardLabels()), underlines: $solvedBoards, onSelection: onBoardSelection)
					.onAppear {
						refreshMenu()
						TipStatus.main.updateTip(for: .solveMenu)
					}
            }
        }
		.onAppear { refreshMenu() }
    }
    
    func refreshMenu() {
        typeLabels = SolveView.getTypeLabels()
		solvedBoards = SolveView.getSolves()
        updateDailyData()
        let delay = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)).timeIntervalSinceNow
        menuUpdateTimer?.invalidate()
        menuUpdateTimer = Timer.after(delay, run: {
			refreshMenu()
        })
    }
	
	var mode: GameMode {
		switch layout.solveSelection[1] {
		case 0: return .daily
		case 1: return .simple
		case 2: return .common
		default: return .tricky
		}
	}
	
	var boardNum: Int {
		switch layout.solveSelection[1] {
		case 0: return layout.solveSelection[0] - 0
		case 1: return layout.solveSelection[0] - solveBoardCount(.daily)
		case 2: return layout.solveSelection[0] - (solveBoardCount(.daily) + (solveBoardCount(.simple) + 1))
		default: return layout.solveSelection[0] - (solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + (solveBoardCount(.common) + 1))
		}
	}
	
	func onTypeSelection(type: Int) {
		switch type {
		case 0: layout.solveSelection[0] = firstBoard(of: .daily)
		case 1: layout.solveSelection[0] = solveBoardCount(.daily) + firstBoard(of: .simple)
		case 2: layout.solveSelection[0] = solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + firstBoard(of: .common)
		case 3: layout.solveSelection[0] = solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + (solveBoardCount(.common) + 1) + firstBoard(of: .tricky)
		default: break
		}
	}
	
    func onBoardSelection(board: Int) {
		if board < solveBoardCount(.daily) { layout.solveSelection[1] = 0 }
		else if board < solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) { layout.solveSelection[1] = 1 }
		else if board < solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + (solveBoardCount(.common) + 1) { layout.solveSelection[1] = 2 }
		else { layout.solveSelection[1] = 3 }
    }
    
    func firstBoard(of type: Key) -> Int {
        let list = Storage.array(type) as? [Bool] ?? []
		return list.enumerated().first(where: { !$0.element })?.offset ?? (type == .daily ? 0 : list.count)
    }
    
    static func getTypeLabels() -> [Any] {
		[
			("daily", Storage.int(.streak)),
			("simple", (Storage.array(.simple) as? [Int])?.reduce(0, { $0 + ($1 == 0 ? 0 : 1) }) ?? 0),
			("common", (Storage.array(.common) as? [Int])?.reduce(0, { $0 + ($1 == 0 ? 0 : 1) }) ?? 0),
			("tricky", (Storage.array(.tricky) as? [Int])?.reduce(0, { $0 + ($1 == 0 ? 0 : 1) }) ?? 0)
		]
	}
        
	static func getBoardLabels() -> [Any] {
		var labels: [String] = []
		
		for type in [Key.daily, Key.simple, Key.common, Key.tricky] {
			for i in 1...solveBoardCount(type) {
				labels.append("\(type.rawValue) \(i)")
			}
			if type != .daily {
				labels.append("\(type.rawValue) ?")
			}
		}
		
		return labels
	}
	
	static func getSolves() -> [Bool] {
		var solves: [Bool] = []
		
		for type in [Key.daily, Key.simple, Key.common, Key.tricky] {
			for solved in Storage.array(type) as? [Bool] ?? [] {
				solves.append(solved)
			}
			if type != .daily {
				solves.append(false)
			}
		}
		
		return solves
	}
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView()
    }
}
