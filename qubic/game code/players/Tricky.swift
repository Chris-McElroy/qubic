//
//  Tricky.swift
//  qubic
//
//  Created by 4 on 12/16/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

class Tricky: Cubist {
    init(b: Board, n: Int, num: Int) {
		let localName = num == solveBoards[.tricky]?.count ?? 0 ? "tricky ?" : "tricky \(num+1)"
		super.init(b: b, n: n, id: localName, name: localName, color: 1)
    }
    
    override func getPause() -> Double {
        .random(in: b.hasW1(n^1) ? 0.4..<0.7 : 2.0..<2.1)
    }
    
//    override func unforcedHeuristic() -> Int {
//        let rich = (0..<64).filter {  Board.rich.contains($0) && b.pointEmpty($0) }
//        let poor = (0..<64).filter { !Board.rich.contains($0) && b.pointEmpty($0) }
//        return rich.isEmpty ? poor.randomElement() ?? 0 : rich.randomElement() ?? 0
//    }
}
