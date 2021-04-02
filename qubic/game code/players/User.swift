//
//  User.swift
//  qubic
//
//  Created by 4 on 12/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

class User: Player {
    var process: ((Int, UInt64) -> Void)? = nil
    
    init(b: Board, n: Int, name: String? = nil) {
        var username = UserDefaults.standard.string(forKey: Key.name) ?? "you"
        if let name = name {
            username = name
        }
        super.init(b: b, n: n, name: username, color: 0, rounded: true)
    }
    
    override func move(with process: @escaping (Int, UInt64) -> Void) {
        self.process = process
    }
    
    func move(at p: Int) {
        if let processMove = process {
            process = nil
            processMove(p, b.board[n])
        }
    }
}
