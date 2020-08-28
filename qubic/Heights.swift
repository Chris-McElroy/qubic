//
//  Heights.swift
//  qubic
//
//  Created by 4 on 8/19/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

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

extension MainView {
    struct Heights {
//        @EnvironmentObject var screen: ScreenObserver
        var screen: ScreenObserver?
        var screenHeight: CGFloat { screen?.height ?? 800 }
        var view: ViewStates = .main
//        private var screen: CGFloat { window.frame.height }
        private var large: Bool { screenHeight > 1000 }
        private var small: Bool { screenHeight < 700 }
        private var defaultTop: CGFloat { screenHeight - (3*mainButtonHeight + mainGaps + bottomGap) }
        private var longMore: [ViewStates] = [.about, .settings, .replays, .friends]
        private var defaultMoreGap: CGFloat {
            mainGaps + ((longMore.contains(view) && !small) ? 20 : 0)
        }
        private let shortMore: CGFloat = 50
        private let bottomGap: CGFloat = 80 // was 88
        
        private var display: Display {
            switch view {
            case .main:      return Display(top: top,       focus: mainGap,   bottom: play)
            case .trainMenu: return Display(top: top,       focus: trainView, bottom: train)
            case .train:     return Display(top: trainView, focus: trainView, bottom: trainView)
            case .solveMenu: return Display(top: top,       focus: solveView, bottom: solve)
            case .solve:     return Display(top: solveView, focus: solveView, bottom: solveView)
            case .play:      return Display(top: playView,  focus: playView,  bottom: playView)
            case .more:      return Display(top: mainGap,   focus: moreFill,  bottom: moreFill)
            case .about:     return Display(top: moreGap,   focus: about,     bottom: friends)
            case .settings:  return Display(top: moreGap,   focus: settings,  bottom: friends)
            case .replays:   return Display(top: moreGap,   focus: replays,   bottom: friends)
            case .friends:   return Display(top: moreGap,   focus: friends,   bottom: friends)
            }
        }
        
        var top:        SubView { SubView(id: 0,  df: defaultTop) }
        var mainGap:    SubView { SubView(id: 1,  df: mainGaps) }
        var trainView:  SubView { SubView(id: 2,  df: 0) }
        var train:      SubView { SubView(id: 3,  df: mainButtonHeight) }
        var solveView:  SubView { SubView(id: 4,  df: 0) }
        var solve:      SubView { SubView(id: 5,  df: mainButtonHeight) }
        var playView:   SubView { SubView(id: 6,  df: 0) }
        var play:       SubView { SubView(id: 7,  df: mainButtonHeight) }
        var moreGap:    SubView { SubView(id: 8,  df: defaultMoreGap) }
        var about:      SubView { SubView(id: 9,  df: shortMore) }
        var settings:   SubView { SubView(id: 10, df: shortMore) }
        var replays:    SubView { SubView(id: 11, df: shortMore) }
        var friends:    SubView { SubView(id: 12, df: shortMore) }
        var moreFill:   SubView { SubView(id: 13, df: shortMore) }
        
        private var subViews: [CGFloat] { [top.df, mainGap.df, trainView.df, train.df, solveView.df, solve.df, playView.df, play.df, moreGap.df, about.df, settings.df, replays.df, friends.df, moreFill.df] }
        
        var total: CGFloat { 3*screenHeight }
        var topSpacer: CGFloat { screenHeight - subViews[0..<display.top.id].sum() }
        var cube: CGFloat { small ? 200 : 280 }
        let fill: CGFloat = 40
        var fillOffset: CGFloat { -2*screenHeight + 83 }
        let backButton: CGFloat = 60
        var backButtonOffset: CGFloat { -screenHeight - 10 }
        
        func get(_ subView: SubView) -> CGFloat {
            if display.focus.id != subView.id { return subView.df }
            else {
                let space = screenHeight - bottomGap + subView.df
                return space - subViews[display.top.id...display.bottom.id].sum()
            }
        }
        
        private struct Display {
            let top: SubView
            let focus: SubView
            let bottom: SubView
        }
        
        struct SubView {
            let id: Int
            let df: CGFloat
        }
    }
}

