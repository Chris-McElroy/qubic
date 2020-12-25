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
    @State var selected: [Int] = [0,1,0]
    let board: BoardScene
    
    let pickerText = [[("sandbox", false),("challenge", false)],
                      [("first", false),("random", false),("second", false)],
                      [("beginner", UserDefaults.standard.integer(forKey: beginnerKey) == 1),
                       ("defender", UserDefaults.standard.integer(forKey: defenderKey) == 1),
                       ("cubist", UserDefaults.standard.integer(forKey: cubistKey) == 1)]]
    var mode: GameMode {
        switch selected[2] {
        case 0: return .beginner
        case 1: return .defender
//        case 2: return .attacker
//        case 3: return .commander
//        case 4: return .diviner
        case 2: return .cubist
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
    
    var body: some View {
        VStack(spacing: 0) {
            if view == .train {
                GameView(board: board)
                    .onAppear { board.load(GameData(mode: mode, turn: turn)) }
            } else if view == .trainMenu {
                Spacer()
                HPicker(use: .train, content: pickerText, dim: (100, 55), selected: $selected, action: {_,_ in })
                    .frame(height: 180)
                    .opacity(view == .trainMenu ? 1 : 0)
            }
        }
    }
    
    var difficultyPicker: some View {
        HStack {
            Image("pinkCube")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    var boardPicker: some View {
        Text("Beginner")
            .foregroundColor(.white)
            .frame(width: 160, height: 40)
            .background(Rectangle().foregroundColor(.red))
            .cornerRadius(100)
    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        TrainView(view: .constant(.solveMenu), board: BoardScene())
    }
}
