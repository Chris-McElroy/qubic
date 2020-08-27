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
        var window: UIWindow = UIWindow()
        var view: ViewStates = .main
        private var screen: CGFloat { window.frame.height }
        private var large: Bool { screen > 1000 }
        private var small: Bool { screen < 700 }
        private let standardGap: CGFloat = 22
        private var shortMain: CGFloat { MainStyle().height + standardGap }
        private var defaultTop: CGFloat { screen - (3*shortMain + standardGap + bottomGap) }
        private var longMore: [ViewStates] = [.about, .settings, .replays, .friends]
        private var defaultMoreGap: CGFloat {
            standardGap + ((longMore.contains(view) && !small) ? 20 : 0)
        }
        private let shortMore: CGFloat = 50
        private let bottomGap: CGFloat = 88 // was 88
        private let fill: CGFloat = 40
        private let defaultBack: CGFloat = 60
        
        private var display: Display {
            switch view {
            case .main:      return Display(top: top,     focus: mainGap,  bottom: play)
            case .trainMenu: return Display(top: top,     focus: train,    bottom: train)
            case .train:     return Display(top: train,   focus: train,    bottom: train)
            case .solveMenu: return Display(top: top,     focus: solve,    bottom: solve)
            case .solve:     return Display(top: solve,   focus: solve,    bottom: solve)
            case .play:      return Display(top: play,    focus: play,     bottom: play)
            case .more:      return Display(top: mainGap, focus: moreFill, bottom: moreFill)
            case .about:     return Display(top: moreGap, focus: about,    bottom: friends)
            case .settings:  return Display(top: moreGap, focus: settings, bottom: friends)
            case .replays:   return Display(top: moreGap, focus: replays,  bottom: friends)
            case .friends:   return Display(top: moreGap, focus: friends,  bottom: friends)
            }
        }
        
        var top:        SubView { SubView(df: defaultTop,     id: 0) }
        var mainGap:    SubView { SubView(df: standardGap,    id: 1) }
        var train:      SubView { SubView(df: shortMain,      id: 2) }
        var solve:      SubView { SubView(df: shortMain,      id: 3) }
        var play:       SubView { SubView(df: shortMain,      id: 4) }
        var moreGap:    SubView { SubView(df: defaultMoreGap, id: 5) }
        var about:      SubView { SubView(df: shortMore,      id: 6) }
        var settings:   SubView { SubView(df: shortMore,      id: 7) }
        var replays:    SubView { SubView(df: shortMore,      id: 8) }
        var friends:    SubView { SubView(df: shortMore,      id: 9) }
        var moreFill:   SubView { SubView(df: shortMore,      id: 10) }
        var topFill:    SubView { SubView(df: fill,           id: 11) }
        var back:       SubView { SubView(df: defaultBack,    id: 12) }
        
        private var subViews: [CGFloat] {
            [top.df, mainGap.df, train.df, solve.df, play.df, moreGap.df, about.df, settings.df, replays.df, friends.df, moreFill.df, topFill.df, back.df]
        }
        
        var total: CGFloat { 3*screen }
        var topSpacer: CGFloat { screen - subViews[0..<display.top.id].sum() }
        var cube: CGFloat { small ? 200 : 280 }
        var fillOffset: CGFloat { -2*screen + 83 }
        var moreButtonOffset: CGFloat { -screen - 10 }
        
        func get(_ subView: SubView) -> CGFloat {
            if display.focus.id != subView.id { return subView.df }
            else {
                let space = screen - bottomGap + subView.df
                return space - subViews[display.top.id...display.bottom.id].sum()
            }
        }
        
        private struct Display {
            let top: SubView
            let focus: SubView
            let bottom: SubView
        }
        
        struct SubView {
            let df: CGFloat
            let id: Int
        }
    }
}

