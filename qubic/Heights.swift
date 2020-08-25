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
        private var totalMain: CGFloat { 3*shortMain + standardGap + bottomGap }
        private var longMore: [ViewStates] = [.about, .settings, .replays, .friends]
        private var moreGap: CGFloat {
            standardGap + ((longMore.contains(view) && !small) ? 20 : 0)
        }
        private let shortMore: CGFloat = 50
        private let bottomGap: CGFloat = 88 // was 88
        
        private var onScreen: Show {
            switch view {
            case .main:         return Show(0,  1,  4, large: large)
            case .trainMenu:    return Show(0,  2,  2, large: large)
            case .train:        return Show(2,  2,  2, large: large)
            case .solveMenu:    return Show(0,  3,  3, large: large)
            case .solve:        return Show(3,  3,  3, large: large)
            case .play:         return Show(4,  4,  4, large: large)
            case .more:         return Show(1, 10, 10, large: large)
            case .about:        return Show(5,  6,  9, large: large)
            case .settings:     return Show(5,  7,  9, large: large)
            case .replays:      return Show(5,  8,  9, large: large)
            case .friends:      return Show(5,  9,  9, large: large)
            }
        }
        
        private var viewList: [CGFloat] {
            [large ? 400 : screen - totalMain,      // 0
             standardGap,                           // 1
             shortMain,                             // 2
             shortMain,                             // 3
             shortMain,                             // 4
             moreGap,                               // 5
             shortMore,                             // 6
             shortMore,                             // 7
             shortMore,                             // 8
             shortMore,                             // 9
             shortMore,                             // 10
             fill,                                  // 11
             moreButton]                            // 12
        }
        
        var total: CGFloat { 3*screen }
        var topSpacer: CGFloat { screen - viewList[0..<onScreen.top].sum() }
        var bottomSpacer: CGFloat { total - topSpacer - get(0...12) }
        var cube: CGFloat { small ? 200 : 280 }
        let fill: CGFloat = 40
        var fillOffset: CGFloat { -2*screen + 83 }
        let moreButton: CGFloat = 60
        var moreButtonOffset: CGFloat { -screen - 10 }
        
        func get(_ id: Int) -> CGFloat {
            if onScreen.focus != id { return viewList[id] }
            else {
                let space = screen - (onScreen.gap ? bottomGap : 0) + viewList[onScreen.focus]
                return space - viewList[onScreen.top...onScreen.bottom].sum()
            }
        }
        
        func get(_ ids: ClosedRange<Int>) -> CGFloat {
            return ids.map({ id in get(id) }).sum()
        }
        
        private struct Show {
            let top: Int
            let focus: Int
            let bottom: Int
            let gap: Bool
            
            init(_ top: Int, _ focus: Int, _ bottom: Int, large: Bool) {
                self.top = large ? 0 : top
                self.focus = focus
                self.bottom = large ? 10 : bottom
                self.gap = top != bottom
            }
        }
    }
}

