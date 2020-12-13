//
//  SettingsView.swift
//  qubic
//
//  Created by 4 on 7/30/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var mainButtonAction: () -> Void
    @State var dots = [UserDefaults.standard.integer(forKey: dotKey)]
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                Text("settings")
            }
            .buttonStyle(MoreStyle())
            Fill(20)
            HPicker(text: [["cubes","spheres","points","blanks","spaces"]], dim: (100,50), selected: $dots, action: setDots)
            Spacer()
        }
        .background(Fill())
    }
    
    func setDots(row: Int, component: Int) -> Void {
        UserDefaults.standard.setValue(row, forKey: dotKey)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView() {}
    }
}
