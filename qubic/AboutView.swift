//
//  AboutView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                Text("about")
            }
            .buttonStyle(MoreStyle())
            Fill().frame(height: 10)
            Text("about qubic")
            Text("about me")
            Text("contact me")
            Text("privacy policy")
            Text("©2020 XNO LLC")
            Spacer()
        }
        .background(Fill())
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView() {}
    }
}
