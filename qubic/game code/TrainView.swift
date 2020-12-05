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
    var switchBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if view == .train {
                GameView() { self.switchBack() }
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    difficultyPicker
                    Fill(5)
                    boardPicker
                }.opacity(view == .trainMenu ? 1 : 0)
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
        TrainView(view: .constant(.solveMenu)) {}
    }
}
