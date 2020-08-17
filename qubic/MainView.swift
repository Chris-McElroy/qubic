//
//  MainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct MainView: View {
    // passed in
    @EnvironmentObject var updater: UpdateClass
    let window: UIWindow
    // defined here
    @State var heights = Heights()
    let cube = CubeView()
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: heights.topSpacer)
            displayStack.frame(height: heights.displayStack)
            mainStack.frame(height: heights.mainStack)
            moreStack.frame(height: heights.moreStack)
            Spacer()
            Fill().frame(height: heights.fill)
                .offset(y: heights.fillOffset)
            moreButton.frame(height: heights.moreButton)
                .offset(y: heights.moreButtonOffset)
        }
        .onAppear { self.heights.window = self.window }
        .onAppear { self.heights.view = .main }
        .frame(height: heights.total)
        .background(Fill())
        .gesture(self.scrollGestures)
    }
    
    var displayStack: some View {
        VStack {
            Text("qubic")
                .font(.custom("Oligopoly Regular", size: 24))
                .padding(.top, 70)
            cube
                .onTapGesture(count: 2) { self.cube.resetCube() }
                .frame(height: heights.cube)
            Spacer()
        }
    }
    
    var mainStack: some View {
        VStack {
            TrainView() { self.switchView(to: .train) }
                .frame(height: heights.train, alignment: .bottom)
            SolveView() { self.switchView(to: .solve) }
                .frame(height: heights.solve, alignment: .bottom)
            PlayView() { self.switchView(to: .play) }
                .frame(height: heights.play, alignment: .bottom)
        }
    }
    
    var moreStack: some View {
        VStack {
            Spacer().frame(height: heights.moreSpacer)
            AboutView() { self.switchView(to: .about) }
                .frame(height: heights.about, alignment: .top)
            SettingsView() { self.switchView(to: .settings) }
                .frame(height: heights.settings, alignment: .top)
            ReplaysView() { self.switchView(to: .replays) }
                .frame(height: heights.replays, alignment: .top)
            FriendsView() { self.switchView(to: .friends) }
                .frame(height: heights.friends, alignment: .top)
            Fill()
                .frame(height: heights.moreFill, alignment: .top)
        }
    }
    
    var moreButton: some View {
        Button(action: {
            self.switchView(to: .main, if: self.heights.backMain, else: .more)
        }) {
            VStack {
                Text(heights.view == .main ? "more" : "back")
                    .font(.custom("Oligopoly Regular", size: 16))
                    .animation(nil)
                Text("↓")
                    .rotationEffect(Angle(degrees: heights.view == .main ? 0 : 180))
            }
            .padding(.bottom,30)
            .padding(.horizontal, 150)
            .background(Fill())
            .padding(.top, 5)
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
                        if h > 0 {
                            self.cube.flipCube()
                        } else {
                            self.switchView(to: .more)
                        }
                    } else if h > 0 {
                        self.switchView(to: .main, if: self.heights.backMain, else: .more)
                    }
                } else {
                    self.cube.spinCube(dir: w > 0 ? 1 : -1)
                }
            }
    }
    
    func switchView(to newView: ViewStates, if switchViews: [ViewStates] = [], else otherView: ViewStates? = nil) {
        if switchViews.contains(heights.view) || switchViews == [] {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.heights.view = newView
            }
        } else if otherView != nil {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.heights.view = otherView ?? .main
            }
        }
    }
    
    enum ViewStates {
        case main
        case more
        case train
        case solve
        case play
        case about
        case settings
        case replays
        case friends
    }
    
    struct Heights {
        var window: UIWindow = UIWindow()
        var view: ViewStates = .main
        var showDisplay: [ViewStates] { large ? [] : [.main] }
        var backMain: [ViewStates] = [.more,.train,.solve,.play]
        var longMore: [ViewStates] = [.about, .settings, .replays, .friends]
        var screen: CGFloat { window.frame.height }
        var large: Bool { screen > 1000 }
        var small: Bool { screen < 700 }
        var displayStack: CGFloat {
            large ? 400 : screen-3*shortMain-bottomGap
        }
        var cube: CGFloat {
            small ? 200 : 280
        }
        var displaySpacer: CGFloat {
            showDisplay.contains(view) ? displayStack : 0
        }
        var mainSpacing: CGFloat { 22 }
        var shortMain: CGFloat { MainStyle().height + mainSpacing }
        var bottomGap: CGFloat { 88 }
        var mainSpacer: CGFloat {
            switch view {
            case .more:
                return 3*shortMain+(small ? 0 : mainSpacing)
            case .main:
                return 3*shortMain
            case .train:
                return 3*shortMain
            case .solve:
                return 2*shortMain
            case .play:
                return 1*shortMain
            default:
                return 0
            }
        }
        var mainStack: CGFloat {
            switch view {
            case .train:
                return screen + 2*shortMain - bottomGap
            case .solve:
                return screen + 2*shortMain - bottomGap
            case .play:
                return screen + 2*shortMain - bottomGap
            default:
                return shortMain*3
            }
        }
        var train: CGFloat { view == .train ? screen - bottomGap : shortMain }
        var solve: CGFloat { view == .solve ? screen - bottomGap : shortMain }
        var play:  CGFloat { view == .play  ? screen - bottomGap : shortMain }
        var extra: CGFloat { large ? 0 : (displayStack + 3*shortMain)*2 }
        var total: CGFloat { extra + screen }
        var topSpacer: CGFloat { displaySpacer + mainSpacer }
        var moreStack: CGFloat {
            moreSpacer+about+settings+replays+friends+moreFill
        }
        var moreSpacer: CGFloat { (longMore.contains(view) && !small) ? 30 : 15 }
        var about:    CGFloat { view == .about    ? screen-225-moreSpacer : 50 }
        var settings: CGFloat { view == .settings ? screen-225-moreSpacer : 50 }
        var replays:  CGFloat { view == .replays  ? screen-225-moreSpacer : 50 }
        var friends:  CGFloat { view == .friends  ? screen-225-moreSpacer : 50 }
        var moreFill: CGFloat { 50 }
        var fill: CGFloat { 40 }
        var fillOffset: CGFloat { -extra/2-screen+83 }
        var moreButton: CGFloat { 60 }
        var moreButtonOffset: CGFloat { -extra/2-10 }
    }
}

struct Fill: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.systemBackground)
    }
}

struct MainStyle: ButtonStyle {
    let height: CGFloat = 62
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Oligopoly Regular", size: 24))
            .foregroundColor(.white)
            .frame(width: 200, height: height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: [.init(red: 0.1, green: 0.3, blue: 1), .blue]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(100)
            .shadow(radius: 4, x: 0, y: 3)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

struct MoreStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Oligopoly Regular", size: 20))
            .foregroundColor(.primary)
            .padding(8)
            .opacity(configuration.isPressed ? 0.25 : 1.0)
    }
}

struct Solid: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(1.0)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(window: UIWindow())
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//            .previewDevice("iPhone 11 Pro")
//        MainView(window: UIWindow())
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .preferredColorScheme(.dark)
    }
}
