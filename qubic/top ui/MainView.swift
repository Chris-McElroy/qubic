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
    @State var heights: Heights = Heights()
    @State var halfBack: Bool = false
    
    let board = BoardScene()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Fill(heights.topSpacer)
            top.zIndex(2)
            mainStack//.zIndex(1)
            moreStack
            Spacer()
            Fill(heights.fill)
                .offset(y: heights.fillOffset)
            backButton.frame(height: heights.backButton)
                .offset(y: heights.backButtonOffset)
        }
        .onAppear {
            heights = Heights(newScreen: self.screen)
            heights.view = .main
            board.goBack = goBack
            board.cancelBack = cancelBack
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
        VStack(spacing: 0) {
            TrainView(view: $heights.view, board: board)
                .frame(height: heights.get(heights.trainView), alignment: .bottom)
            mainButton(text: "train", color: heights.view == .trainMenu ? getColor(0) : getColor3(0)) { self.switchView(to: .trainMenu, or: .train) }
            SolveView(view: $heights.view, board: board)
                .frame(height: heights.get(heights.solveView), alignment: .bottom)
            ZStack {
                mainButton(text: "solve", color: heights.view == .solveMenu ? getColor(0) : getColor2(0)) { self.switchView(to: .solveMenu, or: .solve) }
                if UserDefaults.standard.integer(forKey: lastDCKey) != Date().getInt() {
                    Circle().frame(width: 24, height: 24).foregroundColor(heights.view == .solveMenu ? getColor2(0) : getColor(0)).zIndex(2).offset(x: 88, y: -25)
                }
            }
            PlayView(view: $heights.view, board: board)
                .frame(height: heights.get(heights.playView), alignment: .bottom)
            mainButton(text: "play", color: getColor(0)) { self.switchView(to: .play) }
        }
    }
    
    private struct mainButton: View {
        let text: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action, label: { Text(text) }).buttonStyle(MainStyle(color: color))
        }
    }
    
    private var moreStack: some View {
        VStack(spacing: 0) {
            AboutView() { self.switchView(to: .about) }
                .frame(height: heights.get(heights.about), alignment: .top)
            SettingsView() { self.switchView(to: .settings) }
                .frame(height: heights.get(heights.settings), alignment: .top)
            ReplaysView() { self.switchView(to: .replays) }
                .frame(height: heights.get(heights.replays), alignment: .top)
            FriendsView() { self.switchView(to: .friends) }
                .frame(height: heights.get(heights.friends), alignment: .top)
            Fill(heights.get(heights.moreFill))
        }
    }
    
    private var backButton: some View {
        Button(action: goBack ) {
            VStack {
                Text(heights.view == .main ? "more" : halfBack ? "leave game?" : "back")
                    .font(.custom("Oligopoly Regular", size: 16))
                    .animation(nil)
                Text("↓")
                    .rotationEffect(Angle(degrees: heights.view == .main ? 0 : 180))
            }
            .padding(.bottom, 35)
            .padding(.horizontal, 100)
            .padding(.top, 5)
            .background(Fill())
        }
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
                    } else if h > 0 {
                        self.goBack()
                    }
                } else {
                    self.cube.rotate(right: w > 0)
                }
            }
    }
    
    func switchView(to newView: ViewStates, or otherView: ViewStates? = nil) {
        if let nextView = (heights.view != newView) ? newView : otherView {
            withAnimation(.easeInOut(duration: 0.4)) {
                heights.view = nextView
            }
        }
    }
    
    func goBack() {
        let backMain: [ViewStates] = [.more,.train,.trainMenu,.solve,.solveMenu,.play]
        if [.play,.solve,.train].contains(heights.view) { halfBack.toggle() }
        if halfBack {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            withAnimation(.easeInOut(duration: 0.4)) {
                heights.view = backMain.contains(heights.view) ? .main : .more
            }
        }
    }
    
    func cancelBack() -> Bool {
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
