//
//  SolveView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

let solveButtonsEnabled = true

struct SolveView: View {
    @ObservedObject var layout = Layout.main
    @State var selected: [Int] = [0,0]
    var mode: GameMode {
        switch selected[1] {
        case 0: return .daily
        case 1: return .simple
        case 2: return .common
        default: return .tricky
        }
    }
    var boardNum: Int {
        switch selected[1] {
        case 0: return selected[0] - 0
        case 1: return selected[0] - 1
        case 2: return selected[0] - (simpleBoards.count + 2)
        default: return selected[0] - (simpleBoards.count + commonBoards.count + 3)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if layout.current == .solve {
                GameView()
                    .onAppear { Game.main.load(mode: mode, boardNum: boardNum) }
            } else if layout.current == .solveMenu {
                HPicker(content: .constant(getPickerText()), dim: (90, 40), selected: $selected, action: hPickerAction)
                    .frame(height: 80)
                    .opacity(layout.current == .solveMenu ? 1 : 0)
                Blank(3)
            }
        }
    }
    
    func hPickerAction(row: Int, component: Int) {
        if component == 1 {
            switch row {
            case 0: selected[0] = 0; break
            case 1: selected[0] = 1 + firstSimple; break
            case 2: selected[0] = simpleBoards.count + 2 + firstCommon; break
            default: selected[0] = simpleBoards.count + commonBoards.count + 3 + firstTricky; break
            }
        } else {
            if row < 1 { selected[1] = 0 }
            else if row < simpleBoards.count + 2 { selected[1] = 1 }
            else if row < simpleBoards.count + commonBoards.count + 3 { selected[1] = 2 }
            else { selected[1] = 3 }
        }
    }
    
    var firstSimple: Int {
        let simple = Storage.array(.simple) as? [Int] ?? [0]
        return simple.enumerated().first(where: { $0.element == 0 })?.offset ?? simple.count
    }
    
    var firstCommon: Int {
        let common = Storage.array(.common) as? [Int] ?? [0]
        return common.enumerated().first(where: { $0.element == 0 })?.offset ?? common.count
    }
    
    var firstTricky: Int {
        let tricky = Storage.array(.tricky) as? [Int] ?? [0]
        return tricky.enumerated().first(where: { $0.element == 0 })?.offset ?? tricky.count
    }
    
    
    // TODO make this a state var so that you can update it when the day changes etc
    func getPickerText() -> [[Any]] {
        let streak = getStreakView
        let simple = getSimpleView
        let common = getCommonView
        let tricky = getTrickyView
        var boardNames = getDailyNames()
        boardNames += getSimpleNames()
        boardNames += getCommonNames()
        boardNames += getTrickyNames()
        return [boardNames, [streak, simple, common, tricky]]
    }
    
    func getStreakView() -> UIView {
        Notifications.setBadge(justSolved: false)
        let streak = Storage.int(.streak)
        return getLabel(for: "daily\n\(streak)")
        
    //    if text.contains("\n") {
    //    } else {
    //        if solveMode(is: "daily") { text = row == 0 ? getDateText() : "" }
        
//        if lastDC >= Date().getInt() - 1 && streak > 0 {
//            streak = "streak: \(streak)"
//        } else {
//            streakText = ""
//            Storage.set(0, for: .DCStreak)
//        }
    }
    
    func getSimpleView() -> UIView {
        let simple = Storage.array(.simple) as? [Int] ?? [0]
        return getLabel(for: "simple\n\(simple.sum())")
    }
    
    func getCommonView() -> UIView {
        let common = Storage.array(.common) as? [Int] ?? [0]
        return getLabel(for: "common\n\(common.sum())")
    }
    
    func getTrickyView() -> UIView {
        let tricky = Storage.array(.tricky) as? [Int] ?? [0]
        return getLabel(for: "tricky\n\(tricky.sum())")
    }
    
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
    
    func getDailyNames() -> [(String, Bool)] {
        let format = DateFormatter()
        format.dateStyle = .short
        let solved = Date().getInt() == Storage.int(.lastDC)
        return [(format.string(from: Date()), solved)]
    }
    
    func getSimpleNames() -> [(String, Bool)] {
        guard let solves = Storage.array(.simple) as? [Int] else {
            return []
        }
        var boardArray: [(String, Bool)] = []
        for (i, solved) in solves.enumerated() {
            boardArray.append(("simple \(i+1)",solved == 1))
        }
        boardArray.append(("simple ?", false))
        return boardArray
    }
    
    func getCommonNames() -> [(String, Bool)] {
        guard let solves = Storage.array(.common) as? [Int] else {
            return []
        }
        var boardArray: [(String, Bool)] = []
        for (i, solved) in solves.enumerated() {
            boardArray.append(("common \(i+1)",solved == 1))
        }
        boardArray.append(("common ?", false))
        return boardArray
    }
    
    func getTrickyNames() -> [(String, Bool)] {
        guard let solves = Storage.array(.tricky) as? [Int] else {
            return []
        }
        var boardArray: [(String, Bool)] = []
        for (i, solved) in solves.enumerated() {
            boardArray.append(("tricky \(i+1)",solved == 1))
        }
        boardArray.append(("tricky ?", false))
        return boardArray
    }
    
//    var difficultyPicker: some View {
//        HStack {
//            Text(String(streak))
//            Image("pinkCube")
//                .resizable()
//                .frame(width: 40, height: 40)
//        }
//    }
    
//    var boardOptions: [UIView] { [UIName(text: getDateString(), color: .purple, action: nil), UIName(text: "hard board", color: .blue, action: nil)] }
    
//    var boardPicker: some View {
//        HPicker(text: (0...30).map { String($0) }).frame(height: 40)
//        Picker("boards", selection: $selected) {
//            Text("this2").font(.system(size: 100))
//                .frame(width: 40, height: 160, alignment: .center)
//                .rotationEffect(.degrees(90))
//            Text("this1")
//                .frame(width: 40, height: 160, alignment: .center)
//                .rotationEffect(.degrees(90))
//            HStack {
//                Spacer(minLength: nameButtonWidth*(1-selected))
//                Name(text: getDateString(), color: .purple) { select(0) }
//                Name(text: "hard board", color: .blue) { select(1) }
//                Spacer(minLength: nameButtonWidth*selected)
//            }.frame(alignment: .center)
//        }.pickerStyle(InlinePickerStyle())
//        .rotationEffect(.degrees(-90))
//        .frame(width: 300, height: 40)
//
//    }
//
//    func select(_ n: Int) {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            type = n
//        }
//    }
    
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView()
    }
}
