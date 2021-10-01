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
	let color: UIColor
	let size: UIActivityIndicatorView.Style
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
		activityIndicator.color = color
        activityIndicator.style = size
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
