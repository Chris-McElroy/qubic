//
//  AboutView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @State var mainButtonAction: () -> Void
    
    var body: some View {
        Button(action: mainButtonAction) {
            secondaryLabel(name: "about")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView() {}
    }
}
