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
    @State private var heights = Heights()
    @State private var showGame: Bool = false
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
//        .modifier(ShowGame<GameView>(binding: $showGame))
    }
    
    private var displayStack: some View {
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
    
    private var mainStack: some View {
        VStack {
            TrainView() { self.switchView(to: .train) }
                .frame(height: heights.train, alignment: .bottom)
            SolveView() { self.switchView(to: .solve) }
                .frame(height: heights.solve, alignment: .bottom)
            VStack {
                if self.heights.view == .play {
                    Spacer()
                    GameView().frame(height: 700)
                    Spacer()
                }
                PlayView() { self.switchView(to: .main, if: [.play], else: .play) }
                    
            }.frame(height: heights.play, alignment: .bottom)
        }
    }
    
    private var moreStack: some View {
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
    
    private var moreButton: some View {
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
    
    private var scrollGestures: some Gesture {
        DragGesture()
            .onEnded { drag in
                let h = drag.predictedEndTranslation.height
                let w = drag.predictedEndTranslation.width
                if abs(h)/abs(w) > 1 {
                    if self.heights.view == .main {
                        if h > 0 { self.cube.flipCube() }
                        else { self.switchView(to: .more) }
                    } else if h > 0 {
                        self.switchView(to: .main, if: self.heights.backMain, else: .more)
                    }
                } else {
                    self.cube.rotate(right: w > 0)
                }
            }
    }
    
    private func switchView(to newView: ViewStates, if switchViews: [ViewStates] = [], else otherView: ViewStates? = nil) {
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
    
    private enum ViewStates {
        case main
        case more
        case train
        case trainGame
        case solve
        case solveGame
        case play
        case about
        case settings
        case replays
        case friends
    }
    
    private struct Heights {
        var window: UIWindow = UIWindow()
        var view: ViewStates = .main
        var showDisplay: [ViewStates] { large ? [] : [.main, .train, .solve] }
        var backMain: [ViewStates] = [.more,.train,.solve,.play]
        var longMore: [ViewStates] = [.about, .settings, .replays, .friends]
        var screen: CGFloat { window.frame.height }
        var total: CGFloat { 3*screen }
        var large: Bool { screen > 1000 }
        var small: Bool { screen < 700 }
        var topSpacer: CGFloat { screen - displayHider - mainHider }
        var bottomGap: CGFloat { 88 }
        var displayStack: CGFloat {
            large ? 400 : screen - 3*shortMain - bottomGap
        }
        var cube: CGFloat { small ? 200 : 280 }
        var displayHider: CGFloat {
            showDisplay.contains(view) ? 0 : displayStack
        }
        var mainSpacing: CGFloat = 22
        var shortMain: CGFloat { MainStyle().height + mainSpacing }
        var mainHider: CGFloat {
            switch view {
            case .more:
                return -(small ? 0 : mainSpacing)
            case .main, .train, .solve:
                return 0
            case .play:
                return 2*shortMain
            default:
                return 3*shortMain
            }
        }
        var mainStack: CGFloat { train + solve + play }
        var train: CGFloat {
            switch view {
            case .train:
                return 3*shortMain
            case .trainGame:
                return screen
            default:
                return shortMain
            }
        }
        var solve: CGFloat {
            switch view {
            case .solve:
                return 2*shortMain
            case .solveGame:
                return screen
            default:
                return shortMain
            }
        }
        var play:  CGFloat { view == .play ? screen : shortMain }
        var moreStack: CGFloat {
            moreSpacer + about + settings + replays + friends + moreFill
        }
        var moreSpacer: CGFloat { (longMore.contains(view) && !small) ? 30 : 15 }
        var largeMore: CGFloat { screen - 225 - moreSpacer }
        var smallMore: CGFloat = 50
        var about:    CGFloat { view == .about    ? largeMore : smallMore }
        var settings: CGFloat { view == .settings ? largeMore : smallMore }
        var replays:  CGFloat { view == .replays  ? largeMore : smallMore }
        var friends:  CGFloat { view == .friends  ? largeMore : smallMore }
        var moreFill: CGFloat { smallMore }
        var fill: CGFloat = 40
        var fillOffset: CGFloat { -2*screen + 83 }
        var moreButton: CGFloat = 60
        var moreButtonOffset: CGFloat { -screen - 10 }
    }
    
    struct ShowGame<SomeView: View>: ViewModifier {
        @Binding var binding: Bool

        func body(content: Content) -> some View {
            NavigationView {
                ZStack {
                    content
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                    NavigationLink(
                        destination: GameView()
                            .navigationBarTitle("")
                            .navigationBarHidden(true),
                        isActive: $binding) { EmptyView() }
                }
            }
        }
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
