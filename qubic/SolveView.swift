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
    
    var body: some View {
        VStack {
            difficultyPicker //.animation(.none)
            boardPicker // .animation(.none)
            if view == .solve {
                GameView().animation(.linear)
            }
            Button(action: solveAction) {
                Text("solve")
            }
            .buttonStyle(MainStyle())
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
            .padding(.bottom, view == .solveMenu ? 15 : 23)
    }
    
    func solveAction() {
        if view == .solveMenu {
            withAnimation(.easeInOut(duration: 0.4)) {
                view = .solve
            }
        } else {
            withAnimation(.easeInOut(duration: 0.4)) {
                view = .solveMenu
            }
        }
    }
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView(view: .constant(.solveMenu))
    }
}
