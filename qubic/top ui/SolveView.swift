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
    @State var menuText: [[Any]] = getMenuText()
    @State var menuUpdateTimer: Timer?
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            if layout.current == .solve {
                GameView()
                    .onAppear { Game.main.load(mode: mode, boardNum: boardNum) }
            } else if layout.current == .solveMenu {
                HPicker(content: $menuText, dim: (100, 40), selected: $layout.solveSelection, action: onSelection)
					.frame(height: 80)
                    .opacity(layout.current == .solveMenu ? 1 : 0)
                    .onAppear { refreshMenu() }
                Blank(3)
            }
        }
        .onAppear { refreshMenu() }
    }
    
    func refreshMenu() {
        menuText = SolveView.getMenuText()
        updateDailyData()
        let delay = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)).timeIntervalSinceNow
        menuUpdateTimer?.invalidate()
        menuUpdateTimer = Timer.after(delay, run: {
            menuText = SolveView.getMenuText()
			updateDailyData()
        })
    }
    
    func onSelection(row: Int, component: Int) {
        if component == 1 {
            switch row {
            case 0: layout.solveSelection[0] = firstBoard(of: .daily)
            case 1: layout.solveSelection[0] = solveBoardCount(.daily) + firstBoard(of: .simple)
            case 2: layout.solveSelection[0] = solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + firstBoard(of: .common)
            case 3: layout.solveSelection[0] = solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + (solveBoardCount(.common) + 1) + firstBoard(of: .tricky)
			default: break
            }
        } else {
            if row < solveBoardCount(.daily) { layout.solveSelection[1] = 0 }
            else if row < solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) { layout.solveSelection[1] = 1 }
            else if row < solveBoardCount(.daily) + (solveBoardCount(.simple) + 1) + (solveBoardCount(.common) + 1) { layout.solveSelection[1] = 2 }
            else { layout.solveSelection[1] = 3 }
        }
    }
    
    func firstBoard(of type: Key) -> Int {
        let list = Storage.array(type) as? [Bool] ?? []
		return list.enumerated().first(where: { !$0.element })?.offset ?? (type == .daily ? 0 : list.count)
    }
    
    static func getMenuText() -> [[Any]] {
        func getLabel(text: String, type: Key) -> [() -> UIView] {
            func getLabel(for string: String) -> UILabel {
                let label = UILabel()
                let loc = NSString(string: string).range(of: "\n").location
                let text = NSMutableAttributedString.init(string: string)
                text.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                    NSAttributedString.Key.foregroundColor: UIColor.gray],
                                   range: NSRange(location: loc, length: string.count-loc))
                label.attributedText = text
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                label.textAlignment = .center
                label.transform = CGAffineTransform(rotationAngle: .pi/2)
                return label
            }
            
            let sum: Int
            if type == .daily { sum = Storage.int(.streak) }
            else { sum = (Storage.array(type) as? [Int])?.reduce(0, { $0 + ($1 == 0 ? 0 : 1) }) ?? 0 }
            return [{ getLabel(for: "\(text)\n\(sum)") }]
        }
        
        func getNames(text: String, type: Key) -> [(String, Bool)] {
			guard let solves = Storage.array(type) as? [Bool] else {
                return []
            }
            var boardArray: [(String, Bool)] = []
			for (i, solved) in solves.enumerated() { // where i < solveBoardDates[type]?.count ?? 4 { consider adding this back in if i need it
				boardArray.append(("\(text) \(i+1)", solved)) // type == .daily ? solves.contains(board) : Int(board) == Date.int
            }
            if type != .daily {
                boardArray.append(("\(text) ?", false))
            }
            return boardArray
        }
        
        var labels = getLabel(text: "daily",  type: .daily)
        labels +=    getLabel(text: "simple", type: .simple)
		labels +=    getLabel(text: "common", type: .common)
		labels +=    getLabel(text: "tricky", type: .tricky)
		
		var boards = getNames(text: "daily",  type: .daily)
        boards +=    getNames(text: "simple", type: .simple)
        boards +=    getNames(text: "common", type: .common)
        boards +=    getNames(text: "tricky", type: .tricky)
		
        return [boards, labels]
    }
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView()
    }
}
