//
//  User.swift
//  qubic
//
//  Created by 4 on 12/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

class User: Player {
    var process: ((Int, Int) -> Void)? = nil
    
    override init(b: Board, n: Int) {
        let name = UserDefaults.standard.string(forKey: usernameKey) ?? "me"
        super.init(b: b, n: n, name: name, color: 0, lineP: [:], dirStats: [], depth: 0, w2BlockP: 0, lineScore: [], bucketP: 0)
    }
    
    override func move(with process: @escaping (Int, Int) -> Void) {
        self.process = process
    }
    
    func move(at p: Int) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        process?(p, n)
        process = nil
    }
}
