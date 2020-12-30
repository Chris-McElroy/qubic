//
//  SolveView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SolveView: View {
    @Binding var view: ViewStates
    @State var selected: [Int] = [0,0]
    let game: Game
    var mode: GameMode {
        switch selected[1] {
        case 1: return .tricky
        default: return .daily
        }
    }
    var boardNum: Int { selected[0]-[0,1][selected[1]] }
    
    var body: some View {
        VStack(spacing: 0) {
            if view == .solve {
                GameView(game: game)
                    .onAppear { game.load(mode: mode, boardNum: boardNum) }
            } else if view == .solveMenu {
                HPicker(content: getPickerText(), dim: (90, 40), selected: $selected, action: hPickerAction)
                    .frame(height: 80)
                    .opacity(view == .solveMenu ? 1 : 0)
                Blank(3)
            }
        }
    }
    
    func hPickerAction(row: Int, component: Int) {
        if component == 1 {
            selected[0] = [0,1][row]
        } else {
            selected[1] = [0,1][row]
        }
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
    
    func getPickerText() -> [[Any]] {
        let streak = getStreakView
        let tricky = getTrickyView
        let dailyBoard = getDailyBoard()
        let trickyBoards = getTrickyBoards()
        return [dailyBoard + trickyBoards,[streak,tricky]]
    }
    
    func getStreakView() -> UIView {
        Notifications.setBadge(justSolved: false)
        let streak = UserDefaults.standard.integer(forKey: streakKey)
        return getLabel(for: "daily\n\(streak)")
        
    //    if text.contains("\n") {
    //    } else {
    //        if solveMode(is: "daily") { text = row == 0 ? getDateText() : "" }
        
//        if lastDC >= Date().getInt() - 1 && streak > 0 {
//            streak = "streak: \(streak)"
//        } else {
//            streakText = ""
//            UserDefaults.standard.setValue(0, forKey: DCStreakKey)
//        }
    }
    
    func getTrickyView() -> UIView {
        let tricky = UserDefaults.standard.array(forKey: trickyKey) as? [Int] ?? [0]
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
    
    func getDailyBoard() -> [(String, Bool)] {
        let format = DateFormatter()
        format.dateStyle = .short
        let solved = Date().getInt() == UserDefaults.standard.integer(forKey: lastDCKey)
        return [(format.string(from: Date()), solved)]
    }
    
    func getTrickyBoards() -> [(String, Bool)] {
        var boardArray: [(String, Bool)] = []
        guard let trickyBoards = UserDefaults.standard.array(forKey: trickyKey) as? [Int] else {
            return []
        }
        for (i, solved) in trickyBoards.enumerated() {
            boardArray.append(("tricky \(i+1)",solved == 1))
        }
        return boardArray
    }
    
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView(view: .constant(.solveMenu), game: Game())
    }
}
