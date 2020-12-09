//
//  Beginner.swift
//  qubic
//
//  Created by 4 on 12/9/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation

extension Board {
    func getBeginnerPause() -> Double {
        Double.random(in: 0.5..<1.8)
    }
    
    func getBeginnerMove() -> Int {
        let options = Array(0..<64).filter { !pointFull($0) }
        return options.randomElement() ?? 0
    }
}
