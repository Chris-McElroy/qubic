//
//  PlayView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct PlayView: View {
    @State var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                primaryLabel(name: "play")
            }
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView() {}
    }
}
