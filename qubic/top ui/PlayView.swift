//
//  PlayView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import MessageUI

struct PlayView: View {
    @ObservedObject var layout = Layout.main
    static let onlineTurnText = ["bots", "auto", "humans"]
    static let normalTurnText = ["first", "random", "second"]
    @State var turnText: [Any] = PlayView.onlineTurnText
    @State var tip = tips.randomElement() ?? ""
    
    var body: some View {
        if layout.current == .play {
            GameView()
                .onAppear { Game.main.load(mode: mode, turn: turn, hints: hints, time: time) }
		} else {
			VStack {
				Spacer()
				if layout.current == .playMenu {
					VStack(spacing: 0) {
						Spacer()
						Spacer()
						tipArea
						Spacer()
						
						HPicker(width: 90, height: 42, selection: $layout.playSelection[3], labels: .constant(["sandbox", "challenge"]), onSelection: updateLastPlayMenu)
							.modifier(EnableHPicker(on: mode == .local))
						HPicker(width: 90, height: 42, selection: $layout.playSelection[2], labels: .constant(["untimed", "1 min", "5 min", "10 min"]), onSelection: {
							FB.main.cancelOnlineSearch?()
							updateLastPlayMenu($0)
						})
						.modifier(EnableHPicker(on: mode != .invite))
						HPicker(width: 90, height: 42, selection: $layout.playSelection[1], labels: $turnText, onSelection: { _ in
							FB.main.cancelOnlineSearch?()
						})
						.modifier(EnableHPicker(on: mode != .invite))
						HPicker(width: 90, height: 42, selection: $layout.playSelection[0], labels: .constant(["local", "online", "invite"]), onSelection: { _ in
							FB.main.cancelOnlineSearch?()
							turnText = mode == .online ? PlayView.onlineTurnText : PlayView.normalTurnText
						})
					}.onAppear {
//                		FB.main.finishedOnlineGame(with: .error) // not sure which case this covered
						tip = PlayView.tips.filter({ $0 != tip }).randomElement() ?? ""
						TipStatus.main.updateTip(for: .playMenu)
					}
				}
			}
        }
    }
	
	var tipArea: some View {
		Button(action: { tip = PlayView.tips.filter({ $0 != tip }).randomElement() ?? "" }) {
			VStack(spacing: 0) {
				Text("tip")
					.bold()
					.modifier(Oligopoly(size: 16))
					.padding(.top, 20)
				Fill(3)
				Text(tip)
					.padding(.horizontal, 20)
					.lineLimit(10)
					.multilineTextAlignment(.center)
					.frame(height: 120, alignment: .top)
			}.background(Fill())
		}
		.buttonStyle(Solid())
	}
    
    var mode: GameMode {
        switch layout.playSelection[0] {
        case 0: return .local
        case 1: return .online
        default: return .invite
        }
    }
    
    var time: Double? {
        switch layout.playSelection[2] {
        case 0: return nil
        case 1: return 60
        case 2: return 300
        default: return 600
        }
    }
    
    var turn: Int? {
        if mode == .online { return FB.main.myGameData?.myTurn }
        
        switch layout.playSelection[1] {
        case 0: return 0
        case 2: return 1
        default: return nil
        }
    }
    
    var hints: Bool {
		layout.playSelection[3] == 0 && mode != .online
    }
    
	func updateLastPlayMenu(_: Int) {
        var newPlayMenu = layout.playSelection
        newPlayMenu[0] = 1
        newPlayMenu[1] = 1
        Storage.set(newPlayMenu, for: .lastPlayMenu)
    }
	
	struct EnableHPicker: ViewModifier {
		let on: Bool
		
		func body(content: Content) -> some View {
			ZStack {
				content
				Fill(42)
					.opacity(on ? 0.0 : 0.6)
					.animation(.linear(duration: 0.15))
			}
		}
	}
    
    static let tips: [String] = [
		"swipe down in game for analysis!",
		"you can change your name and color in settings!",
		"your name can include emojis and other i̴͍͈̱̊͐͑n̵̠̍̊̎t̸̹͗̈́͜͝e̸̗̝̻͠r̸̰̀ê̶̼͍s̵̰̯̅̀t̴̢͂̾̎ị̴̏̎n̸̡̨̟̍̐g̶͓̙̺̊̒ characters!",
		"the \"auto\" option will match you with a bot if you don’t match with a human in time!",
		"sandbox mode lets you undo moves and see analysis during the game!",
		"training opponents who you beat in a challenge game will have their name underlined!",
		"you can make hypothetical moves after a game by pressing \"review game\"!",
		"you can swipe down instead of using the back button!",
		"solve boards can always be solved using only checks!",
		"you can use local games in sandbox mode to try out new ideas!",
		"local games let you play against someone on the same device!",
		"invite allows you to send a game you can play over messages!",
		"use the arrows to replay previous moves!",
		"the first player can always win with perfect play!",
		"watch out for sequences of checks your opponent can make!",
		"the 8 corner moves and 8 central moves are the best starting points!",
		"the earliest possible 2nd order win begins on the 4th move!",
		"swipe side to side in game to rotate the board!",
		"if you get the game board off-axis, you can double tap the background to reset it!",
		"when it’s your turn, your name will glow!",
		"if your opponent has your color, their color will appear different for you!",
		"once you beat a solve board, its name will show up underlined!",
		"if you get the menu cube off-axis, you can double tap it to reset it!",
		"you can send feedback by pressing \"back\" then \"more\" then \"feedback\"!",
		"sending feedback will help make the app better!",
		"if you tap this tip a new one will appear!",
		"the board has 76 possible winning lines!",
		"the board has 192 automorphisms (symmetries)!",
		"the board has 18 4x4 planes!",
		"the first player to get 4 in a row wins!",
		"the number under daily is your current streak for solving all the daily challenges!",
		"if you tap on moves they’ll spin around!",
		"swipe left, right, or down in the main menu to spin the cube!",
		"try to surprise your opponent!",
		"check means you have three in a row, and you can win you next turn if it’s still open!",
		"second order wins involve making a series of checks that lead to a checkmate!",
		"second order wins are also called forcing sequences!",
		"you can set up a second order win with just three moves!",
		"checkmate means you have two checks, and your opponent can’t block them both!",
		"if you can get three in a row on two different lines with one move, that’s checkmate!",
		"checkmates are key to winning!",
		"second order checkmate means your opponent can’t prevent a second order win!",
		"second order check means you could have a second order win the next turn if it’s open!",
		"third and fourth order wins exist but aren’t shown in the analysis!",
		"sometimes you have to check to get out of a second order check!",
		"second order checkmate means your opponents checks (if any) don’t prevent a win!",
		"there are only 2 distinct first moves!",
		"solve boards are all first or second order wins!",
		"sometimes pressing an advantage is easier than finding a tricky win!",
		"settings are available under the main menu—just press \"more\"!",
		"cubist can be beaten, even when it goes first!",
		"changing your color will also change your app icon’s color!",
		"second order wins can sometimes be more than 10 checks long!",
		"some second order wins require you to let your opponent check you during the win!",
		"daily 1 boards can always be won in 1 move!",
		"daily 2 boards can always be won in 2 moves!",
		"daily 3 boards can always be won in 3 moves!",
		"daily 4 boards can always be won in 4 moves!",
		"analysis is not available in challenge mode until after the game!",
		"analysis is not available on solve boards until they are solved!",
		"analysis is not available in online games until after the game!",
		"analysis is available in sandbox mode both during and after the game!",
		"it is possible to reach a draw!",
		"the name on the left is player 1, and the name on the right is player 2!",
		"the name on the left always moves first!",
		"you can turn premoves on in settings!",
		"when premoves are on, you can tap to select a series of moves before its your turn!",
		"the dot by the solve button indicates that you have daily boards to solve!",
		"when notifications are on, the app badge indicates that you have daily boards to solve!",
		"if you run out of time in a timed game, you lose!",
		"the time limits in timed games show the total amount of time each player has for the game!",
		"you can save time in a timed game by using premoves!",
		"your premoves will cancel if you have a 4 in a row available!",
		"you can cancel your premoves by tapping on any of the moves you selected!",
		"bots’ names are in rectangles",
		"human players’ names always have rounded sides"
    ]
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}
