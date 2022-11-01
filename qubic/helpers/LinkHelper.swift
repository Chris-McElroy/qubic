//
//  LinkHelper.swift
//  qubic
//
//  Created by Chris McElroy on 9/16/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

struct ShareButton: View {
	let playerID: String
	let gameID: String
	let movesIn: String?
	
	init() {
		playerID = game.player[game.myTurn].id
		gameID = String(game.gameID)
		movesIn = game.movesBack != 0 ? String(game.moves.count - game.movesBack) : nil
	}
	
	init(playerID: String, gameID: String, movesIn: String? = nil) {
		self.playerID = playerID
		self.gameID = gameID
		self.movesIn = movesIn
	}
	
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
	
	func getURL() -> URL? {
		let movesPart = movesIn != nil ? "&m=" + (movesIn ?? "") : ""
		return URL(string: "https://xno.store/share?u=" + playerID + "&g=" + gameID + movesPart)
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
	
	FB.main.getPastGame(userID: userID, gameID: gameID, completion: { gameData in
		let myData = FB.main.getPlayerData(for: userID)
		let opData = FB.main.getPlayerData(for: gameData.opID)
		
		// TODO if it's in the tutorial, don't let them leave
		
		if Layout.main.currentGame != .none {
			GameLayout.main.deepLinkAction = {
				Layout.main.currentGame = .share
				ShareGame().load(from: gameData, myData: myData, opData: opData, movesIn: movesIn)
			}
			GameLayout.main.setPopups(to: .deepLink)
		} else {
			Layout.main.currentGame = .share
			ShareGame().load(from: gameData, myData: myData, opData: opData, movesIn: movesIn)
		}
	})
}

fileprivate func presentShareSheet(for url: URL) {
	let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
	UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}
