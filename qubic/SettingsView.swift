//
//  SettingsView.swift
//  qubic
//
//  Created by 4 on 7/30/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State var mainButtonAction: () -> Void
    @State var sup: Bool = false
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                Text("settings")
            }
            .buttonStyle(MoreStyle())
            Spacer()
            Toggle("this", isOn: $sup)
                .padding()
            Spacer()
        }
        .background(Fill())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView() {}
    }
}
