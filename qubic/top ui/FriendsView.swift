//
//  FriendsView.swift
//  qubic
//
//  Created by 4 on 8/4/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct FriendsView: View {
	@ObservedObject var layout = Layout.main
    
    var body: some View {
        VStack {
			Button("friends") { layout.change(to: .about) }
				.buttonStyle(MoreStyle())
				.zIndex(10)
            Spacer()
            Fill().frame(height: 10)
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
        FriendsView()
    }
}
