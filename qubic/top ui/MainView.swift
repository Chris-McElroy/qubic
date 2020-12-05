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
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Fill(heights.topSpacer)
            top//.zIndex(2)
            mainStack//.zIndex(1)
            moreStack
            Spacer()
            Fill(heights.fill)
                .offset(y: heights.fillOffset)
            backButton.frame(height: heights.backButton)
                .offset(y: heights.backButtonOffset)
        }
        .onAppear { self.heights = Heights(newScreen: self.screen) }
        .onAppear { self.heights.view = .main  }
        .frame(height: heights.total)
        .background(Fill())
        .gesture(scrollGestures)
    }
    
    let cube = CubeView()
    
    private var top: some View {
        VStack {
            Text("qubic")
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
            TrainView(view: $heights.view) { self.switchBack() }
                .frame(height: heights.get(heights.trainView), alignment: .bottom)
            mainButton(text: "train") { self.switchView(to: .trainMenu, or: .train) }
            SolveView(view: $heights.view) { self.switchBack() }
                .frame(height: heights.get(heights.solveView), alignment: .bottom)
            mainButton(text: "solve") { self.switchView(to: .solveMenu, or: .solve) }
            PlayView(view: $heights.view) { self.switchBack() }
                .frame(height: heights.get(heights.playView), alignment: .bottom)
            mainButton(text: "play") { self.switchView(to: .play) }
        }
    }
    
    private struct mainButton: View {
        let text: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action, label: { Text(text) }).buttonStyle(MainStyle())
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
        Button(action: { self.switchBack() }) {
            VStack {
                Text(heights.view == .main ? "more" : "back")
                    .font(.custom("Oligopoly Regular", size: 16))
                    .animation(nil)
                Text("↓")
                    .rotationEffect(Angle(degrees: heights.view == .main ? 0 : 180))
            }
            .padding(.bottom, 35)
            .padding(.horizontal, 150)
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
                        self.switchBack()
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
    
    func switchBack() {
        let backMain: [ViewStates] = [.more,.trainMenu,.train,.solveMenu,.solve,.play]
        withAnimation(.easeInOut(duration: 0.4)) {
            heights.view = backMain.contains(heights.view) ? .main : .more
        }
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
