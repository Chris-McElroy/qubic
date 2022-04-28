//
//  TrainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct TrainView: View {
    @ObservedObject var layout = Layout.main
    let beaten = Storage.array(.train) as? [Bool] ?? [false, false, false, false, false, false]
    
    var body: some View {
        if layout.current == .train {
            GameView()
				.onAppear { Game.main.load(mode: mode, turn: turn, hints: hints) }
        } else if layout.current == .trainMenu {
            VStack(spacing: 0) {
                Spacer()
				HPicker(content: .constant(menuText), dim: (90, 55), selected: $layout.trainSelection, action: onSelection)
                    .frame(height: 180)
                    .opacity(layout.current == .trainMenu ? 1 : 0)
            }
			.onAppear { TipStatus.main.updateTip(for: .trainMenu) }
        }
    }
    
    func onSelection(row: Int, component: Int) {
		var newTrainMenu = layout.trainSelection
        newTrainMenu[1] = 1
        Storage.set(newTrainMenu, for: .lastTrainMenu)
    }

    var menuText: [[Any]] {
        [[("novice",    beaten[0]),
          ("defender",  beaten[1]),
          ("warrior",   beaten[2]),
          ("tyrant",    beaten[3]),
          ("oracle",    beaten[4]),
          ("cubist",    beaten[5])],
         ["first", "random", "second"],
         ["sandbox", "challenge"]]
    }
    
    var mode: GameMode {
		switch layout.trainSelection[0] {
		case 0: return .novice // .picture1
		case 1: return .defender
		case 2: return .warrior
		case 3: return .tyrant
        case 4: return .oracle
        default: return .cubist
        }
    }
    
    var turn: Int? {
        switch layout.trainSelection[1] {
        case 0: return 0
        case 2: return 1
        default: return nil
        }
    }
    
    var hints: Bool {
		layout.trainSelection[2] == 0
    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        TrainView()
    }
}
