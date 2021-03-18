//
//  TrainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct TrainView: View {
    @Binding var view: ViewStates
    @State var selected: [Int] = [UserDefaults.standard.integer(forKey: lastTrainKey),1,0]
    let game: Game
    let beaten = UserDefaults.standard.array(forKey: trainKey) as? [Int] ?? [0,0,0,0,0,0]
    
    var body: some View {
        if view == .train {
            GameView(game: game)
                .onAppear { game.load(mode: mode, turn: turn, hints: hints) }
        } else if view == .trainMenu {
            VStack(spacing: 0) {
                Spacer()
                HPicker(content: pickerText, dim: (90, 55), selected: $selected, action: onSelection)
                    .frame(height: 180)
                    .opacity(view == .trainMenu ? 1 : 0)
            }
        }
    }
    
    func onSelection(row: Int, component: Int) {
        if component == 2 {
            UserDefaults.standard.setValue(row, forKey: lastTrainKey)
        }
    }
    
    var pickerText: [[(String, Bool)]] {
        [[("novice",    beaten[0] == 1),
          ("defender",  beaten[1] == 1),
          ("warrior",   beaten[2] == 1),
          ("tyrant",    beaten[3] == 1),
          ("oracle",    beaten[4] == 1),
          ("cubist",    beaten[5] == 1)],
         [("first", false),("random", false),("second", false)],
         [("sandbox", false),("challenge", false)]]
    }
    
    var mode: GameMode {
        switch selected[0] {
        case 0: return .novice
        case 1: return .defender
        case 2: return .warrior
        case 3: return .tyrant
        case 4: return .oracle
        default: return .cubist
        }
    }
    
    var turn: Int {
        switch selected[1] {
        case 0: return 0
        case 2: return 1
        default: return Int.random(in: 0...1)
        }
    }
    
    var hints: Bool {
        selected[2] == 0
    }
    
//    var difficultyPicker: some View {
//        HStack {
//            Image("pinkCube")
//                .resizable()
//                .frame(width: 40, height: 40)
//        }
//    }
//
//    var boardPicker: some View {
//        Text("Beginner")
//            .foregroundColor(.white)
//            .frame(width: 160, height: 40)
//            .background(Rectangle().foregroundColor(.red))
//            .cornerRadius(100)
//    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        TrainView(view: .constant(.solveMenu), game: Game())
    }
}