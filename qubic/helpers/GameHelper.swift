//
//  GameHelper.swift
//  qubic
//
//  Created by 4 on 10/13/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

enum OpponentType {
    case master
}

struct WinLine {
    let start: Int
    let end: Int
    let line: Int
}

class GameData {
    // provided
    let myTurn: Int
    let op: OpponentType
    let playerColor: [UIColor]
    let preset: [Int]
    
    // created
    private let board = Board()
    var winner: Int? = nil
    var leaving: Bool = false
    
    init() {
        myTurn = 0
        op = .master
        playerColor = []
        preset = []
    }
    
    init(preset givenPreset: [Int]) {
        myTurn = givenPreset.count % 2
        op = .master
        playerColor = [getUIColor(1), getUIColor(2)]
        preset = givenPreset
    }
    
    func getMove() -> Int {
        switch op {
        case .master: return board.getMasterMove()
        }
    }
    
    func getTurn() -> Int { board.getTurn() }
    func nextTurn() -> Int { board.nextTurn() }
    func processMove(_ p: Int) -> [WinLine]? { board.processMove(p) }
    func pauseTime() -> Double { board.pauseTime() }
}

func expandMoves(_ moves: String) -> [Int] {
    return moves.compactMap { moveStringMap.firstIndex(of: $0) }
}

let moveStringMap: [Character] = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","1","2","3","4","5","6","7","8","9","0","_","-","."]

let allSolveBoards = ["dZsf-RvH", "QR9v-HMCh_", "-vHRD9ojCMh", "RmDO9zvh-siL", "sRdGC1hQ", "dZsf-RvH", "QR9v-HMCh_", "-vHRD9ojCMh", "RmDO9zvh-siL",  "vmDHQ9khV-q", "RHvu96Dh-MPU", "mR9vDdH-VlhQ", "9R-vDHojqMC",  "dsqtRF9hMmVD", "Hd-yvqVjhRms", "dsVqHhC4M9", "RmvCsqJj", "VdMqhs-RDe", "VdMZhRmqs6Db9v-z", "RQj9hgX-s0_E", "mRHCVh90Wq", "Vqhsv9dHtRCD", "RHtqvu9hj27C",  "pmD93VvMqhRs",  "m-DQCMsdqVZU3vjY", "DQvMRhPU9-Cd", "jCdhqVbmH", "sdqMVvCQmD", "mdvnqVsHh",  "m-DQvdRsCjhq", "QW9X-C0_BRjmhDMPUOHt",  "m-CDrMbQvnRj", "-qm8hjVRs", "sdMCqhRHvbDW0a_", "vQJHY-yCjkR3VM", "9V-j_0RdfBQMJuc",  "mRD9vM-qVh",  "hVMsjqTD-", "jhVdCqvQ-nG_RBt9H", "sdMCqj9Hv1R"]
