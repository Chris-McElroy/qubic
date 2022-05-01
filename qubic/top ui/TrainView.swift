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
    @State var beaten = getBeaten()
    
    var body: some View {
		if layout.current == .train {
			GameView()
				.onAppear { Game.main.load(mode: mode, turn: turn, hints: hints) }
		} else if layout.current == .trainMenu {
			VStack(spacing: 0) {
				Spacer()
				HPicker(width: 90, height: 55, selection: $layout.trainSelection[2],
						   labels: ["sandbox", "challenge"], onSelection: onSelection)
				HPicker(width: 90, height: 55, selection: $layout.trainSelection[1],
						   labels: ["first", "random", "second"], onSelection: onSelection)
				HPicker(width: 90, height: 55, selection: $layout.trainSelection[0],
						   labels: ["novice", "defender", "warrior", "tyrant", "oracle", "cubist"],
						   underlines: $beaten, onSelection: onSelection)
				Blank(5)
			}
			.onAppear {
				beaten = TrainView.getBeaten() // this isn't seemingly necessary but it makes me feel better
				TipStatus.main.updateTip(for: .trainMenu)
			}
		}
    }
	
	static func getBeaten() -> [Bool] {
		Storage.array(.train) as? [Bool] ?? [false, false, false, false, false, false]
	}
    
	func onSelection(_: Int) {
		var newTrainMenu = layout.trainSelection
        newTrainMenu[1] = 1
        Storage.set(newTrainMenu, for: .lastTrainMenu)
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
