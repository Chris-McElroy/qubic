//
//  Heights.swift
//  qubic
//
//  Created by 4 on 8/19/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

extension MainView {
    struct Heights {
        var window: UIWindow = UIWindow()
        var view: ViewStates = .main
        private var screen: CGFloat { window.frame.height }
        private var large: Bool { screen > 1000 }
        private var small: Bool { screen < 700 }
        private let standardGap: CGFloat = 22
        private var shortMain: CGFloat { MainStyle().height + standardGap }
        private var totalMain: CGFloat { 3*shortMain + standardGap + bottomGap }
        private let shortMore: CGFloat = 50
        private let bottomGap: CGFloat = 88
        
        private var onScreen: Show {
            switch view {
            case .main:         return Show(top: 0, focus: 1,  bottom: 4,  gap: true)
            case .trainMenu:    return Show(top: 0, focus: 2,  bottom: 2,  gap: true)
            case .train:        return Show(top: 2, focus: 2,  bottom: 2,  gap: false)
            case .solveMenu:    return Show(top: 0, focus: 3,  bottom: 3,  gap: true)
            case .solve:        return Show(top: 3, focus: 3,  bottom: 3,  gap: false)
            case .play:         return Show(top: 4, focus: 4,  bottom: 4,  gap: false)
            case .more:         return Show(top: 1, focus: 10, bottom: 10, gap: true)
            case .about:        return Show(top: 5, focus: 6,  bottom: 9, gap: true)
            case .settings:     return Show(top: 5, focus: 7,  bottom: 9, gap: true)
            case .replays:      return Show(top: 5, focus: 8,  bottom: 9, gap: true)
            case .friends:      return Show(top: 5, focus: 9,  bottom: 9, gap: true)
            }
        }
        
        private var viewList: [CGFloat] {
            [large ? 400 : screen - totalMain,
             standardGap,
             shortMain,
             shortMain,
             shortMain,
             standardGap, // was (longMore.contains(view) && !small) ? 30 : 15
             shortMore,
             shortMore,
             shortMore,
             shortMore,
             shortMore]
        }
        
        var total: CGFloat { 3*screen }
        var topSpacer: CGFloat { viewList[0..<onScreen.top].reduce(screen,-) }
        var cube: CGFloat { small ? 200 : 280 }
        let fill: CGFloat = 40
        var fillOffset: CGFloat { -2*screen + 83 }
        let moreButton: CGFloat = 60
        var moreButtonOffset: CGFloat { -screen - 10 }
        
        func get(_ id: Int) -> CGFloat {
            if onScreen.focus != id { return viewList[id] }
            else {
                let space = screen - (onScreen.gap ? bottomGap : 0) + viewList[onScreen.focus]
                return viewList[onScreen.top...onScreen.bottom].reduce(space,-)
            }
        }
        
        private struct Show {
            let top: Int
            let focus: Int
            let bottom: Int
            let gap: Bool
        }
    }
}

