//
//  ActivityIndicator.swift
//  qubic
//
//  Created by Chris McElroy on 4/4/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
//    @Binding var shouldAnimate: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .white
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
//        uiView.sizeThatFits(CGSize(width: 100, height: 100))
//        if self.shouldAnimate {
//            uiView.startAnimating()
//        } else {
//            uiView.stopAnimating()
//        }
    }
}
