//
//  MainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var screen: ScreenObserver
    @ObservedObject var game: Game = Game.main
    @State var heights: Heights = Heights()
    @State var halfBack: Bool = false
    @State var playSelection = [1,1,0]
    @State var searching: Bool = false
    
    // The delegate required by `MFMessageComposeViewController`
    let messageComposeDelegate = MessageDelegate()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Fill(heights.topSpacer)
            top.zIndex(9)
            mainStack.zIndex(1)
            moreStack.zIndex(0)
            Spacer()
            Fill(heights.fill).zIndex(10)
                .offset(y: heights.fillOffset)
            backButton.frame(height: heights.backButton)
                .offset(y: heights.backButtonOffset)
                .zIndex(10)
        }
        .onAppear {
            FB.main.start()
            heights = Heights(newScreen: self.screen)
            heights.view = .main
            game.goBack = goBack
            game.cancelBack = cancelBack
        }
        .frame(height: heights.total)
        .background(Fill())
        .gesture(scrollGestures)
    }
    
    let cube = CubeView()
    
    private var top: some View {
        VStack {
            Text("4Play beta")
                .font(.custom("Oligopoly Regular", size: 24))
                .padding(.top, 20)
            cube
                .onTapGesture(count: 2) { self.cube.resetCube() }
                .frame(height: heights.cube)
            Fill()
                .zIndex(2)
        }
        .frame(height: heights.get(heights.top))
        .background(Fill())
    }
    
    private var mainStack: some View {
        var trainText: String {
            heights.view == .trainMenu ? "  start  " : "  train  "
        }
        
        var solveText: String {
            heights.view == .solveMenu ? "  start  " : " solve "
        }
        
        var playText: String {
            if searching {
                return "\u{2009}            "
            } else {
                return heights.view == .playMenu ? "  start  " : "  \u{2009}\u{2009}\u{2009}play\u{2009}\u{2009}\u{2009}  "
            }
        }
        
        return VStack(spacing: 0) {
            TrainView(view: $heights.view)
                .frame(height: heights.get(heights.trainView), alignment: .bottom)
            mainButton(view: $heights.view, views: [.trainMenu, .train], text: trainText, color: .tertiary(0), action: switchView)
                .zIndex(5)
            SolveView(view: $heights.view)
                .frame(height: heights.get(heights.solveView), alignment: .bottom)
            ZStack {
                mainButton(view: $heights.view, views: [.solveMenu, .solve], text: solveText, color: .secondary(0), action: switchView)
                if UserDefaults.standard.integer(forKey: Key.lastDC) != Date().getInt() {
                    Circle().frame(width: 24, height: 24).foregroundColor(heights.view == .solveMenu ? .secondary(0) : .primary(0)).zIndex(2).offset(x: 88, y: -25)
                }
            }
            PlayView(view: $heights.view, selected: $playSelection)
                .frame(height: heights.get(heights.playView), alignment: .bottom)
            ZStack {
                mainButton(view: $heights.view, views: [.playMenu, .play], text: playText, color: .primary(0)) { v1,v2 in
                    if heights.view == .playMenu && playSelection[0] == 1 && playSelection[1] != 0 {
                        searching = true
                        FB.main.getOnlineMatch(timeLimit: -1, humansOnly: playSelection[1] == 2, onMatch: {
                            searching = false
                            heights.view = .play
                        }, onCancel: { searching = false })
                    } else if heights.view == .playMenu && playSelection[0] == 2 {
                        presentMessageCompose()
                    } else { switchView(to: v1, or: v2) }
                }
                ActivityIndicator()
                    .offset(x: 1, y: 1)
                    .opacity(searching ? 1 : 0)
            }
        }
    }
    
    private struct mainButton: View {
        @Binding var view: ViewState
        let views: [ViewState]
        let text: String
        let color: Color
        let action: (ViewState, ViewState) -> Void
        
        var body: some View {
            ZStack {
                Fill().frame(height: mainButtonHeight)
                Button(action: { action(views[0], views[1]) }, label: { Text(text) })
                    .buttonStyle(MainStyle(color: views.contains(view) ? .primary(0) : color))
            }
        }
    }
    
    private var moreStack: some View {
        VStack(spacing: 0) {
            AboutView(view: $heights.view) { self.switchView(to: .about) }
                .frame(height: heights.get(heights.about), alignment: .top)
                .zIndex(2)
            SettingsView(view: $heights.view) { self.switchView(to: .settings) }
                .frame(height: heights.get(heights.settings), alignment: .top)
                .zIndex(1)
//            ReplaysView() { self.switchView(to: .replays) }
//                .frame(height: heights.get(heights.replays), alignment: .top)
//            FriendsView() { self.switchView(to: .friends) }
//                .frame(height: heights.get(heights.friends), alignment: .top)
            Fill(heights.get(heights.moreFill))
        }
    }
    
    private var backButton: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 10)
            Button(action: game.undoMove) {
                Text("undo")
                    .font(.custom("Oligopoly Regular", size: 15.5))
                    .accentColor(.label)
                    .padding(.bottom, 52)
            }
            .frame(width: 100)
            .opacity(game.undoOpacity.rawValue)
            Spacer().frame(width: 20)
            Spacer()
            Button(action: goBack ) {
                VStack {
                    Text(heights.view == .main ? "more" : halfBack ? "leave game?" : "back")
                        .font(.custom("Oligopoly Regular", size: 16))
                        .animation(nil)
                    Text("↓")
                        .rotationEffect(Angle(degrees: heights.view == .main ? 0 : 180))
                }
                .padding(.horizontal, halfBack ? 0 : 20)
                .padding(.bottom, 35)
                .padding(.top, 5)
                .background(Fill())
            }
            Spacer()
            Button(action: game.prevMove) {
                Text("←")
                    .font(.custom("Oligopoly Regular", size: 25))
                    .accentColor(.label)
                    .padding(.bottom, 45)
            }
            .frame(width: 40)
            .opacity(game.prevOpacity.rawValue)
            Spacer().frame(width: 20)
            Button(action: game.nextMove) {
                Text("→")
                    .font(.custom("Oligopoly Regular", size: 25))
                    .accentColor(.label)
                    .padding(.bottom, 45)
            }
            .frame(width: 40)
            .opacity(game.nextOpacity.rawValue)
            Spacer().frame(width: 30)
        }.background(Rectangle().foregroundColor(.systemBackground))
        .buttonStyle(Solid())
    }
    
    var scrollGestures: some Gesture {
        DragGesture()
            .onEnded { drag in
                let h = drag.predictedEndTranslation.height
                let w = drag.predictedEndTranslation.width
                if abs(h)/abs(w) > 1 {
                    if self.heights.view == .main {
                        if h < 0 { self.switchView(to: .more) }
                        else { self.cube.flipCube() }
                    } else if h > 0 || [.trainMenu, .solveMenu, .playMenu].contains(self.heights.view) {
                        self.goBack()
                    }
                } else {
                    self.cube.rotate(right: w > 0)
                }
            }
    }
    
    func switchView(to newView: ViewState, or otherView: ViewState? = nil) {
        if let nextView = (heights.view != newView) ? newView : otherView {
            withAnimation(.easeInOut(duration: 0.4)) { //0.4
                heights.view = nextView
            }
        }
    }
    
    func goBack() {
        if game.hideHintCard() { return }
        if heights.view.gameView { halfBack.toggle() }
        if halfBack {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            game.turnOff()
            FB.main.cancelOnlineSearch?()
            FB.main.finishedOnlineGame(with: .myLeave)
            withAnimation(.easeInOut(duration: 0.4)) { //0.4
                heights.view = heights.view.back
            }
        }
    }
    
    func cancelBack() -> Bool {
        if game.hideHintCard() { return false }
        if halfBack {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            halfBack = false
            return false
        }
        return true
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ScreenObserver())
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//            .previewDevice("iPhone 11 Pro")
//        MainView(window: UIWindow())
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .preferredColorScheme(.dark)
    }
}
