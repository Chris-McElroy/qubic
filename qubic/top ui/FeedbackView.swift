//
//  FeedbackView.swift
//  qubic
//
//  Created by Chris McElroy on 4/21/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    var mainButtonAction: () -> Void
    @ObservedObject var layout = Layout.main
    @State var text = "enter feedback"
    
    var body: some View {
        VStack {
            ZStack {
                Fill().frame(height: moreButtonHeight)
                Button("feedback", action: mainButtonAction)
                    .buttonStyle(MoreStyle())
            }.zIndex(4)
            if layout.view == .feedback {
                Text("your name (optional)")
                TextField("enter name", text: $text)
                Text("your email (optional—for replies)")
                TextField("enter email", text: $text)
                    .lineLimit(5)
                Text("your feedback")
                if #available(iOS 14.0, *) {
                    TextEditor(text: $text)
                } else {
                    // what the fuck i'm going to have to use some really jank ass shit
                    // https://www.appcoda.com/swiftui-textview-uiviewrepresentable/
                }
            }
        }
    }
}
