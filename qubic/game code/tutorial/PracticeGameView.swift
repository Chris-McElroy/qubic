//
//  PracticeGameView.swift
//  qubic
//
//  Created by Chris McElroy on 11/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI
import Combine

struct PracticeGameView: View {
	@ObservedObject var game: Game = Game.main
	@ObservedObject var gameLayout: GameLayout = GameLayout.main
	@ObservedObject var layout: Layout = Layout.main
	@ObservedObject var tutorialLayout: TutorialLayout = TutorialLayout.main
	@ObservedObject var controller: PracticeGameController = PracticeGameController.main
	var components = GameViewComponents.self
	
	var body: some View {
		ZStack {
			components.boardView
			components.popupFill
			optionsPopup
			gameEndPopup
			components.analysisPopup
			tutorialPopup
			components.popupMasks
			components.names
			components.gameControls
			nextButton
		}
		.opacity(gameLayout.hideAll ? 0 : 1)
		.gesture(swipe)
		.onAppear {
			controller.lastAnalysisMode = gameLayout.analysisMode
			tutorialLayout.readyToAdvance = false
			tutorialLayout.readyToContinue = true
			TutorialGame().load()
			gameLayout.animateIntro()
			game.timers.append(Timer.after(1.2) {
				gameLayout.setPopups(to: .settings)
			})
		}
		.onReceive(Just(gameLayout.analysisMode), perform: controller.onAnalysisModeChange)
		.modifier(BoundSize(min: .large, max: .extraExtraExtraLarge))
	}
	
	var swipe: some Gesture { DragGesture(minimumDistance: 30)
		.onEnded { drag in
			let h = drag.translation.height
			let w = drag.translation.width
			if abs(w/h) < 1 && BoardScene.main.mostRecentRotate == nil {
				if h > 0 {
					if (gameLayout.popup == .settings || gameLayout.popup == .none) && (controller.step == .swipe1 || controller.step == .swipe2 || controller.step == .swipe3) {
						if controller.step == .swipe1 { controller.step = .analysis1 }
						else if controller.step == .swipe2 { controller.step = .analysis2 }
						else { controller.step = .show }
						tutorialLayout.readyToContinue = true
						gameLayout.setPopups(to: .analysis)
					} else if gameLayout.popup == .options || gameLayout.popup == .gameEnd || gameLayout.popup == .settings {
						if gameLayout.popup == .gameEnd && controller.step == .great {
							game.reviewingGame = true
							tutorialLayout.readyToContinue = true
							controller.step = .post
							gameLayout.setPopups(to: .settings)
						} else {
							gameLayout.hidePopups()
						}
					} else if gameLayout.popup == .none {
						gameLayout.setPopups(to: .analysis)
					}
				} else {
					if gameLayout.popup == .analysis {
						gameLayout.hidePopups()
					} else if gameLayout.popup == .none || gameLayout.popup == .settings && controller.step == .options {
						gameLayout.setPopups(to: .options)
					}
				}
			}
			BoardScene.main.endRotate()
		}
		.onChanged { drag in
			let h = drag.translation.height
			let w = drag.translation.width
			if abs(w/h) > 1 && gameLayout.popup == .none {
				BoardScene.main.rotate(angle: w, start: drag.startLocation)
			}
		}
	}
	
	var nextButton: some View {
		VStack(spacing: 0) {
			Spacer()
			Button(tutorialLayout.readyToContinue || tutorialLayout.readyToAdvance ? "continue" : "next", action: controller.nextAction)
				.opacity(gameLayout.optionsOpacity.rawValue)
				.offset(x: (layout.width - 95)/2 - 15)
				.offset(y: (layout.hasBottomGap ? 5 : -10) - gameLayout.gameControlHeight)
				.buttonStyle(Standard())
		}
	}
	
	var optionsPopup: some View {
		VStack(spacing: 0) {
			Spacer()
			VStack(spacing: 20) {
				Button("tutorial") {
					if controller.step == .analysis1 { controller.step = .block }
					if controller.step == .analysis2 { controller.step = .adv2 }
					gameLayout.setPopups(to: .settings)
				}
				if game.hints || game.solved {
					Button("analysis") {
						gameLayout.setPopups(to: .analysis)
						if controller.step == .swipe1 {
							controller.step = .analysis1
							tutorialLayout.readyToContinue = true
						} else if controller.step == .swipe2 {
							controller.step = .analysis2
							tutorialLayout.readyToContinue = true
						} else if controller.step == .swipe3 {
							
						}
					}
				}
//				Text("game insights")
				if game.reviewingGame {
					newGameButton
					rematchButton
					Button("menu") { tutorialLayout.exitTutorial() }
				} else {
					Button("resign") {}
						.opacity(Opacity.half.rawValue)
				}
			}
			.modifier(Oligopoly(size: 18))
			.buttonStyle(Solid())
			.padding(.top, 20)
			.padding(.bottom, gameLayout.gameControlSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .options ? 0 : 400)
		}
	}
	
	var gameEndPopup: some View {
		var titleText = game.gameState.myWin ? "you won!" : "you lost!"
		if game.gameState == .draw { titleText = "draw" }
		if game.gameState == .error { titleText = "game over" }
		if game.mode == .daily && Storage.int(.lastDC) > game.lastDC { titleText = "\(Storage.int(.streak)) day streak!" }
		
		return VStack(spacing: 0) {
			VStack(spacing: 15) {
				Text(titleText).modifier(Oligopoly(size: 24))
//				Text("a little something about the game")
			}
			.padding(.vertical, 15)
			.padding(.top, gameLayout.nameSpace)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .gameEnd ? 0 : -(130 + gameLayout.nameSpace))
			
			Fill().opacity(gameLayout.popup == .gameEnd ? 0.015 : 0)
				.onTapGesture {
					game.reviewingGame = true
					tutorialLayout.readyToContinue = true
					controller.step = .post
					gameLayout.setPopups(to: .settings)
				}
			
			VStack(spacing: 15) {
				Button("review game") {
					game.reviewingGame = true
					tutorialLayout.readyToContinue = true
					controller.step = .post
					gameLayout.setPopups(to: .settings)
				}
					.modifier(Oligopoly(size: 18))
				Text("great job—they resigned!\nnow you can see what might have happened\npress review game or tap the board to stay in this game")
					.multilineTextAlignment(.center)
					.padding(.horizontal, 10)
			}
			.padding(.top, 15)
			.padding(.bottom, gameLayout.gameControlSpace)
			.buttonStyle(Solid())
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .gameEnd ? 0 : 330)
		}
	}
	
	var rematchButton: some View {
		Button("rematch") {}
			.opacity(Opacity.half.rawValue)
	}
	
	var newGameButton: some View {
		Button("new game") {}
			.opacity(Opacity.half.rawValue)
	}
	
	var tutorialPopup: some View {
		VStack(spacing: 0) {
			Spacer()
			VStack(spacing: 0) {
				Blank(15)
				Text(controller.tutorialText)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 10)
				Blank(10)
				Button("exit tutorial") { tutorialLayout.exitTutorial() }
				.buttonStyle(Standard())
				.offset(x: -((layout.width - 95)/2 - 15))
				Blank(10)
			}
			.padding(.bottom, gameLayout.gameControlSpace - 20)
			.frame(width: layout.width)
			.modifier(PopupModifier())
			.offset(y: gameLayout.popup == .settings ? 0 : 400)
		}
	}
}
