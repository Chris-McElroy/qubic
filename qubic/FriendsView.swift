//
//  FriendsView.swift
//  qubic
//
//  Created by 4 on 8/4/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct FriendsView: View {
    @State var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                Text("friends")
            }
            .buttonStyle(MoreStyle())
            Fill().frame(height: 10)
            Spacer()
            List {
                Text("< a list of my friends >")
                HStack {
                    Text("more Friends").padding()
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
            .padding()
            Spacer()
        }
        .background(Fill())
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView() {}
    }
}
