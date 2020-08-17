//
//  SolveView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SolveView: View {
    @State var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                Text("solve")
            }
            .buttonStyle(MainStyle())
        }
    }
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView() {}
    }
}
