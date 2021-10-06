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
	var trainGame: Bool { self == .train || self == .trainMenu }
	var solveGame: Bool { self == .solve || self == .solveMenu }
	var playGame: Bool { self == .play || self == .playMenu }
    
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
        .more: (top: .trainView, focus: .moreSpacer, bottom: .feedback),
        .about: (top: .about, focus: .about, bottom: .about),
        .settings: (top: .settings, focus: .settings, bottom: .settings),
        .feedback: (top: .feedback, focus: .feedback, bottom: .feedback),
    ]
}

enum LayoutView: Int, Comparable {
    case topSpacer
    case title, cube, mainSpacer
    case trainView, trainButton, solveView, solveButton, playView, playButton
    case moreSpacer, about, settings, feedback
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
        .moreSpacer: 0,
        .about: moreButtonHeight,
        .settings: moreButtonHeight,
        .feedback: moreButtonHeight,
        .bottomButtons: bottomButtonFrame
    ]
    
    private var focusHeight: [ViewState: CGFloat] = [:]
    private var topSpacerHeight: [ViewState: CGFloat] = [:]
    
    @Published var current: ViewState = .main
    @Published var leftArrows: Bool = Storage.int(.arrowSide) == 0
    @Published var newDaily = Storage.int(.lastDC) != Date.int
	@Published var updateAvailable: Bool = false
	@Published var trainSelection: [Int] = Storage.array(.lastTrainMenu) as? [Int] ?? [0,1,0]
	@Published var solveSelection: [Int] = [0,0]
	@Published var playSelection: [Int] = Storage.array(.lastPlayMenu) as? [Int] ?? [1,1,0,0]
	@Published var searchingOnline: Bool = false
//	@Published var hue: CGFloat = 0.59
//	@Published var sat: CGFloat = 1.0
    var total: CGFloat = 2400
    var fullHeight: CGFloat = 800
    var safeHeight: CGFloat = 800
    var menuHeight: CGFloat = 800
    var width: CGFloat = 0
    private var topGap: CGFloat = 80
	private var bottomGap: CGFloat = 80
    var bottomButtonsOffset: CGFloat {
		let baseOffset = -2*safeHeight + (bottomButtonFrame - bottomButtonSpace)
		// add the amount the start button travels if it's moving with the start button
		return baseOffset + (current.gameView ? mainButtonHeight + bottomButtonSpace + bottomGap : 0)
	}
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
        if current.gameView { return current.top == view ? topGap : 0 }
        return current.top == view ? topGap + (safeHeight-menuHeight)/2 : 0
    }
    
    func bottomOf(_ view: LayoutView) -> CGFloat {
		if current.gameView { return current.bottom == view ? bottomGap : 0 }
        return current.bottom == view ? (safeHeight-menuHeight)/2 : 0
    }
    
    func load(for screen: ScreenObserver) {
        fullHeight = screen.height
        width = screen.width
        topGap = screen.window?.safeAreaInsets.top ?? 0
        bottomGap = screen.window?.safeAreaInsets.bottom ?? 0
		bottomButtonSpace = bottomButtonHeight - bottomGap/3
        safeHeight = fullHeight - topGap - bottomGap
        menuHeight = min(800, safeHeight)
        total = 5*safeHeight
        setLineWidth()
        setCube()
        setFeedbackText()
        setFocusHeights()
        setTopSpacerHeights()
    }
    
    private func setFocusHeights() {
        // set default height of main spacer (this is fucking ONLY necessary for solveMenu)
        defaultHeight[.mainSpacer] = 0
        var space = menuHeight - bottomButtonSpace
        for v in LayoutView.title.rawValue...LayoutView.playButton.rawValue {
            guard let view = LayoutView.init(rawValue: v) else { break }
            space -= defaultHeight[view] ?? 0
        }
        defaultHeight[.mainSpacer] = space
        
        
        // set default height of more spacer
        defaultHeight[.moreSpacer] = 0
        space = menuHeight - bottomButtonSpace
        for v in LayoutView.about.rawValue...LayoutView.feedback.rawValue {
            guard let view = LayoutView.init(rawValue: v) else { break }
            space -= defaultHeight[view] ?? 0
        }
        defaultHeight[.moreSpacer] = space
        
        // use that to calculate everything else
        for state in ViewState.allCases {
            var space = (state.gameView ? safeHeight : menuHeight - bottomButtonSpace) + (defaultHeight[state.focus] ?? 0)
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
    
    private func setLineWidth() {
        switch safeHeight {
        case 734: lineWidth = 0.01      // iPhone X, 11 Pro
        case 814: lineWidth = 0.0072    // iPhone 11 (very light)
        case 818: lineWidth = 0.0088    // iPhone 11 Pro Max
        case 763: lineWidth = 0.0095    // iPhone 12, 12 Pro
        case 845: lineWidth = 0.0087    // iPhone 12 Pro Max
        case 728: lineWidth = 0.01      // iPhone 12 mini
        case 647: lineWidth = 0.0088    // iPhone SE 2nd gen, 8
        case 548: lineWidth = 0.0108    // iPhone SE 1st gen
        case 716: lineWidth = 0.0096    // iPhone 8 Plus
        
        case 776: lineWidth = 0.0072    // hz iPad Air 4th gen
        case 748: lineWidth = 0.008     // hz iPad Pro (9.7 in)
        case 790: lineWidth = 0.0073    // hz iPad Pro (11 in)
        
        case 1060: lineWidth = 0.005    // iPad 8th gen
        case 1136: lineWidth = 0.005    // iPad Air 4th gen
        case 1004: lineWidth = 0.0054   // iPad Pro (9.7 in)
        case 1150: lineWidth = 0.0045   // iPad Pro (11 in)
        case 1322: lineWidth = 0.0039  // iPad Pro (12.9 in)
        default: lineWidth = 0.01*734/safeHeight
        }
        BoardScene.main.resetSpaces()
//        print(safeHeight, width, lineWidth)
//        if fullHeight < 650 {
//            lineWidth = 0.012
//        } else if fullHeight < 700 {
//            lineWidth = 0.009461
//        } else {
//            lineWidth = 0.01
//        }
    }
    
    private func setCube() {
        var cube: CGFloat = fullHeight < 700 ? 200 : 280
        if fullHeight < 600 { cube = 140 }
        defaultHeight[.cube] = cube
    }
    
    private func setFeedbackText() {
        if #available(iOS 14.0, *) {
            if width > fullHeight { // ipads
                feedbackTextSize = (fullHeight-568)/3.0+50
            } else {
                feedbackTextSize = (fullHeight-568)/1.65+90
            }
        } else {
            feedbackTextSize = (fullHeight-568)/2.0+50
        }
        if width > fullHeight { // ipads
            feedbackSpacerSize = 170 - (fullHeight-834)/10
        } else {
            feedbackSpacerSize = (fullHeight-568)/4.5+15
        }
    }
    
	func shouldStartOnlineGame() -> Bool {
		(current == .playMenu || current == .play) && playSelection[0] == 1 && playSelection[1] != 0
	}
	
	func shouldSendInvite() -> Bool {
		current == .playMenu && playSelection[0] == 2
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

