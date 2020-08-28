//
//  PlayView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct PlayView: View {
    @Binding var view: ViewStates
    
    var body: some View {
        VStack {
            if view == .play {
                Spacer()
                GameView().frame(height: 700)
                Spacer()
            }
            Spacer()
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(view: .constant(.main))
    }
}
