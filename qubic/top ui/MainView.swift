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
    @ObservedObject var layout = Layout.main
    @State var halfBack: Bool = false
    @State var playSelection = [1,1,0]
    @State var searching: Bool = false
    
    // The delegate required by `MFMessageComposeViewController`
    let messageComposeDelegate = MessageDelegate()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Fill(layout.topSpacer)
            top.zIndex(9)
            mainStack.zIndex(1)
            moreStack.zIndex(0)
            Spacer()
            Fill(layout.fill).zIndex(10)
                .offset(y: layout.fillOffset)
            bottomButtons.frame(height: layout.backButton)
                .offset(y: layout.backButtonOffset)
                .zIndex(10)
        }
        .onAppear {
            FB.main.start()
            layout.load(for: self.screen)
            layout.view = .main
            game.goBack = goBack
            game.cancelBack = cancelBack
        }
        .frame(height: layout.total)
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
                .frame(height: layout.cube)
            Fill()
                .zIndex(2)
        }
        .frame(height: layout.get(layout.top))
        .background(Fill())
    }
    
    private var mainStack: some View {
        var trainText: String {
            layout.view == .trainMenu ? "  start  " : "  train  "
        }
        
        var solveText: String {
            layout.view == .solveMenu ? "  start  " : " solve "
        }
        
        var playText: String {
            if searching {
                return "\u{2009}            "
            } else {
                return layout.view == .playMenu ? "  start  " : "  \u{2009}\u{2009}\u{2009}play\u{2009}\u{2009}\u{2009}  "
            }
        }
        
        return VStack(spacing: 0) {
            TrainView()
                .frame(height: layout.get(layout.trainView), alignment: .bottom)
            mainButton(view: $layout.view, views: [.trainMenu, .train], text: trainText, color: .tertiary(0), action: switchView)
                .zIndex(5)
            SolveView()
                .frame(height: layout.get(layout.solveView), alignment: .bottom)
            ZStack {
                mainButton(view: $layout.view, views: [.solveMenu, .solve], text: solveText, color: .secondary(0), action: switchView)
                if UserDefaults.standard.integer(forKey: Key.lastDC) != Date().getInt() {
                    Circle().frame(width: 24, height: 24).foregroundColor(layout.view == .solveMenu ? .secondary(0) : .primary(0)).zIndex(2).offset(x: 88, y: -25)
                }
            }
            PlayView(selected: $playSelection)
                .frame(height: layout.get(layout.playView), alignment: .bottom)
            ZStack {
                mainButton(view: $layout.view, views: [.playMenu, .play], text: playText, color: .primary(0)) { v1,v2 in
                    if layout.view == .playMenu && playSelection[0] == 1 && playSelection[1] != 0 {
                        searching = true
                        FB.main.getOnlineMatch(timeLimit: -1, humansOnly: playSelection[1] == 2, onMatch: {
                            searching = false
                            layout.view = .play
                        }, onCancel: { searching = false })
                    } else if layout.view == .playMenu && playSelection[0] == 2 {
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
            AboutView() { self.switchView(to: .about) }
                .frame(height: layout.get(layout.about), alignment: .top)
                .zIndex(2)
            SettingsView() { self.switchView(to: .settings) }
                .frame(height: layout.get(layout.settings), alignment: .top)
                .zIndex(1)
//            ReplaysView() { self.switchView(to: .replays) }
//                .frame(height: heights.get(heights.replays), alignment: .top)
//            FriendsView() { self.switchView(to: .friends) }
//                .frame(height: heights.get(heights.friends), alignment: .top)
            Fill(layout.get(layout.moreFill))
        }
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 0) {
            if layout.leftArrows { arrowButtons }
            else { undoButton }
            Spacer()
            backButton
            Spacer()
            if layout.leftArrows { undoButton }
            else { arrowButtons }
        }.background(Rectangle().foregroundColor(.systemBackground))
        .buttonStyle(Solid())
    }
    
    private var backButton: some View {
        Button(action: goBack ) {
            VStack {
                Text(layout.view == .main ? "more" : halfBack ? "leave game?" : "back")
                    .font(.custom("Oligopoly Regular", size: 16))
                    .animation(nil)
                Text("↓")
                    .rotationEffect(Angle(degrees: layout.view == .main ? 0 : 180))
            }
            .padding(.horizontal, halfBack ? 0 : 20)
            .padding(.bottom, 35)
            .padding(.top, 5)
            .background(Fill())
        }
    }
    
    private var undoButton: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: layout.leftArrows ? 20 : 10)
            Button(action: game.undoMove) {
                Text("undo")
                    .font(.custom("Oligopoly Regular", size: 15.5))
                    .accentColor(.label)
                    .padding(.bottom, 52)
            }
            .frame(width: 100)
            .opacity(layout.view.gameView ? game.undoOpacity.rawValue : 0)
            Spacer().frame(width: layout.leftArrows ? 10 : 20)
        }
    }
    
    private var arrowButtons: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: layout.leftArrows ? 30 : 0)
            Button(action: game.prevMove) {
                Text("←")
                    .font(.custom("Oligopoly Regular", size: 25))
                    .accentColor(.label)
                    .padding(.bottom, 45)
            }
            .frame(width: 40)
            .opacity(layout.view.gameView ? game.prevOpacity.rawValue : 0)
            Spacer().frame(width: 20)
            Button(action: game.nextMove) {
                Text("→")
                    .font(.custom("Oligopoly Regular", size: 25))
                    .accentColor(.label)
                    .padding(.bottom, 45)
            }
            .frame(width: 40)
            .opacity(layout.view.gameView ? game.nextOpacity.rawValue : 0)
            Spacer().frame(width: layout.leftArrows ? 0 : 30)
        }
    }
    
    var scrollGestures: some Gesture {
        DragGesture()
            .onEnded { drag in
                let h = drag.predictedEndTranslation.height
                let w = drag.predictedEndTranslation.width
                if abs(h)/abs(w) > 1 {
                    if self.layout.view == .main {
                        if h < 0 { self.switchView(to: .more) }
                        else { self.cube.flipCube() }
                    } else if h > 0 || self.layout.view.menuView {
                        self.goBack()
                    }
                } else {
                    self.cube.rotate(right: w > 0)
                }
            }
    }
    
    func switchView(to newView: ViewState, or otherView: ViewState? = nil) {
        if let nextView = (layout.view != newView) ? newView : otherView {
            withAnimation(.easeInOut(duration: 0.4)) { //0.4
                layout.view = nextView
            }
        }
    }
    
    func goBack() {
        if game.hideHintCard() { return }
        if layout.view.gameView { halfBack.toggle() }
        if halfBack {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            FB.main.cancelOnlineSearch?()
            FB.main.finishedOnlineGame(with: .myLeave)
            withAnimation(.easeInOut(duration: 0.4)) { //0.4
                layout.view = layout.view.back
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
