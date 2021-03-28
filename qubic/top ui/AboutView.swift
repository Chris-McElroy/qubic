//
//  AboutView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @Binding var view: ViewStates
    var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                Fill().frame(height: moreButtonHeight)
                Button(action: mainButtonAction) {
                    Text("about")
                }
                .buttonStyle(MoreStyle())
            }.zIndex(4)
            if view == .about {
                VStack(spacing: 20) {
                    LinkView(site: "https://en.wikipedia.org/wiki/3D_tic-tac-toe", text: "about qubic")
                    LinkView(site: "https://xno.store/about", text: "about me")
                    LinkView(site: "https://xno.store/contact", text: "contact me")
                    LinkView(site: "http://xno.store/privacy-policy", text: "privacy policy")
                    Text("©2021 XNO LLC")
                }.zIndex(2)
            }
            Spacer()
        }
        .background(Fill())
    }
    
    struct LinkView: View {
        let site: String
        let text: String
        
        var body: some View {
            Button(action: {
                if let url = URL(string: site) {
                   UIApplication.shared.open(url)
               }
            }) {
                Text(text).accentColor(.blue)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(view: .constant(.about)) {}
    }
}
