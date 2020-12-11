//
//  HeightHelper.swift
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
        var top       = SubView(id: 0,  df: 0)
        let trainView = SubView(id: 1,  df: 0)
        let train     = SubView(id: 2,  df: mainButtonHeight)
        let solveView = SubView(id: 3,  df: 0)
        let solve     = SubView(id: 4,  df: mainButtonHeight)
        let playView  = SubView(id: 5,  df: 0)
        let play      = SubView(id: 6,  df: mainButtonHeight)
        let about     = SubView(id: 7,  df: moreButtonHeight)
        let settings  = SubView(id: 8,  df: moreButtonHeight)
        let replays   = SubView(id: 9,  df: moreButtonHeight)
        let friends   = SubView(id: 10, df: moreButtonHeight)
        let moreFill  = SubView(id: 11, df: moreButtonHeight)
        
        var view: ViewStates = .main
        var total: CGFloat
        var topSpacer: CGFloat { screen - subViews[0..<display.top.id].sum() }
        var cube: CGFloat
        let fill: CGFloat = 40
        var fillOffset: CGFloat
        let backButton: CGFloat = 60
        var backButtonOffset: CGFloat
        private var subViews: [CGFloat]
        private var screen: CGFloat
        private var bottomGap: CGFloat
        
        init(newScreen: ScreenObserver? = nil) {
            let screenHeight = newScreen?.height ?? 800
            let small = screenHeight < 700
            let topGap: CGFloat = small ? 10 : 30
            bottomGap = 80 - topGap
            screen = screenHeight - 2*topGap
            top.df = screen - 3*mainButtonHeight - bottomGap
            total = 3*screen
            cube = small ? 200 : 280
            if screenHeight < 600 { cube = 140 }
            fillOffset = -2*screen + 83 - 2*topGap
            backButtonOffset = -screen - 10 + topGap
            subViews = [top.df, trainView.df, train.df, solveView.df, solve.df, playView.df, play.df, about.df, settings.df, replays.df, friends.df, moreFill.df]
        }
        
        private var display: Display {
            switch view {
            case .main:      return Display(top: top,       focus: top,       bottom: play)
            case .trainMenu: return Display(top: top,       focus: trainView, bottom: train)
            case .train:     return Display(top: trainView, focus: trainView, bottom: trainView)
            case .solveMenu: return Display(top: top,       focus: solveView, bottom: solve)
            case .solve:     return Display(top: solveView, focus: solveView, bottom: solveView)
            case .play:      return Display(top: playView,  focus: playView,  bottom: playView)
            case .more:      return Display(top: train,     focus: moreFill,  bottom: moreFill)
            case .about:     return Display(top: about,     focus: about,     bottom: friends)
            case .settings:  return Display(top: about,     focus: settings,  bottom: friends)
            case .replays:   return Display(top: about,     focus: replays,   bottom: friends)
            case .friends:   return Display(top: about,     focus: friends,   bottom: friends)
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
}

