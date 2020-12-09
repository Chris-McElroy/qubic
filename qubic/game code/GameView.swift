//
//  GameView.swift
//  qubic
//
//  Created by 4 on 8/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct GameView: View {
    @ObservedObject var data: GameData = GameData()
    var switchBack: () -> Void = { return }
    let boardRep: BoardViewRep
    @State var cubeHeight: CGFloat = 10
    @State var rotateMe = false
    @State var isRotated = false
    @State var cont = false
    
    init(_ switchBackFunc: @escaping () -> Void) {
        switchBack = switchBackFunc
        boardRep = BoardViewRep()
        let newData = GameData(preset: [], dc: false)
        data = newData
        boardRep.load(newData)
    }
    
    init(_ preset: [Int], dc: Bool, _ switchBackFunc: @escaping () -> Void) {
        switchBack = switchBackFunc
        boardRep = BoardViewRep()
        let newData = GameData(preset: preset, dc: dc)
        data = newData
        boardRep.load(newData)
    }
    
    var body: some View {
//        VStack(spacing: 20) {
//            // 1
//            Button("Rotate") {
//                self.isRotated = true
//                print(cont)
//                self.cont.toggle()
//            }
//            // 2
//            Rectangle()
//                .foregroundColor(.green)
//                .frame(width: 200, height: 200)
//                .rotationEffect(Angle.degrees(isRotated && cont ? 360 : 0))
//                .animation(cont ? animation : .default)
//        }
        
        VStack(spacing: 0) {
            Fill(4)
            Text("other")
                .foregroundColor(.white)
                .frame(width: 160, height: 40)
                .background(Rectangle().foregroundColor(Color(UIColor.magenta)))
                .cornerRadius(100)
            boardRep
                .gesture(DragGesture()
                    .onEnded { drag in
                        let h = drag.predictedEndTranslation.height
                        let w = drag.predictedEndTranslation.width
                        if abs(w)/abs(h) > 1 {
                            self.boardRep.rotate(right: w > 0)
                        } else if h > 0 {
                            self.switchBack()
                        }
                    }
                )
            Text("chris")
                .foregroundColor(.white)
                .frame(width: 160, height: 40)
                .background(Rectangle().foregroundColor(.blue))
                .cornerRadius(100)
        }
    }
    
    var animation = Animation.linear.delay(0)
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView([3], dc: false) {}
    }
}
