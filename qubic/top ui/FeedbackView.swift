//
//  FeedbackView.swift
//  qubic
//
//  Created by Chris McElroy on 4/21/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    @ObservedObject var layout = Layout.main
    @State var name = ""
    @State var email = ""
    @State var feedback = ""
    @State var sendLabel = "send"
    
    var body: some View {
		VStack(spacing: 0) {
			ZStack {
				Fill().frame(height: moreButtonHeight)
				Button("feedback") {
					layout.change(to: .feedback)
				}
				.buttonStyle(MoreStyle())
			}
			.zIndex(4)
            if layout.current == .feedback {
                if #available(iOS 14.0, *) {
                    Spacer()
                    Blank(5)
                }
                VStack(spacing: 5) {
                    Text("your name (optional)")
                    TextField("enter name", text: $name)
                        .multilineTextAlignment(.center)
                        .autocapitalization(.words)
                    Text("your email (optional—for replies)")
                    TextField("enter email", text: $email)
                        .multilineTextAlignment(.center)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    Text("your feedback or ideas")
                    VStack {
                        if #available(iOS 14.0, *) {
                            TextEditor(text: $feedback)
                        } else {
                            OldTextEditor(text: $feedback, textStyle: UIFont.TextStyle.body)
                        }
                    }
                    .frame(maxWidth: 300, maxHeight: min(layout.feedbackTextSize, 300))
                    .padding(10)
                    .border(Color.primary)
                    .padding(.horizontal, 20)
                }
				.modifier(BoundSize(min: .medium, max: .extraExtraLarge))
                Blank(10)
                Button(sendLabel) {
                    hideKeyboard()
                    if feedback != "" {
                        FB.main.postFeedback(name: name, email: email, feedback: feedback)
                        sendLabel = "thanks for your feedback!"
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
                            self.sendLabel = "send"
                        })
                    }
                    name = ""
                    email = ""
                    feedback = ""
                }
                Blank(15)
                LinkView(site: "mailto:chris@xno.store", text: "send as email\n(for attachments)")
                    .multilineTextAlignment(.center)
                if #available(iOS 14.0, *) {
                    Blank(layout.feedbackSpacerSize)
                } else {
                    Spacer()
                }
            }
        }.background(Fill().onTapGesture {
            hideKeyboard()
        })
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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
