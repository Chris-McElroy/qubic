//
//  MainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

let buildNumber = 30302
let versionType: VersionType = .xCode
let solveButtonsEnabled = false

struct MainView: View {
    @ObservedObject var screen: ScreenObserver
    @ObservedObject var game: Game = Game.main
    @ObservedObject var layout = Layout.main
    
    // The delegate required by `MFMessageComposeViewController`
    let messageComposeDelegate = MessageDelegate()
    
    var body: some View {
		if layout.current == .tutorial {
			TutorialView()
				.onAppear { layout.load(for: screen) }
				.onReceive(screen.objectWillChange) { layout.load(for: screen) }
		} else {
			ZStack {
				VStack(alignment: .center, spacing: 0) {
					Spacer().modifier(LayoutModifier(for: .topSpacer))
					top.zIndex(9)
					mainStack.zIndex(1)
					moreStack.zIndex(0)
					Spacer()
					backButton.modifier(LayoutModifier(for: .backButton))
						.offset(y: layout.backButtonOffset)
						.zIndex(10)
				}
				TipView()
			}
			.onAppear { layout.load(for: screen) }
			.onAppear { TipStatus.main.updateTip(for: .main) }
			.onReceive(screen.objectWillChange) { layout.load(for: screen) }
			.frame(height: layout.total)
			.background(Fill())
			.gesture(scrollGestures)
		}
    }
    
    let cube = CubeView()
    
    private var top: some View {
        VStack(spacing: 0) {
			Text("qubic")  // + (versionType == .testFlight ? " beta" : ""))
				.modifier(Oligopoly(size: 42))
                .padding(.top, 10)
                .modifier(LayoutModifier(for: .title))
				.modifier(BoundSize(min: .large, max: .extraExtraExtraLarge))
				.zIndex(3)
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
			layout.current.trainGame ? "  start  " : "  train  "
        }
        
        var solveText: String {
			layout.current.solveGame ? "  start  " : " solve "
        }
        
        var playText: String {
			if layout.searchingOnline {
                return "\u{2009}            "
            } else {
				return layout.current.playGame ? "  start  " : "  \u{2009}\u{2009}\u{2009}play\u{2009}\u{2009}\u{2009}  "
            }
        }
		
		func playAction(view1: ViewState, view2: ViewState) {
			if layout.shouldStartOnlineGame() {
				FB.main.getOnlineMatch(onMatch: { layout.current = .play })
			} else if layout.shouldSendInvite() {
				presentMessageCompose()
			} else { layout.change(to: view1, or: view2) }
		}
        
        return VStack(spacing: 0) {
            TrainView()
                .modifier(LayoutModifier(for: .trainView))
            mainButton(views: [.trainMenu, .train], text: trainText, color: .tertiary(), action: layout.change)
                .modifier(LayoutModifier(for: .trainButton))
                .zIndex(5)
            SolveView()
                .modifier(LayoutModifier(for: .solveView))//, alignment: .bottom)
                .zIndex(0)
            ZStack {
                mainButton(views: [.solveMenu, .solve], text: solveText, color: .secondary(), action: layout.change)
                Circle()
                    .frame(width: 24, height: 24)
                    .foregroundColor(layout.current == .solveMenu ? .secondary() : .primary())
                    .zIndex(2)
                    .offset(x: 88, y: -25)
                    .opacity(layout.newDaily ? 1 : 0)
            }
            .modifier(LayoutModifier(for: .solveButton))
            PlayView()
                .modifier(LayoutModifier(for: .playView)) //, alignment: .bottom)
            ZStack {
				mainButton(views: [.playMenu, .play], text: playText, color: .primary(), action: playAction)
				ActivityIndicator(color: .white, size: .large)
                    .offset(x: 1, y: 1)
					.opacity(layout.searchingOnline ? 1 : 0)
            }
            .modifier(LayoutModifier(for: .playButton))
        }
		.modifier(BoundSize(min: .medium, max: .accessibilityMedium))
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
				.zIndex(10)
            AboutView()
                .frame(alignment: .top)
                .modifier(LayoutModifier(for: .about))
                .zIndex(5)
			FeedbackView()
				.frame(alignment: .top)
				.modifier(LayoutModifier(for: .feedback))
				.zIndex(4)
			TutorialMenuView()
				.frame(alignment: .top)
				.modifier(LayoutModifier(for: .tutorialMenu))
				.zIndex(3)
            SettingsView()
                .frame(alignment: .top)
                .modifier(LayoutModifier(for: .settings))
                .zIndex(2)
			PastGamesView()
				.frame(alignment: .top)
				.modifier(LayoutModifier(for: .pastGames))
				.zIndex(1)
//            FriendsView() { self.switchView(to: .friends) }
//                .frame(height: heights.get(heights.friends), alignment: .top)
        }
		.modifier(BoundSize(min: .medium, max: .accessibilityMedium))
    }

//            VStack {
//                Text("\(layout.hue), \(layout.baseColor)").offset(y: -700)
//                if #available(iOS 14.0, *) {
//                    Slider(value: $layout.baseColor, in: 0.5...1).padding(.horizontal, 20).offset(y: -700)//.onChange(of: layout.baseColor, perform: { layout.hue = $0 })
//                }
//                Slider(value: $layout.hue, in: 0...1).padding(.horizontal, 20).offset(y: -70)
//            }
//        }
    
    private var backButton: some View {
		VStack(spacing: 0) {
			Button(action: layout.goBack) {
				VStack(spacing: 0) {
					ZStack {
						Text(layout.current == .main ? "more" : "back")
							.modifier(Oligopoly(size: 16))
						Circle().frame(width: 12, height: 12).foregroundColor(.primary()).offset(x: 30, y: 2)
							.opacity(layout.current == .main && layout.updateAvailable ? 1 : 0)
					}
					Text("↓")
						.rotationEffect(Angle(degrees: layout.current == .main ? 0 : 180))
				}
				.frame(width: 110, height: backButtonHeight)
				.background(Fill())
			}
			Spacer()
		}
		.modifier(BoundSize(min: .extraSmall, max: .extraExtraLarge))
		.frame(width: layout.width)
		.background(Fill())
		.buttonStyle(Solid())
//            .padding(.horizontal, 0)// halfBack ? 0 : 20)
//            .padding(.bottom, 10)
//            .padding(.top, 5)
    }
    
    var scrollGestures: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { drag in
                let h = drag.translation.height
                let w = drag.translation.width
                if abs(h)/abs(w) > 1 {
                    if self.layout.current == .main {
                        if h < 0 { layout.change(to: .more) }
                        else { self.cube.flipCube() }
                    } else if h > 0 || self.layout.current.menuView {
						self.layout.goBack()
                    }
                } else {
                    self.cube.rotate(right: w > 0)
                }
            }
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
