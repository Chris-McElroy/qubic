//
//  User.swift
//  qubic
//
//  Created by 4 on 12/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

class User: Player {
    var process: ((Int) -> Void)? = nil
    
    override init(b: Board, n: Int) {
        let name = UserDefaults.standard.string(forKey: usernameKey) ?? "me"
        super.init(b: b, n: n, name: name, color: 0, wins: [], o1CheckMates: [], o1Checks: [])
    }
    
    override func move(with process: @escaping (Int) -> Void) {
        self.process = process
    }
    
    func move(at p: Int) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        process?(p)
        process = nil
    }
}
