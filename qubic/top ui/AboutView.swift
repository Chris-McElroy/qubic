//
//  AboutView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @ObservedObject var layout = Layout.main
    var mainButtonAction: () -> Void
    let pickerContent: [[Any]] = [["how to play", "using the app", "developer bio", "helpful links"]]
    @State var selected: [Int] = [0]
    @State var page: Int = 0
    var width: CGFloat { min(500, layout.width) }
    
    var body: some View {
        VStack {
            ZStack {
                Fill().frame(height: moreButtonHeight)
                Button(action: mainButtonAction) {
                    Text("about")
                }
                .buttonStyle(MoreStyle())
            }.zIndex(4)
            if layout.current == .about {
                ZStack {
                    VStack(spacing: 0) {
                        Spacer()
                        HPicker(content: .constant(pickerContent), dim: (130,40), selected: $selected, action: onSelection)
                            .frame(height: 50)
                    }
                    VStack(spacing: 0) {
                        ZStack {
                            HStack(spacing: 0) {
                                Spacer()
                                if page == 0 {
                                    howToPlayPage.frame(width: width)
                                } else if page == 1 {
                                    usingTheAppPage.frame(width: width)
                                } else if page == 2 {
                                    developerBioPage.frame(width: width)
                                } else {
                                    linkPage.frame(width: width)
                                }
                                Spacer()
                            }
                            .gesture(swipeGesture)
                        }
                        Blank(60)
                    }
                }.zIndex(2)
            }
            Spacer()
        }
        .background(Fill())
    }
    
    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { drag in
                let h = drag.translation.height
                let w = drag.translation.width
                if abs(h)/abs(w) < 1 {
                    if w > 0 {
                        if selected[0] > 0 { selected[0] -= 1 }
                    } else {
                        if selected[0] < 3 { selected[0] += 1 }
                    }
                    withAnimation {
                        page = selected[0]
                    }
                }
            }
    }
    
    func onSelection(row: Int, component: Int) {
        withAnimation {
            page = row
        }
    }
    
    var howToPlayPage: some View {
        ScrollView {
            Text("the goal").bold().padding(.bottom, 1)
            Text("To play 4x4x4 tic tac toe, or qubic, you and your opponent alternate placing moves in open positions on the board. Your goal is to get 4 of your moves in a row before they do. These 4 moves can be in any direction—left, right, up, down, or diagonal—any completely straight line on the 3 dimensional board. There are 64 possible moves, but 76 possible winning lines, some of which can be very tricky to see!\n").multilineTextAlignment(.leading)
            Text("checkmate").bold().padding(.bottom, 1)
            Text("One way to win is to create a 4 in a row in a tricky way that your opponent doesn’t notice. But some opponents are too careful for this to work effectively. In that case, another strategy is necessary. If you have 2 in a row along two intersecting lines (with the intersection open), you can place one move to get 3 in a row along two lines at once. If your opponent cannot win in the next turn, this is impossible for them to block. Such a position, in which you force your opponent to block multiple lines at once, is called a checkmate. In chess, checkmate is the last move. In tic tac toe, you must still get 4 in a row, but there is no way for your opponent to prevent you from doing so. So checkmate is effectively another way to win.\n").multilineTextAlignment(.leading)
            Text("second order wins").bold().padding(.bottom, 1)
            Text("A careful opponent can still watch for and block any checkmates, so you would need an even more powerful strategy to beat them. This is possible using checks. Since 4 in a row wins the game, 3 in a row acts as a forcing move. It is often referred to as a \"check\" since, like chess, your opponent is required to block it to avoid losing. While checks are not winning moves on their own, they can be strung together to create long, pre-planned sequences, that the opponent is forced to go along with. A sequence of checks that ends in checkmate is called a second order win (with a lone checkmate being the simplest second order win). Long second order wins are nearly impossible to anticipate or block. These are the heart of qubic.\n").multilineTextAlignment(.leading)
            Text("second order checkmates").bold().padding(.bottom, 1)
            Text("With great care, it is possible to find moves that will block a second order win. In this case, the move before such a win acts to limit your opponent’s options to only those moves that prevent your win. Thus, the threat of such a win acts as a meta-check, since it forces your opponent into similarly restrictive options. This threat is therefore called a second order check. Second order checkmates, in which you threaten multiple second order wins and your opponent cannot block them all, are also possible, though rarer. Third and fourth order wins are possible but much less studied.\n").multilineTextAlignment(.leading)
            Text("learning more").bold().padding(.bottom, 1)
            Text("As you play more qubic, checks and checkmates will become easier to recognize. You can use the hints available after the game (or during the game in sandbox mode) to identify second order wins and try to complete them. Solve boards are made for just this purpose—all solve boards are either first or second order wins, though there are other ways to solve them that are entirely valid. Patience is key; learning to play well takes a lot of time. This guide is only meant to point you to the next part to explore. Good luck!").multilineTextAlignment(.leading)
        }.padding(.horizontal, 20)
    }
    
    var usingTheAppPage: some View {
        ScrollView {
            VStack {
                Text("playing games").bold().padding(.bottom, 1)
                Text("You can play games by pressing \"play\", \"solve\", or \"train\", and then \"start\". Once you start a game, you can see your name and your opponent’s name at the top, with the first player on the left and the second player on the right. When it’s your turn, your name (\"new player\" by default) glows. On your turn, you can tap on any open space to move there. Your moves are the same color as your name. You can rotate the board by swiping left or right. Double tapping on the background resets the rotation. The right and left arrows at the bottom of the screen allow you to review the progress of the game by replaying previous moves. Note that you cannot make a move if you are on a previous move. When one player gets 4 in a row, a line appears connecting the row, and the board spins around. After the game ends, you can review previous moves by tapping the left arrow, and even test out alternative moves, which show up slightly transparent. Swiping up brings up the hints panel. When hints are enabled, this explains what opportunities you and your opponent have to win. By tapping \"wins\", you can see hints about making or stopping your wins, while tapping \"blocks\" brings up hints for your opponent’s wins. The hints are a powerful tool for learning from your games and becoming a strong player.\n").multilineTextAlignment(.leading)
                Text("play options").bold().padding(.bottom, 1)
                Text("The \"play\" menu allows you to choose a local, online, or invite game. Local games are played on a single device, and are helpful for playing with someone else in person or learning on your own. You can choose to go first or second, or leave it to be chosen randomly. Local games can be played in sandbox mode, in which hints and undos are available the whole game, or challenge mode, which does not allow undos, and only displays hints after the game. Online games are played between devices over the internet. In auto mode, the app searchs for another human for a few seconds, and match you with a bot if no one else is available. Bots’ names are in rectangles, while human players’ names have rounded sides like yours. If you want to wait for another human, you can switch from auto to humans mode. If you just want to play with a bot, you can instead switch from auto to bots, which matches you with a bot as soon as you press \"start\". Both local and online games can be played with a time limit of 1, 5, or 10 min. This time limit is the total time given to each player to make all of their moves, and if your time runs out, you lose the game. Invite games use the 4Play iMessages extension, which allows you to play games with friends in the Messages app. These games are played one move at a time, with no time limit on moves.\n").multilineTextAlignment(.leading)
                Text("solve options").bold().padding(.bottom, 1)
                Text("Pressing \"solve\" brings up all the solve boards, which are divided into daily, simple, common, and tricky boards. Daily boards are 4 boards of increasing hardness: daily 1 is a 1 move win (3 in a row), daily 2 is a 2 move win (checkmate), daily 3 is a 3 move win, and daily 4 is a 4 move win. If you solve all 4 of them in one day, you get one day added to your daily streak, the gray number that appears under daily. Simple boards work up from 3 in a rows to simple second order wins. Common boards are foundational second order wins that come up frequently or are built on in more complicated tactics. The first 12 contain triangles, setups consisting of 3 moves in a plane from which a 6 move long second order win is possible. Tricky boards are long and often hard to find second order wins. Some of them involve tactics like check-backs, in which you allow your opponent to check you part of the way through a second order win. Tricky boards can take many attempts to solve, and are meant more as a puzzle than an exercise.\n").multilineTextAlignment(.leading)
            }
            VStack {
                Text("train options").bold().padding(.bottom, 1)
                Text("The \"train\" button brings up 6 computer opponents to choose from: novice, defender, warrior, tyrant, oracle, and cubist. Their skills run the gamut; while novice often overlooks checks, cubist blocks second order wins whenever possible. The sandbox and challenge modes available in local games are present here too. Sandbox mode games are helpful for understanding the game as it unfolds and correcting mistakes. If you beat a training opponent in challenge mode, its name will be underlined to mark your success. Keep in mind: all of these opponents can be beaten, even moving first.\n").multilineTextAlignment(.leading)
                Text("settings").bold().padding(.bottom, 1)
                Text("When you first open the app, your name shows up as \"new player\" and your color is blue. You can change these by going to settings. To get to settings, press more (or swipe up) from the main menu, then tap \"settings\". To change your username, simply click on the text under the word username, edit it, and then press return. To choose a color, tap on the other color cubes under the word color. The arrow side setting determines which side the left and right arrows appear on during the game. It’s typically easier to have them on the same side as the hand you typically hold your device with. Turning premoves on allows you to select moves during your opponent’s move that will process as soon as it’s your turn. Premoves cancel if you select any already-selected premoves, or if your opponent leaves you 3 in a row. Finally, if you turn notifications on, the app icon will display a badge with a 1 anytime there are remaining daily challenges. In the future, notifications will also include game invites and friend invites.\n").multilineTextAlignment(.leading)
                Text("feedback").bold().padding(.bottom, 1)
                Text("Your feedback is incredibly helpful for improving this app. If you have any ideas, questions, or spot any bugs, please report it by going to the feedback page under settings, entering your feedback in the main text box (including your email if you’d like a response), and pressing send. If you’d like to include a screenshot or video, please send your feedback via email by pressing the \"send as email\" button. The development process is slow, and basing it on user feedback makes it much more productive. Thanks so much for your help!").multilineTextAlignment(.leading)
            }
        }.padding(.horizontal, 20)
    }
    
    var developerBioPage: some View {
        ScrollView {
            Text("This app is developed by Chris McElroy, the founder, president, and only employee of XNO LLC. Chris grew up in Norfolk, Virginia, and graduated high school in 2015. He moved to Claremont, California to attend Harvey Mudd College, graduating in 2019 with a degree in general Engineering. While at college Chris became obsessed with qubic, building several physical boards and making plans to produce an internet-connected board with friends. Those plans quickly scaled up to a mass-producable version that he’d go on to market on Kickstarter after graduating college. When that failed to generate enough interest, Chris began to focus more on the app version of the game, moving on to other full time work while developing this app in his free time. In his other free time, Chris likes to climb, run, bike, and listen to music.").multilineTextAlignment(.leading)
        }.padding(.horizontal, 20)
    }
    
    var linkPage: some View {
        VStack(spacing: 20) {
            Fill()
            LinkView(text: "about xno", site: "https://xno.store/about")
            LinkView(text: "contact xno", site: "https://xno.store/contact")
            LinkView(text: "privacy policy", site: "https://xno.store/privacy-policy")
            LinkView(text: "game history", site: "https://en.wikipedia.org/wiki/3D_tic-tac-toe")
            LinkView(text: "join the discord", site: "https://discord.gg/7J48ms5")
            Text("©2021 XNO LLC")
            Fill()
        }.padding(.horizontal, 20)
        .background(Fill())
        .frame(width: layout.width)
    }
    
    struct LinkView: View {
        let text: String
        let site: String
        
        var body: some View {
            Button(action: {
                if let url = URL(string: site) {
                   UIApplication.shared.open(url)
               }
            }) {
                Text(text).accentColor(.blue)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView() {}
    }
}
