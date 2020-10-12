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
    var switchBack: () -> Void
//    @State var preset: [Int] = allPresets.randomElement() ?? []
    let allPresets = [[0,3,2],[3,5,32],[24,23,34,12,14,15]]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            difficultyPicker
            Fill(5)
            boardPicker
            if view == .solve {
                GameView(getSolveBoard()) { self.switchBack() }
            }
            Fill(5)
        }
    }
    
    var difficultyPicker: some View {
        Image("blueCube")
            .resizable()
            .frame(width: 40, height: 40)
    }
    
    var boardPicker: some View {
        Text("August 22, 2020")
            .foregroundColor(.white)
            .frame(width: 160, height: 40)
            .background(Rectangle().foregroundColor(.purple))
            .cornerRadius(100)
    }
    
    func getSolveBoard() -> [Int] {
        return expandMoves(allSolveBoards.randomElement() ?? "")
    }
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView(view: .constant(.solveMenu)) {}
    }
}
