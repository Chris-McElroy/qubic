//
//  TipView.swift
//  qubic
//
//  Created by Chris McElroy on 4/8/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import SwiftUI

struct TipView: View {
	@ObservedObject var layout = Layout.main
	@ObservedObject var tipStatus = TipStatus.main
	
	var body: some View {
		VStack(spacing: 0) {
			VStack(spacing: 0) {
				Text(tipStatus.text).padding(20)
				Button("dismiss") { withAnimation(.easeIn(duration: 2.5)) { tipStatus.displayed = false } }
				Blank(20)
			}
			.buttonStyle(Solid())
			.multilineTextAlignment(.center)
			.frame(width: max(layout.width - 20, 100))
			.background(Fill())
			.cornerRadius(20)
			.shadow(radius: 15)
			.offset(y: tipStatus.displayed ? 0 : -500)
			Spacer()
		}.frame(height: layout.safeHeight)
	}
}

class TipStatus: ObservableObject {
	static var main = TipStatus()
	
	@Published var text = "wofjie"
	@Published var displayed: Bool = false
	@Published var tipsOn: Bool = Storage.int(.tipsOn) == 1
	
	enum Tip {
		case none, more, start, sandbox, trainAIs, forcing, daily, simple, common, tricky, random, online, local, invite, bots, timing, settings
	}
	
	init() {
		updateRemainingTips()
	}
	
	var remainingTips: [ViewState: [Tip]] = [:]
	
	static let startingTips: [ViewState: [Tip]] = [
		.main: [.none, .none, .none, .more],
		.playMenu: [.none, .online, .none, .local, .invite, .bots, .timing],
		.solveMenu: [.none, .forcing, .none, .daily, .simple, .common, .tricky, .none, .random],
		.trainMenu: [.none, .sandbox, .trainAIs],
		.settings: [.settings],
		.play: [.start]
	]
	
	func updateRemainingTips() {
		guard let tipsShownArray = Storage.array(.tipsShown) as? [Int] else { return }
		
		remainingTips = TipStatus.startingTips
		
		for (view, tips) in remainingTips {
			remainingTips[view]?.removeFirst(min(tipsShownArray[TipStatus.viewStateMap[view] ?? 0], tips.count))
		}
	}
	
	static let viewStateMap: [ViewState: Int] = [
		.main: 0,
		.playMenu: 1,
		.solveMenu: 2,
		.trainMenu: 3,
		.settings: 4,
		.play: 5
	]
	
	static let tipOptions: [Tip: String] = [
		.more: "tap the more button at the bottom to learn more about the app, change your settings, replay the tutorial, or submit feedback!",
		.start: "tap the start button to start a game!",
		.sandbox: "sandbox mode lets you undo moves and view analysis while playing. challenge mode removes these supports so you can test yourself. beating training opponents in challenge mode will underline their name and unlock features!",
		.trainAIs: "training opponents play very differently, and roughly increase in difficulty from novice to cubist. even cubist can still be beaten moving first or second!",
		.forcing: "solve boards can all be solved with a forcing sequence. that is, every move you make is either a check (3 in a row) or a 4 in a row—your opponent is never free to move where they want. that is not the only way to solve these puzzles, though!",
		.daily: "every day, you'll have 4 new daily boards to solve. each daily n puzzle can be solved in n moves (1-4). the number below daily tracks your current streak!",
		.simple: "simple boards are an introduction to puzzle solving, slowly advancing from 2 move wins (checkmates) to longer sequences of up to 5 moves",
		.common: "common boards reflect common situations that would come up in a game. the first 12 are triangle setups, in which you have 3 moves in one plane that can be used to win by force in that plane. the last 12 are common opening situations that are worth preparing for. these are not very easy to solve!",
		.tricky: "tricky boards are meant primarily as puzzles. they often require long sequences of checks, with many possible dead ends. stay patient and keep exploring new options!",
		.random: "? boards are generated fresh each time you play them. each one is a random inversion of one of the puzzles in that category. this way you can revisit the same ideas after solving all the puzzles of one type!",
		.online: "online games match you up against anyone else using the app. let’s see what you've got!",
		.local: "local games are played on a single device. you can use these to play someone in person, or to test out new strategies!",
		.invite: "invite games are played over iMessage. you can use them to play asynchronous games with friends who have qubic!",
		.bots: "bots are always available to play, even if you're not connected to the internet or no one else is online. select bots to play one immediately. select auto to play with a bot if a match isn’t found immediately. select humans to wait until another player using the app tries to start an online game as well. bots’ names always have corners, while humans’ names are always rounded on the side.",
		.timing: "each game, you can choose what time limit you want for each side. simply pick an option—unlimited, 1 min, 5 min, or 10 min, and both sides will have that much time total to move in the game.",
		.settings: "you can change your name, color, and other settings here. you can learn more about each setting by tapping the ⓘ buttons!"
	]
	
	func updateTip(for view: ViewState) {
		guard tipsOn else { return }
		
		guard var tipsShownArray = Storage.array(.tipsShown) as? [Int] else { return }
		guard let viewNum = TipStatus.viewStateMap[view] else { return }
		tipsShownArray[viewNum] += 1
		Storage.set(tipsShownArray, for: .tipsShown)
		
		guard let tip = remainingTips[view]?.first else { return }
		
		remainingTips[view]?.removeFirst()
		
		if (view == .trainMenu || view == .solveMenu || view == .playMenu) && tipsShownArray[viewNum] == 1 {
			updateTip(for: .play)
			return
		}
		
		if tip != .none {
			text = TipStatus.tipOptions[tip] ?? ""
			Timer.after(0.3) {
				withAnimation(.easeOut(duration: 0.5)) {
					self.displayed = true
				}
			}
		}
	}
}
