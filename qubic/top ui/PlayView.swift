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
    @Binding var selected: [Int]
    static let onlineMenuText = [[("local",false),("online",false),("invite",false)],
                                 [("bots",false),("auto",false),("humans",false)],
                                 [("sandbox",false),("challenge",false)]]
    static let altMenuText = [[("local",false),("online",false),("invite",false)],
                              [("first",false),("random",false),("second",false)],
                              [("sandbox",false),("challenge",false)]]
    @State var menuText: [[Any]] = PlayView.onlineMenuText
    @State var tip = tips.randomElement() ?? ""
    
    var body: some View {
        if layout.view == .play {
            GameView()
                .onAppear { Game.main.load(mode: mode, turn: turn, hints: hints) }
        } else if layout.view == .playMenu {
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    HPicker(content: $menuText, dim: (90, 55), selected: $selected, action: onSelection)
                        .frame(height: 180)
                }
                VStack {
                    Spacer()
                    Spacer()
                    Button(action: { tip = PlayView.tips.filter({ $0 != tip }).randomElement() ?? "" }) {
                        VStack(spacing: 0) {
                            Text("tip")
                                .bold()
                                .font(.custom("Oligopoly Regular", size: 16))
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
                    Spacer()
                    Fill(100)
                        .opacity(mode == .local ? 0.0 : 0.8)
                        .animation(.linear(duration: 0.15))
                    Fill(60)
                        .opacity(mode != .invite ? 0.0 : 0.8)
                        .animation(.linear(duration: 0.15))
                    Blank(60)
                }
            }.onAppear {
                FB.main.finishedOnlineGame(with: .error)
                tip = PlayView.tips.filter({ $0 != tip }).randomElement() ?? ""
            }
        }
    }
    
    var mode: GameMode {
        switch selected[0] {
        case 0: return .local
        case 1: return .online
        default: return .invite
        }
    }
    
    var turn: Int {
        if mode == .online { return FB.main.myGameData?.myTurn ?? Int.random(in: 0...1) }
        
        switch selected[1] {
        case 0: return 0
        case 2: return 1
        default: return Int.random(in: 0...1)
        }
    }
    
    var hints: Bool {
        selected[2] == 0 && mode != .online
    }
    
    func onSelection(row: Int, component: Int) {
        FB.main.cancelOnlineSearch?()
        if component == 0 {
            menuText = mode == .online ? PlayView.onlineMenuText : PlayView.altMenuText
        }
    }
    
    static let tips: [String] = [
        "swipe up on the board for hints!",
        "you can change your name and color in settings!",
        "your name can include emojis and other i̴͍͈̱̊͐͑n̵̠̍̊̎t̸̹͗̈́͜͝e̸̗̝̻͠r̸̰̀ê̶̼͍s̵̰̯̅̀t̴̢͂̾̎ị̴̏̎n̸̡̨̟̍̐g̶͓̙̺̊̒ characters!",
        "the \"auto\" option will match you with a bot if you don't match with a human in time!",
        "sandbox mode lets you undo moves and see hints during the game!",
        "training opponents who you beat in a challenge game will have their name underlined!",
        "you can make hypothetical moves after a game if you go back to earlier positions!",
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
        "when it's your turn, your name will glow!",
        "if your opponent has your color, their color will appear different for you!",
        "once you beat a solve board, its name will show up underlined!",
        "if you get the menu cube off-axis, you can double tap it to reset it!",
        "you can send feedback by pressing \"back\" then \"more\" then \"feedback\"!",
        "sending feedback will help make the app better!",
        "if you tap this hint a new one will appear!",
        "the board has 76 possible winning lines!",
        "the board has 192 automorphisms (symmetries)!",
        "the board has 18 4x4 planes!",
        "the first player to get 4 in a row wins!",
        "the number under daily is your current streak for solving all the daily challenges!",
        "if you tap on moves they'll spin around!",
        "swipe left, right, or down in the main menu to spin the cube!",
        "try to surprise your opponent!",
        "check means you have three in a row, and you can win you next turn if it's still open!",
        "second order wins involve making a series of checks that lead to a checkmate!",
        "second order wins are also called forcing sequences!",
        "you can set up a second order win with just three moves!",
        "checkmate means you have two checks, and your opponent can't block them both!",
        "if you can get three in a row on two different lines with one move, that's checkmate!",
        "checkmates are key to winning!",
        "second order checkmate means your opponent can't prevent a second order win!",
        "second order check means you could have a second order win the next turn if it's open!",
        "third and fourth order wins exist but aren't shown by the hints!",
        "sometimes you have to check to get out of a second order check!",
        "second order checkmate means your opponents checks (if any) don't prevent a win!",
        "there are only 2 distinct first moves!",
        "solve boards are all first or second order wins!",
        "sometimes pressing an advantage is easier than finding a tricky win!",
        "if you leave a game your progress will be lost!",
        "settings are available under the main menu—just press \"more\"!"
    ]
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(selected: .constant([0,0,0]))
    }
}
