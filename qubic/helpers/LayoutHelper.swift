//
//  LayoutHelper.swift
//  qubic
//
//  Created by 4 on 8/19/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

enum ViewState: CaseIterable {
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
    
    var gameView: Bool { self == .play || self == .solve || self == .train }
    var menuView: Bool { self == .playMenu || self == .solveMenu || self == .trainMenu }
    
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
    
    var top: LayoutView {
        ViewState.viewsDict[self]?.top ?? .title
    }
    
    var focus: LayoutView {
        ViewState.viewsDict[self]?.focus ?? .mainSpacer
    }
    
    var bottom: LayoutView {
        ViewState.viewsDict[self]?.bottom ?? .playButton
    }
    
    private static let viewsDict: [ViewState: (top: LayoutView, focus: LayoutView, bottom: LayoutView)] = [
        .main: (top: .title, focus: .mainSpacer, bottom: .playButton),
        .trainMenu: (top: .title, focus: .trainView, bottom: .trainButton),
        .train: (top: .trainView, focus: .trainView, bottom: .trainView),
        .solveMenu: (top: .title, focus: .solveView, bottom: .solveButton),
        .solve: (top: .solveView, focus: .solveView, bottom: .solveView),
        .playMenu: (top: .playView, focus: .playView, bottom: .playButton),
        .play: (top: .playView, focus: .playView, bottom: .playView),
        .more: (top: .trainView, focus: .moreSpacer, bottom: .moreSpacer),
        .about: (top: .about, focus: .about, bottom: .about),
        .settings: (top: .settings, focus: .settings, bottom: .settings),
        .feedback: (top: .feedback, focus: .feedback, bottom: .feedback),
    ]
}

enum LayoutView: Int, Comparable {
    case topSpacer
    case title, cube, mainSpacer
    case trainView, trainButton, solveView, solveButton, playView, playButton
    case about, settings, feedback, moreSpacer
    case bottomButtons
    
    static func < (lhs: LayoutView, rhs: LayoutView) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct LayoutModifier: ViewModifier {
    let top: CGFloat
    let main: CGFloat
    let bottom: CGFloat
    
    init(for view: LayoutView) {
        top = Layout.main.topOf(view)
        main = Layout.main.heightOf(view)
        bottom = Layout.main.bottomOf(view)
        
        if main < 0 { print(view, main) }
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: top)
            content.frame(height: main)
            Spacer().frame(height: bottom)
        }
    }
}

class Layout: ObservableObject {
    static var main = Layout()
    
    private var defaultHeight: [LayoutView: CGFloat] = [
        .topSpacer: 0,
        .title: 50,
        .cube: 200,
        .mainSpacer: 0,
        .trainView: 0,
        .trainButton: mainButtonHeight,
        .solveView: 0,
        .solveButton: mainButtonHeight,
        .playView: 0,
        .playButton: mainButtonHeight,
        .about: moreButtonHeight,
        .settings: moreButtonHeight,
        .feedback: moreButtonHeight,
        .moreSpacer: 0,
        .bottomButtons: bottomButtonFrame
    ]
    
    private var focusHeight: [ViewState: CGFloat] = [:]
    private var topSpacerHeight: [ViewState: CGFloat] = [:]
    
    @Published var current: ViewState = .main
    @Published var leftArrows: Bool = UserDefaults.standard.integer(forKey: Key.arrowSide) == 0
    var total: CGFloat = 2400
    var fullHeight: CGFloat = 800
    var safeHeight: CGFloat = 800
    var menuHeight: CGFloat = 800
    var width: CGFloat = 0
    private var topGap: CGFloat = 80
    private var bottomGap: CGFloat = 80
    var bottomButtonsOffset: CGFloat = -800
    var feedbackTextSize: CGFloat = 90
    var feedbackSpacerSize: CGFloat = 15
    
    init() {}
    
    func heightOf(_ view: LayoutView) -> CGFloat {
        switch view {
        case .topSpacer:    return topSpacerHeight[current] ?? 0
        case current.focus: return focusHeight[current] ?? 0
        default:            return defaultHeight[view] ?? 0
        }
    }
    
    func topOf(_ view: LayoutView) -> CGFloat {
//        if current.gameView { return 0 }
        return current.top == view ? topGap : 0
    }
    
    func bottomOf(_ view: LayoutView) -> CGFloat {
//        if current.gameView { return 0 }
        return current.bottom == view ? 0 : 0 // I'm not convinced a bottom gap is useful in any cases
    }
    
    func load(for screen: ScreenObserver) {
        fullHeight = screen.height
        width = screen.width
        topGap = screen.window?.safeAreaInsets.top ?? 0
        bottomGap = screen.window?.safeAreaInsets.bottom ?? 0
        safeHeight = fullHeight - topGap - bottomGap
        menuHeight = safeHeight
        total = 5*safeHeight
        setLineWidth()
        setCube()
        setFeedbackText()
        setOffsets()
        setFocusHeights()
        setTopSpacerHeights()
        print(topSpacerHeight[.main] ?? 0)
//        print(defaultHeight[.topSpacer])
        print(fullHeight, topGap, bottomGap, safeHeight, total)
    }
    
    private func setFocusHeights() {
        // set default height of main spacer (this is fucking ONLY necessary for solveMenu)
        var space = menuHeight - bottomButtonSpace
        for v in LayoutView.title.rawValue...LayoutView.playButton.rawValue {
            guard let view = LayoutView.init(rawValue: v) else { break }
            space -= defaultHeight[view] ?? 0
        }
        defaultHeight[.mainSpacer] = space
        
        // use that to calculate everything else
        for state in ViewState.allCases {
            var space = (state.gameView ? safeHeight : menuHeight) - bottomButtonSpace + (defaultHeight[state.focus] ?? 0)
            for v in state.top.rawValue...state.bottom.rawValue {
                guard let view = LayoutView.init(rawValue: v) else { break }
                space -= defaultHeight[view] ?? 0
            }
            focusHeight[state] = space
        }
    }
    
    private func setTopSpacerHeights() {
        for state in ViewState.allCases {
            var space = 2*safeHeight - topGap
            for v in 0..<state.top.rawValue {
                guard let view = LayoutView.init(rawValue: v) else { break }
                space -= defaultHeight[view] ?? 0
            }
            topSpacerHeight[state] = space
        }
    }
    
    private func setOffsets() {
//        fillOffset = -3*mainHeight + 83 - 2*topGap
        bottomButtonSpace = bottomButtonHeight - bottomGap/2
        bottomButtonsOffset = -2*safeHeight + (bottomButtonFrame - bottomButtonSpace)
    }
    
    private func setLineWidth() {
        if fullHeight < 650 {
            lineWidth = 0.012
        } else if fullHeight < 700 {
            lineWidth = 0.009461
        } else {
            lineWidth = 0.01
        }
    }
    
    private func setCube() {
        var cube: CGFloat = fullHeight < 700 ? 200 : 280
        if fullHeight < 600 { cube = 140 }
        defaultHeight[.cube] = cube
    }
    
    private func setFeedbackText() {
        if #available(iOS 14.0, *) {
            feedbackTextSize = (fullHeight-568)/1.65+90
        } else {
            feedbackTextSize = (fullHeight-568)/2.0+50
        }
        feedbackSpacerSize = (fullHeight-568)/4.5+15
    }
    
}



//    var top       = SubView(id: 0,  df: 0)
//    let trainView = SubView(id: 1,  df: 0)
//    let train     = SubView(id: 2,  df: mainButtonHeight)
//    let solveView = SubView(id: 3,  df: 0)
//    let solve     = SubView(id: 4,  df: mainButtonHeight)
//    let playView  = SubView(id: 5,  df: 0)
//    let play      = SubView(id: 6,  df: mainButtonHeight)
//    let about     = SubView(id: 7,  df: moreButtonHeight)
//    let settings  = SubView(id: 8,  df: moreButtonHeight)
//    let feedback  = SubView(id: 9,  df: moreButtonHeight)
//    let moreFill  = SubView(id: 10, df: moreButtonHeight)

//    var topSpacer: CGFloat { 2*mainHeight - subViews[0..<display.top.id].sum() }

//        top.df = mainHeight - 3*mainButtonHeight - bottomGap

//        subViews = [top.df, trainView.df, train.df, solveView.df, solve.df, playView.df, play.df, about.df, settings.df, feedback.df, moreFill.df]

//    private var display: Display {
//        switch current {
//        case .main:      return Display(top: top,       focus: top,       bottom: play)
//        case .trainMenu: return Display(top: top,       focus: trainView, bottom: train)
//        case .train:     return Display(top: trainView, focus: trainView, bottom: trainView)
//        case .solveMenu: return Display(top: top,       focus: solveView, bottom: solve)
//        case .solve:     return Display(top: solveView, focus: solveView, bottom: solveView)
//        case .playMenu:  return Display(top: playView,  focus: playView,  bottom: play)
//        case .play:      return Display(top: playView,  focus: playView,  bottom: playView)
//        case .more:      return Display(top: train,     focus: moreFill,  bottom: moreFill)
//        case .about:     return Display(top: about,     focus: about,     bottom: about)
//        case .settings:  return Display(top: settings,  focus: settings,  bottom: settings)
//        case .feedback:  return Display(top: feedback,  focus: feedback,  bottom: feedback)
//        }
//    }
//
//
//    func get(_ subView: SubView) -> CGFloat {
//        if display.focus.id != subView.id { return subView.df }
//        else {
//            let space = mainHeight - bottomGap + subView.df
//            return space - subViews[display.top.id...display.bottom.id].sum()
//        }
//    }
//
//    struct SubView {
//        let id: Int
//        var df: CGFloat
//    }
//
//    private struct Display {
//        let top: SubView
//        let focus: SubView
//        let bottom: SubView
//    }

