//
//  TutorialPlayer.swift
//  qubic
//
//  Created by Chris McElroy on 1/28/22.
//  Copyright © 2022 XNO LLC. All rights reserved.
//

import Foundation

class TutorialPlayer: Player {
	override init(b: Board, n: Int) {
		super.init(b: b, n: n, name: "opponent", color: 6, //3?
				   // TODO change these?
				   lineP: [3: 1.0, -3: 0.9, 2: 0.20],
				   dirStats: Player.setStats(hs: 0.98, vs: 0.65, hd: 0.95, vd: 0.20, md: 0.25),
				   depth: 1,
				   w2BlockP: 0.2,
				   lineScore: [0,0,2,1,1,1,2,0,0], // my points on the left
				   bucketP: 0.4)
	}
	
//	override func getPause() -> Double {
//		print("getting pause for tutorial player")
//		return 1.0
//	}
	
	override func move() {
		
	}
}
