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
    @State var heights: Heights = Heights()
    @State var showGame: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: heights.topSpacer)
            displayStack
            mainStack
            moreStack
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
    
    let cube = CubeView()
    
    private var displayStack: some View {
        VStack {
            Text("qubic")
                .font(.custom("Oligopoly Regular", size: 24))
                .padding(.top, 70)
            cube
                .onTapGesture(count: 2) { self.cube.resetCube() }
                .frame(height: heights.cube)
            Spacer()
        }.frame(height: heights.get(0))
    }
    
    private var mainStack: some View {
        VStack {
            Spacer()
                .frame(height: heights.get(1))
            TrainView() { self.switchView(to: .trainMenu) }
                .frame(height: heights.get(2), alignment: .bottom)
            SolveView() { self.switchView(to: .solveMenu) }
                .frame(height: heights.get(3), alignment: .bottom)
            VStack {
                if self.heights.view == .play {
                    Spacer()
                    GameView().frame(height: 700)
                    Spacer()
                }
                PlayView() { self.switchView(to: .play, if: [.play], else: .play) }
                    
            }.frame(height: heights.get(4), alignment: .bottom)
        }
    }
    
    private var moreStack: some View {
        VStack {
            Spacer().frame(height: heights.get(5))
            AboutView() { self.switchView(to: .about) }
                .frame(height: heights.get(6), alignment: .top)
            SettingsView() { self.switchView(to: .settings) }
                .frame(height: heights.get(7), alignment: .top)
            ReplaysView() { self.switchView(to: .replays) }
                .frame(height: heights.get(8), alignment: .top)
            FriendsView() { self.switchView(to: .friends) }
                .frame(height: heights.get(9), alignment: .top)
            Fill()
                .frame(height: heights.get(10), alignment: .top)
        }
    }
    
    private var moreButton: some View {
        Button(action: {
            self.switchView(to: .main, if: self.backMain, else: .more)
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
                        if h > 0 { self.cube.flipCube() }
                        else { self.switchView(to: .more) }
                    } else if h > 0 {
                        self.switchView(to: .main, if: self.backMain, else: .more)
                    }
                } else {
                    self.cube.rotate(right: w > 0)
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
        case trainMenu
        case train
        case solveMenu
        case solve
        case play
        case about
        case settings
        case replays
        case friends
    }
    
    var backMain: [ViewStates] = [.more,.trainMenu,.train,.solveMenu,.solve,.play]
}
    
//    struct ShowGame<SomeView: View>: ViewModifier {
//        @Binding var binding: Bool
//
//        func body(content: Content) -> some View {
//            NavigationView {
//                ZStack {
//                    content
//                        .navigationBarTitle("")
//                        .navigationBarHidden(true)
//                    NavigationLink(
//                        destination: GameView()
//                            .navigationBarTitle("")
//                            .navigationBarHidden(true),
//                        isActive: $binding) { EmptyView() }
//                }
//            }
//        }
//    }

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
