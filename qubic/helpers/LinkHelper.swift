//
//  LinkHelper.swift
//  qubic
//
//  Created by Chris McElroy on 9/16/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

struct ShareButton: View {
	var body: some View {
		if let url = getURL() {
			if #available(iOS 16.0, *) {
				ShareLink(item: url) {
					Text("share")
				}
			} else {
				Button("share") {
					presentShareSheet(for: url)
				}
			}
		}
	}
	
	// TODO oh shit this should be available anytime a game is being reviewed
	// todo button aint showin up?
	
	func getURL() -> URL? {
		let playerID = game.player[game.myTurn].id
		let gameID = String(game.gameID)
		let movesIn = String(game.moves.count - game.movesBack)
		
		return URL(string: "https://xno.store/share?u=" + playerID + "&g=" + gameID + "&m=" + movesIn)
	}
}

fileprivate func presentShareSheet(for url: URL) {
	let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
	UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}
