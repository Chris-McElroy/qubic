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

func deeplink(to url: URL) {
	guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else { return }
	guard url.lastPathComponent == "share" else { return }
	guard queryItems.count >= 2 else { return }
	guard queryItems[0].name == "u" else { return }
	guard queryItems[1].name == "g" else { return }
	
	let userID = queryItems[0].value ?? ""
	let gameID = Int(queryItems[1].value ?? "") ?? 0
	var movesIn: Int? = nil
	
	if queryItems.count == 3 && queryItems[2].name == "m" {
		movesIn = Int(queryItems[2].value ?? "")
	}
	
	// TODO catch whether they're in a game currently, and if they are, offer to open the shared game or keep the current one
	// this should appear as a little thing that comes up from the bottom in-game, not an alert, with little yes or no buttons
	
	// TODO this should be working, fucking try it out
	
	// TODO double check that moves in (including as nil) is working as expected
	
	FB.main.getPastGame(userID: userID, gameID: gameID, completion: { gameData in
		let opData = FB.main.playerDict[userID] ?? FB.PlayerData(id: "error", name: "unknown", color: 4)
		ShareGame().load(from: gameData, opData: opData, movesIn: movesIn)
	})
}

fileprivate func presentShareSheet(for url: URL) {
	let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
	UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}
