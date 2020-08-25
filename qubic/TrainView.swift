//
//  TrainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct TrainView: View {
    @State var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer().frame(height: 30)
            Button(action: mainButtonAction) {
                Text("train")
            }
            .buttonStyle(MainStyle())
        }
        .background(Fill())
    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        TrainView() {}
    }
}
