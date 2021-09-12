//
//  MainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

let solveButtonsEnabled = false
let tfVersion = true
let qubicVersion = 030033

struct MainView: View {
    @ObservedObject var screen: ScreenObserver
    @ObservedObject var game: Game = Game.main
    @ObservedObject var layout = Layout.main
    @State var halfBack: Bool = false
    @State var playSelection: [Int] = Storage.array(.lastPlayMenu) as? [Int] ?? [1,1,0,0]
    @State var searching: Bool = false
    
    // The delegate required by `MFMessageComposeViewController`
    let messageComposeDelegate = MessageDelegate()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer().modifier(LayoutModifier(for: .topSpacer))
            top.zIndex(9)
            mainStack.zIndex(1)
            moreStack.zIndex(0)
            Spacer()
            bottomButtons.modifier(LayoutModifier(for: .bottomButtons))
                .offset(y: layout.bottomButtonsOffset)
                .zIndex(10)
        }
        .onAppear {
            FB.main.start()
            layout.load(for: screen)
            layout.current = .main
            game.goBack = goBack
            game.cancelBack = cancelBack
			updateSolveBoardData()
            Notifications.setBadge(justSolved: false)
        }
        .onReceive(screen.objectWillChange) { layout.load(for: screen) }
        .frame(height: layout.total)
        .background(Fill())
        .gesture(scrollGestures)
    }
    
    let cube = CubeView()
    
    private var top: some View {
        VStack(spacing: 0) {
            Text("4Play beta")
                .font(.custom("Oligopoly Regular", size: 24))
                .padding(.top, 10)
                .modifier(LayoutModifier(for: .title))
            cube
                .onTapGesture(count: 2) { self.cube.resetCube() }
                .modifier(LayoutModifier(for: .cube))
            Fill()
                .modifier(LayoutModifier(for: .mainSpacer))
                .zIndex(2)
        }
        .background(Fill())
    }
    
    private var mainStack: some View {
        var trainText: String {
            layout.current == .trainMenu ? "  start  " : "  train  "
        }
        
        var solveText: String {
            layout.current == .solveMenu ? "  start  " : " solve "
        }
        
        var playText: String {
            if searching {
                return "\u{2009}            "
            } else {
                return layout.current == .playMenu ? "  start  " : "  \u{2009}\u{2009}\u{2009}play\u{2009}\u{2009}\u{2009}  "
            }
        }
        
        return VStack(spacing: 0) {
            TrainView()
                .modifier(LayoutModifier(for: .trainView))
            mainButton(views: [.trainMenu, .train], text: trainText, color: .tertiary(), action: switchLayout)
                .modifier(LayoutModifier(for: .trainButton))
                .zIndex(5)
            SolveView()
                .modifier(LayoutModifier(for: .solveView))//, alignment: .bottom)
                .zIndex(0)
            ZStack {
                mainButton(views: [.solveMenu, .solve], text: solveText, color: .secondary(), action: switchLayout)
                Circle()
                    .frame(width: 24, height: 24)
                    .foregroundColor(layout.current == .solveMenu ? .secondary() : .primary())
                    .zIndex(2)
                    .offset(x: 88, y: -25)
                    .opacity(layout.newDaily ? 1 : 0)
            }
            .modifier(LayoutModifier(for: .solveButton))
            PlayView(selected: $playSelection)
                .modifier(LayoutModifier(for: .playView)) //, alignment: .bottom)
            ZStack {
                mainButton(views: [.playMenu, .play], text: playText, color: .primary()) { v1,v2 in
                    if layout.current == .playMenu && playSelection[0] == 1 && playSelection[1] != 0 {
                        searching = true
                        FB.main.getOnlineMatch(timeLimit: [-1, 60, 300, 600][playSelection[2]], humansOnly: playSelection[1] == 2, onMatch: {
                            searching = false
                            layout.current = .play
                        }, onCancel: { searching = false })
                    } else if layout.current == .playMenu && playSelection[0] == 2 {
                        presentMessageCompose()
                    } else { switchLayout(to: v1, or: v2) }
                }
                ActivityIndicator()
                    .offset(x: 1, y: 1)
                    .opacity(searching ? 1 : 0)
            }
            .modifier(LayoutModifier(for: .playButton))
        }
    }
    
    private struct mainButton: View {
        let views: [ViewState]
        let text: String
        let color: Color
        let action: (ViewState, ViewState) -> Void
        
        var body: some View {
            ZStack {
                Fill().frame(height: mainButtonHeight)
                Button(action: { action(views[0], views[1]) }, label: { Text(text) })
                    .buttonStyle(MainStyle(color: views.contains(Layout.main.current) ? .primary() : color))
            }
        }
    }
    
    private var moreStack: some View {
        VStack(spacing: 0) {
            Fill().modifier(LayoutModifier(for: .moreSpacer))
            AboutView() { self.switchLayout(to: .about) }
                .frame(alignment: .top)
                .modifier(LayoutModifier(for: .about))
                .zIndex(3)
            SettingsView() { self.switchLayout(to: .settings) }
                .frame(alignment: .top)
                .modifier(LayoutModifier(for: .settings))
                .zIndex(2)
            FeedbackView() { self.switchLayout(to: .feedback) }
                .frame(alignment: .top)
                .modifier(LayoutModifier(for: .feedback))
                .zIndex(1)
            
//            ReplaysView() { self.switchView(to: .replays) }
//                .frame(height: heights.get(heights.replays), alignment: .top)
//            FriendsView() { self.switchView(to: .friends) }
//                .frame(height: heights.get(heights.friends), alignment: .top)
        }
    }
    
    private var bottomButtons: some View {
//        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Spacer().frame(width: 15)
                    if layout.leftArrows { arrowButtons }
                    else { undoButton.frame(alignment: .top) }
                    Spacer()
                    backButton
                    Spacer()
                    if layout.leftArrows { undoButton }
                    else { arrowButtons.frame(alignment: .top) }
                    Spacer().frame(width: 15)
                }
                Spacer()
            }
            .background(Fill())
            .buttonStyle(Solid())
            .frame(width: layout.width)
//            VStack {
//                Text("\(layout.hue), \(layout.baseColor)").offset(y: -700)
//                if #available(iOS 14.0, *) {
//                    Slider(value: $layout.baseColor, in: 0.5...1).padding(.horizontal, 20).offset(y: -700)//.onChange(of: layout.baseColor, perform: { layout.hue = $0 })
//                }
//                Slider(value: $layout.hue, in: 0...1).padding(.horizontal, 20).offset(y: -70)
//            }
//        }
    }
    
    private var backButton: some View {
        Button(action: goBack ) {
            VStack {
                Text(layout.current == .main ? "more" : halfBack ? "leave game?" : "back")
                    .font(.custom("Oligopoly Regular", size: 16))
                    .animation(nil)
                Text("↓")
                    .rotationEffect(Angle(degrees: layout.current == .main ? 0 : 180))
            }
//            .padding(.horizontal, 0)// halfBack ? 0 : 20)
//            .padding(.bottom, 10)
//            .padding(.top, 5)
            .frame(width: 110, height: bottomButtonHeight)
            .background(Fill())
        }
    }
    
    private var undoButton: some View {
        HStack(spacing: 0) {
//            Spacer().frame(width: layout.leftArrows ? 20 : 10)
            Button(action: game.undoMove) {
                VStack(spacing: 0) {
                    Fill(20).cornerRadius(10).opacity(0.00001)
                    Text("undo")
                        .font(.custom("Oligopoly Regular", size: 16))
                        .accentColor(.label)
                    Text(" ")
    //                    .padding(.bottom, 10)
    //                    .multilineTextAlignment(layout.leftArrows ? .trailing : .leading)
                }
            }
            .frame(width: 75, height: bottomButtonHeight, alignment: layout.leftArrows ? .trailing : .leading)
            .offset(y: -10)
            .padding(.horizontal, 10)
            .opacity(game.undoOpacity.rawValue)
//            Spacer().frame(width: layout.leftArrows ? 10 : 20)
        }
    }
    
    private var arrowButtons: some View {
        HStack(spacing: 0) {
//            Spacer().frame(width: layout.leftArrows ? 30 : 0)
            Button(action: game.prevMove) {
                VStack(spacing: 0) {
                    Fill(20).cornerRadius(10).opacity(0.00001)
                    Text("←")
                        .font(.custom("Oligopoly Regular", size: 25))
                        .accentColor(.label)
    //                    .padding(.bottom, 10)
                    Blank(12)
                }
            }
            .frame(width: 40, height: bottomButtonHeight)
            .offset(y: -10)
            .opacity(game.prevOpacity.rawValue)
            Spacer().frame(width: 15)
            Button(action: game.nextMove) {
                VStack(spacing: 0) {
                    Fill(20).cornerRadius(10).opacity(0.00001)
                    Text("→")
                        .font(.custom("Oligopoly Regular", size: 25))
                        .accentColor(.label)
    //                    .padding(.bottom, 10)
                    Blank(12)
                }
            }
            .frame(width: 40, height: bottomButtonHeight)
            .offset(y: -10)
            .opacity(game.nextOpacity.rawValue)
//            Spacer().frame(width: layout.leftArrows ? 0 : 30)
        }
    }
    
    var scrollGestures: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { drag in
                let h = drag.translation.height
                let w = drag.translation.width
                if abs(h)/abs(w) > 1 {
                    if self.layout.current == .main {
                        if h < 0 { self.switchLayout(to: .more) }
                        else { self.cube.flipCube() }
                    } else if h > 0 || self.layout.current.menuView {
                        self.goBack()
                    }
                } else {
                    self.cube.rotate(right: w > 0)
                }
            }
    }
    
    func switchLayout(to newLayout: ViewState, or otherLayout: ViewState? = nil) {
        if let nextView = (layout.current != newLayout) ? newLayout : otherLayout {
            withAnimation(.easeInOut(duration: 0.4)) { //0.4
                layout.current = nextView
            }
        }
    }
    
    func goBack() {
        if game.hideHintCard() { return }
        if layout.current.gameView { halfBack.toggle() }
        if halfBack {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            FB.main.cancelOnlineSearch?()
            game.endGame(with: .myLeave)
            withAnimation(.easeInOut(duration: 0.4)) { //0.4
                layout.current = layout.current.back
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
        MainView(screen: ScreenObserver()).previewDevice("iPhone 8")
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//            .previewDevice("iPhone 11 Pro")
//        MainView(window: UIWindow())
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .preferredColorScheme(.dark)
    }
}
