//
//  TutorialView.swift
//  qubic
//
//  Created by Chris McElroy on 10/18/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

struct TutorialButton: View {
	var body: some View {
		VStack(spacing: 0) {
			Button(action: {
				// start tutorial
				print("starting tutorial!")
			}) {
				Text("tutorial")
			}
			.buttonStyle(MoreStyle())
			Spacer()
		}
	}
}

