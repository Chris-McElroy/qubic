//
//  LayoutHelper.swift
//  qubic
//
//  Created by 4 on 8/19/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

enum ViewState {
    case main
    case more
    case trainMenu
    case train
    case solveMenu
    case solve
    case playMenu
    case play
    case about
    case settings
    case feedback
//    case replays
//    case friends
    
    var gameView: Bool { [.play, .solve, .train].contains(self) }
    var menuView: Bool { [.playMenu, .solveMenu, .trainMenu].contains(self) }
    
    var back: ViewState {
        switch self {
        case .main: return .more
        case .train: return .trainMenu
        case .solve: return .solveMenu
        case .play: return .playMenu
        case .about: return .more
        case .settings: return .more
        case .feedback: return .more
        default: return .main
        }
    }
}

class Layout: ObservableObject {
    static var main = Layout()
    
    var top       = SubView(id: 0,  df: 0)
    let trainView = SubView(id: 1,  df: 0)
    let train     = SubView(id: 2,  df: mainButtonHeight)
    let solveView = SubView(id: 3,  df: 0)
    let solve     = SubView(id: 4,  df: mainButtonHeight)
    let playView  = SubView(id: 5,  df: 0)
    let play      = SubView(id: 6,  df: mainButtonHeight)
    let about     = SubView(id: 7,  df: moreButtonHeight)
    let settings  = SubView(id: 8,  df: moreButtonHeight)
    let feedback  = SubView(id: 9,  df: moreButtonHeight)
//        let replays   = SubView(id: 9,  df: moreButtonHeight)
//        let friends   = SubView(id: 10, df: moreButtonHeight)
    let moreFill  = SubView(id: 10, df: moreButtonHeight)
    
    @Published var view: ViewState = .main
    @Published var leftArrows: Bool = UserDefaults.standard.integer(forKey: Key.arrowSide) == 0
    var total: CGFloat = 2400
    var topSpacer: CGFloat { 2*screen - subViews[0..<display.top.id].sum() }
    var cube: CGFloat = 0
    let fill: CGFloat = 40
    var fillOffset: CGFloat = 0
    var bottomWidth: CGFloat = 0
    let backButton: CGFloat = 60
    var backButtonOffset: CGFloat = -800
    var feedbackTextSize: CGFloat = 90
    var feedbackSpacerSize: CGFloat = 15
    private var subViews: [CGFloat] = Array(repeating: 0, count: 10)
    private var screen: CGFloat = 800
    private var bottomGap: CGFloat = 80
    
    init() {}
    
    func load(for screen: ScreenObserver) {
        let screenHeight = screen.height
        let small = screenHeight < 700
        let topGap: CGFloat = small ? 10 : 30
        bottomWidth = screen.width
        bottomGap = 80 - topGap
        self.screen = screenHeight - 2*topGap
        setLineWidth(screenHeight)
        top.df = self.screen - 3*mainButtonHeight - bottomGap
        total = 5*self.screen
        cube = small ? 200 : 280
        if screenHeight < 600 { cube = 140 }
        fillOffset = -3*self.screen + 83 - 2*topGap
        backButtonOffset = -2*self.screen - 10 + topGap
        feedbackTextSize = (screenHeight-568)/1.65+90
        feedbackSpacerSize = (screenHeight-568)/4.5+15
        subViews = [top.df, trainView.df, train.df, solveView.df, solve.df, playView.df, play.df, about.df, settings.df, feedback.df, moreFill.df]
    }
    
    private var display: Display {
        switch view {
        case .main:      return Display(top: top,       focus: top,       bottom: play)
        case .trainMenu: return Display(top: top,       focus: trainView, bottom: train)
        case .train:     return Display(top: trainView, focus: trainView, bottom: trainView)
        case .solveMenu: return Display(top: top,       focus: solveView, bottom: solve)
        case .solve:     return Display(top: solveView, focus: solveView, bottom: solveView)
        case .playMenu:  return Display(top: playView,  focus: playView,  bottom: play)
        case .play:      return Display(top: playView,  focus: playView,  bottom: playView)
        case .more:      return Display(top: train,     focus: moreFill,  bottom: moreFill)
        case .about:     return Display(top: about,     focus: about,     bottom: about)
        case .settings:  return Display(top: settings,  focus: settings,  bottom: settings)
        case .feedback:  return Display(top: feedback,  focus: feedback,  bottom: feedback)
//            case .replays:   return Display(top: about,     focus: replays,   bottom: friends)
//            case .friends:   return Display(top: about,     focus: friends,   bottom: friends)
        }
    }
    
    func get(_ subView: SubView) -> CGFloat {
        if display.focus.id != subView.id { return subView.df }
        else {
            let space = screen - bottomGap + subView.df
            return space - subViews[display.top.id...display.bottom.id].sum()
        }
    }
    
    struct SubView {
        let id: Int
        var df: CGFloat
    }
    
    private struct Display {
        let top: SubView
        let focus: SubView
        let bottom: SubView
    }
}

