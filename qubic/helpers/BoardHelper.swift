//
//  BoardHelper.swift
//  qubic
//
//  Created by 4 on 8/31/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation
import SceneKit


func expandMoves(_ moves: String) -> [Int] {
    return moves.compactMap { moveStringMap.firstIndex(of: $0) }
}


let moveStringMap: [Character] = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","1","2","3","4","5","6","7","8","9","0","_","-","."]

let allSolveBoards = ["dZsf-RvH", "QR9v-HMCh_", "-vHRD9ojCMh", "RmDO9zvh-siL", "sRdGC1hQ", "dZsf-RvH", "QR9v-HMCh_", "-vHRD9ojCMh", "RmDO9zvh-siL",  "vmDHQ9khV-q", "RHvu96Dh-MPU", "mR9vDdH-VlhQ", "9R-vDHojqMC",  "dsqtRF9hMmVD", "Hd-yvqVjhRms", "dsVqHhC4M9", "RmvCsqJj", "VdMqhs-RDe", "VdMZhRmqs6Db9v-z", "RQj9hgX-s0_E", "mRHCVh90Wq", "Vqhsv9dHtRCD", "RHtqvu9hj27C",  "pmD93VvMqhRs",  "m-DQCMsdqVZU3vjY", "DQvMRhPU9-Cd", "jCdhqVbmH", "sdqMVvCQmD", "mdvnqVsHh",  "m-DQvdRsCjhq", "QW9X-C0_BRjmhDMPUOHt",  "m-CDrMbQvnRj", "-qm8hjVRs", "sdMCqhRHvbDW0a_", "vQJHY-yCjkR3VM", "9V-j_0RdfBQMJuc",  "mRD9vM-qVh",  "hVMsjqTD-", "jhVdCqvQ-nG_RBt9H", "sdMCqj9Hv1R"]

extension Board {
    struct D: Hashable {
        let gain: Int
        let cost: Int?
        let gains: UInt64
        let costs: UInt64
        let pairs: Dictionary<Int,Int>
        let line: Int?
        
        init(given: Int) {
            gain = given
            cost = nil
            gains = 0
            costs = 0
            pairs = [:]
            line = nil
        }
        
        init(gain: Int, cost: Int?, gains: UInt64, costs: UInt64, pairs: Dictionary<Int,Int>, line: Int?) {
            self.gain = gain
            self.cost = cost
            self.gains = gains
            self.costs = costs
            self.pairs = pairs
            self.line = line
        }
    }
    
    static let rich = [0,3,12,15,21,22,25,26,37,38,41,42,48,51,60,63]
    static let corners = [0,3,12,15,48,51,60,63]
    static let centers = [21,22,25,26,37,38,41,42]
    
    static let linesThruPoint: [[Int]] = [
        [0, 16, 32, 48, 56, 64, 72],  [0, 17, 33, 65],
        [0, 18, 34, 66],  [0, 19, 35, 52, 60, 67, 74],
        [1, 16, 36, 57],  [1, 17, 37, 48],
        [1, 18, 38, 52],  [1, 19, 39, 61],
        [2, 16, 40, 58],  [2, 17, 41, 52],
        [2, 18, 42, 48],  [2, 19, 43, 62],
        [3, 16, 44, 52, 59, 68, 75],  [3, 17, 45, 69],
        [3, 18, 46, 70],  [3, 19, 47, 48, 63, 71, 73],
        [4, 20, 32, 49],  [4, 21, 33, 56],
        [4, 22, 34, 60],  [4, 23, 35, 53],
        [5, 20, 36, 64],  [5, 21, 37, 49, 57, 65, 72],
        [5, 22, 38, 53, 61, 66, 74],  [5, 23, 39, 67],
        [6, 20, 40, 68],  [6, 21, 41, 53, 58, 69, 75],
        [6, 22, 42, 49, 62, 70, 73],  [6, 23, 43, 71],
        [7, 20, 44, 53],  [7, 21, 45, 59],
        [7, 22, 46, 63],  [7, 23, 47, 49],
        [8, 24, 32, 50],  [8, 25, 33, 60],
        [8, 26, 34, 56],  [8, 27, 35, 54],
        [9, 24, 36, 68],  [9, 25, 37, 50, 61, 69, 73],
        [9, 26, 38, 54, 57, 70, 75],  [9, 27, 39, 71],
        [10, 24, 40, 64],[10, 25, 41, 54, 62, 65, 74],
        [10, 26, 42, 50, 58, 66, 72],[10, 27, 43, 67],
        [11, 24, 44, 54],[11, 25, 45, 63],
        [11, 26, 46, 59],[11, 27, 47, 50],
        [12, 28, 32, 51, 60, 68, 73],[12, 29, 33, 69],
        [12, 30, 34, 70],[12, 31, 35, 55, 56, 71, 75],
        [13, 28, 36, 61],[13, 29, 37, 51],
        [13, 30, 38, 55],[13, 31, 39, 57],
        [14, 28, 40, 62],[14, 29, 41, 55],
        [14, 30, 42, 51],[14, 31, 43, 58],
        [15, 28, 44, 55, 63, 64, 74],[15, 29, 45, 65],
        [15, 30, 46, 66],[15, 31, 47, 51, 59, 67, 72]
    ]

    static let pointsInLine: [[Int]] = [
        [0,1,2,3],    [4,5,6,7],    [8,9,10,11],  [12,13,14,15],
        [16,17,18,19],[20,21,22,23],[24,25,26,27],[28,29,30,31],
        [32,33,34,35],[36,37,38,39],[40,41,42,43],[44,45,46,47],
        [48,49,50,51],[52,53,54,55],[56,57,58,59],[60,61,62,63],
        [0,4,8,12],   [1,5,9,13],   [2,6,10,14],  [3,7,11,15],
        [16,20,24,28],[17,21,25,29],[18,22,26,30],[19,23,27,31],
        [32,36,40,44],[33,37,41,45],[34,38,42,46],[35,39,43,47],
        [48,52,56,60],[49,53,57,61],[50,54,58,62],[51,55,59,63],
        [0,16,32,48], [1,17,33,49], [2,18,34,50], [3,19,35,51],
        [4,20,36,52], [5,21,37,53], [6,22,38,54], [7,23,39,55],
        [8,24,40,56], [9,25,41,57], [10,26,42,58],[11,27,43,59],
        [12,28,44,60],[13,29,45,61],[14,30,46,62],[15,31,47,63],
        [0,5,10,15],  [16,21,26,31],[32,37,42,47],[48,53,58,63],
        [3,6,9,12],   [19,22,25,28],[35,38,41,44],[51,54,57,60],
        [0,17,34,51], [4,21,38,55], [8,25,42,59], [12,29,46,63],
        [3,18,33,48], [7,22,37,52], [11,26,41,56],[15,30,45,60],
        [0,20,40,60], [1,21,41,61], [2,22,42,62], [3,23,43,63],
        [12,24,36,48],[13,25,37,49],[14,26,38,50],[15,27,39,51],
        [0,21,42,63], [15,26,37,48],[3,22,41,60], [12,25,38,51]
    ]

    static let linePoints: [UInt64] = [15, 240, 3840, 61440, 983040, 15728640, 251658240, 4026531840, 64424509440, 1030792151040, 16492674416640, 263882790666240, 4222124650659840, 67553994410557440, 1080863910568919040, 17293822569102704640, 4369, 8738, 17476, 34952, 286326784, 572653568, 1145307136, 2290614272, 18764712116224, 37529424232448, 75058848464896, 150117696929792, 1229764173248856064, 2459528346497712128, 4919056692995424256, 9838113385990848512, 281479271743489, 562958543486978, 1125917086973956, 2251834173947912, 4503668347895824, 9007336695791648, 18014673391583296, 36029346783166592, 72058693566333184, 144117387132666368, 288234774265332736, 576469548530665472, 1152939097061330944, 2305878194122661888, 4611756388245323776, 9223512776490647552, 33825, 2216755200, 145277268787200, 9520891087237939200, 4680, 306708480, 20100446945280, 1317302891005870080, 2251816993685505, 36029071898968080, 576465150383489280, 9223442406135828480, 281483566907400, 4503737070518400, 72059793128294400, 1152956690052710400, 1152922604119523329, 2305845208239046658, 4611690416478093316, 9223380832956186632, 281543712968704, 563087425937408, 1126174851874816, 2252349703749632, 9223376434903384065, 281612482805760, 1152923703634296840, 2252074725150720]

    static let inLine: [[(Int, Int, Int)?]] = [
         [nil, (0, 3, 2), (0, 3, 1), (0, 1, 2), (16, 12, 8), (48, 15, 10), nil, nil, (16, 12, 4), nil, (48, 15, 5), nil, (16, 8, 4), nil, nil, (48, 10, 5), (32, 32, 48), (56, 34, 51), nil, nil, (64, 60, 40), (72, 63, 42), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (32, 48, 16), nil, (56, 51, 17), nil, nil, nil, nil, nil, (64, 20, 60), nil, (72, 63, 21), nil, nil, nil, nil, nil, (32, 32, 16), nil, nil, (56, 34, 17), nil, nil, nil, nil, nil, nil, nil, nil, (64, 20, 40), nil, nil, (72, 42, 21)],
         [(0, 3, 2), nil, (0, 3, 0), (0, 2, 0), nil, (17, 13, 9), nil, nil, nil, (17, 5, 13), nil, nil, nil, (17, 5, 9), nil, nil, nil, (33, 33, 49), nil, nil, nil, (65, 61, 41), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (33, 17, 49), nil, nil, nil, nil, nil, nil, nil, (65, 21, 61), nil, nil, nil, nil, nil, nil, nil, (33, 17, 33), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (65, 21, 41), nil, nil],
         [(0, 3, 1), (0, 3, 0), nil, (0, 1, 0), nil, nil, (18, 10, 14), nil, nil, nil, (18, 6, 14), nil, nil, nil, (18, 6, 10), nil, nil, nil, (34, 34, 50), nil, nil, nil, (66, 42, 62), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (34, 18, 50), nil, nil, nil, nil, nil, nil, nil, (66, 22, 62), nil, nil, nil, nil, nil, nil, nil, (34, 18, 34), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (66, 42, 22), nil],
         [(0, 1, 2), (0, 2, 0), (0, 1, 0), nil, nil, nil, (52, 9, 12), (19, 11, 15), nil, (52, 6, 12), nil, (19, 15, 7), (52, 9, 6), nil, nil, (19, 11, 7), nil, nil, (60, 48, 33), (35, 35, 51), nil, nil, (74, 41, 60), (67, 43, 63), nil, nil, nil, nil, nil, nil, nil, nil, nil, (60, 18, 48), nil, (35, 19, 51), nil, nil, nil, nil, nil, (74, 22, 60), nil, (67, 23, 63), nil, nil, nil, nil, (60, 18, 33), nil, nil, (35, 35, 19), nil, nil, nil, nil, nil, nil, nil, nil, (74, 41, 22), nil, nil, (67, 23, 43)],
         [(16, 12, 8), nil, nil, nil, nil, (1, 7, 6), (1, 5, 7), (1, 5, 6), (16, 12, 0), nil, nil, nil, (16, 0, 8), nil, nil, nil, nil, nil, nil, nil, (36, 36, 52), (57, 38, 55), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (36, 20, 52), nil, (57, 21, 55), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (36, 36, 20), nil, nil, (57, 21, 38), nil, nil, nil, nil, nil, nil, nil, nil],
         [(48, 15, 10), (17, 13, 9), nil, nil, (1, 7, 6), nil, (1, 7, 4), (1, 6, 4), nil, (17, 1, 13), (48, 0, 15), nil, nil, (17, 1, 9), nil, (48, 0, 10), nil, nil, nil, nil, nil, (37, 37, 53), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (37, 21, 53), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (37, 21, 37), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, (18, 10, 14), (52, 9, 12), (1, 5, 7), (1, 7, 4), nil, (1, 5, 4), nil, (52, 3, 12), (18, 2, 14), nil, (52, 9, 3), nil, (18, 2, 10), nil, nil, nil, nil, nil, nil, nil, (38, 38, 54), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (38, 22, 54), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (38, 22, 38), nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, (19, 11, 15), (1, 5, 6), (1, 6, 4), (1, 5, 4), nil, nil, nil, nil, (19, 15, 3), nil, nil, nil, (19, 11, 3), nil, nil, nil, nil, nil, nil, (61, 37, 52), (39, 55, 39), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (61, 22, 52), nil, (39, 23, 55), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (61, 22, 37), nil, nil, (39, 23, 39), nil, nil, nil, nil, nil, nil, nil, nil],
         [(16, 12, 4), nil, nil, nil, (16, 12, 0), nil, nil, nil, nil, (2, 10, 11), (2, 11, 9), (2, 10, 9), (16, 0, 4), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (40, 40, 56), (58, 59, 42), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (40, 24, 56), nil, (58, 25, 59), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (40, 24, 40), nil, nil, (58, 25, 42), nil, nil, nil, nil],
         [nil, (17, 5, 13), nil, (52, 6, 12), nil, (17, 1, 13), (52, 3, 12), nil, (2, 10, 11), nil, (2, 11, 8), (2, 10, 8), (52, 3, 6), (17, 1, 5), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (41, 41, 57), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (41, 57, 25), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (41, 41, 25), nil, nil, nil, nil, nil, nil],
         [(48, 15, 5), nil, (18, 6, 14), nil, nil, (48, 0, 15), (18, 2, 14), nil, (2, 11, 9), (2, 11, 8), nil, (2, 8, 9), nil, nil, (18, 6, 2), (48, 0, 5), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 42, 58), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 58, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 42, 26), nil, nil, nil, nil, nil],
         [nil, nil, nil, (19, 15, 7), nil, nil, nil, (19, 15, 3), (2, 10, 9), (2, 10, 8), (2, 8, 9), nil, nil, nil, nil, (19, 7, 3), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (62, 41, 56), (43, 59, 43), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (62, 56, 26), nil, (43, 59, 27), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (62, 41, 26), nil, nil, (43, 27, 43), nil, nil, nil, nil],
         [(16, 8, 4), nil, nil, (52, 9, 6), (16, 0, 8), nil, (52, 9, 3), nil, (16, 0, 4), (52, 3, 6), nil, nil, nil, (3, 14, 15), (3, 15, 13), (3, 14, 13), nil, nil, nil, nil, nil, nil, nil, nil, (68, 48, 36), (75, 38, 51), nil, nil, (44, 60, 44), (59, 46, 63), nil, nil, nil, nil, nil, nil, (68, 48, 24), nil, (75, 25, 51), nil, nil, nil, nil, nil, (44, 28, 60), nil, (59, 29, 63), nil, (68, 24, 36), nil, nil, (75, 38, 25), nil, nil, nil, nil, nil, nil, nil, nil, (44, 28, 44), nil, nil, (59, 46, 29)],
         [nil, (17, 5, 9), nil, nil, nil, (17, 1, 9), nil, nil, nil, (17, 1, 5), nil, nil, (3, 14, 15), nil, (3, 12, 15), (3, 12, 14), nil, nil, nil, nil, nil, nil, nil, nil, nil, (69, 37, 49), nil, nil, nil, (45, 61, 45), nil, nil, nil, nil, nil, nil, nil, (69, 49, 25), nil, nil, nil, nil, nil, nil, nil, (45, 61, 29), nil, nil, nil, (69, 37, 25), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (45, 29, 45), nil, nil],
         [nil, nil, (18, 6, 10), nil, nil, nil, (18, 2, 10), nil, nil, nil, (18, 6, 2), nil, (3, 15, 13), (3, 12, 15), nil, (3, 12, 13), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (70, 38, 50), nil, nil, nil, (46, 62, 46), nil, nil, nil, nil, nil, nil, nil, (70, 50, 26), nil, nil, nil, nil, nil, nil, nil, (46, 62, 30), nil, nil, nil, (70, 38, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (46, 46, 30), nil],
         [(48, 10, 5), nil, nil, (19, 11, 7), nil, (48, 0, 10), nil, (19, 11, 3), nil, nil, (48, 0, 5), (19, 7, 3), (3, 14, 13), (3, 12, 14), (3, 12, 13), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (73, 37, 48), (71, 51, 39), nil, nil, (63, 45, 60), (47, 47, 63), nil, nil, nil, nil, nil, (73, 26, 48), nil, (71, 27, 51), nil, nil, nil, nil, nil, (63, 60, 30), nil, (47, 31, 63), (73, 26, 37), nil, nil, (71, 27, 39), nil, nil, nil, nil, nil, nil, nil, nil, (63, 45, 30), nil, nil, (47, 31, 47)],
         [(32, 32, 48), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (4, 18, 19), (4, 17, 19), (4, 18, 17), (20, 24, 28), (49, 26, 31), nil, nil, (20, 20, 28), nil, (49, 31, 21), nil, (20, 20, 24), nil, nil, (49, 26, 21), (32, 48, 0), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (32, 32, 0), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [(56, 34, 51), (33, 33, 49), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (4, 18, 19), nil, (4, 16, 19), (4, 16, 18), nil, (21, 29, 25), nil, nil, nil, (21, 29, 21), nil, nil, nil, (21, 25, 21), nil, nil, nil, (33, 49, 1), (56, 0, 51), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (33, 33, 1), nil, (56, 34, 0), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, (34, 34, 50), (60, 48, 33), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (4, 17, 19), (4, 16, 19), nil, (4, 16, 17), nil, nil, (22, 26, 30), nil, nil, nil, (22, 30, 22), nil, nil, nil, (22, 26, 22), nil, nil, (60, 48, 3), (34, 2, 50), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (60, 33, 3), nil, (34, 2, 34), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, (35, 35, 51), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (4, 18, 17), (4, 16, 18), (4, 16, 17), nil, nil, nil, (53, 25, 28), (23, 27, 31), nil, (53, 28, 22), nil, (23, 23, 31), (53, 25, 22), nil, nil, (23, 23, 27), nil, nil, nil, (35, 3, 51), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (35, 3, 35), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [(64, 60, 40), nil, nil, nil, (36, 36, 52), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (20, 24, 28), nil, nil, nil, nil, (5, 23, 22), (5, 23, 21), (5, 22, 21), (20, 28, 16), nil, nil, nil, (20, 24, 16), nil, nil, nil, nil, nil, nil, nil, (36, 4, 52), nil, nil, nil, (64, 0, 60), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (36, 36, 4), nil, nil, nil, nil, nil, nil, nil, (64, 0, 40), nil, nil, nil],
         [(72, 63, 42), (65, 61, 41), nil, nil, (57, 38, 55), (37, 37, 53), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (49, 26, 31), (21, 29, 25), nil, nil, (5, 23, 22), nil, (5, 23, 20), (5, 22, 20), nil, (21, 29, 17), (49, 16, 31), nil, nil, (21, 25, 17), nil, (49, 16, 26), nil, nil, nil, nil, nil, (37, 5, 53), (57, 55, 4), nil, nil, (65, 61, 1), (72, 63, 0), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (37, 37, 5), nil, (57, 38, 4), nil, nil, nil, nil, nil, (65, 1, 41), nil, (72, 42, 0)],
         [nil, nil, (66, 42, 62), (74, 41, 60), nil, nil, (38, 38, 54), (61, 37, 52), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (22, 26, 30), (53, 25, 28), (5, 23, 21), (5, 23, 20), nil, (5, 21, 20), nil, (53, 19, 28), (22, 18, 30), nil, (53, 19, 25), nil, (22, 18, 26), nil, nil, nil, nil, nil, nil, (61, 7, 52), (38, 6, 54), nil, nil, (74, 3, 60), (66, 2, 62), nil, nil, nil, nil, nil, nil, nil, nil, nil, (61, 37, 7), nil, (38, 6, 38), nil, nil, nil, nil, nil, (74, 41, 3), nil, (66, 2, 42), nil],
         [nil, nil, nil, (67, 43, 63), nil, nil, nil, (39, 55, 39), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (23, 27, 31), (5, 22, 21), (5, 22, 20), (5, 21, 20), nil, nil, nil, nil, (23, 19, 31), nil, nil, nil, (23, 19, 27), nil, nil, nil, nil, nil, nil, nil, (39, 7, 55), nil, nil, nil, (67, 3, 63), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (39, 7, 39), nil, nil, nil, nil, nil, nil, nil, (67, 3, 43)],
         [nil, nil, nil, nil, nil, nil, nil, nil, (40, 40, 56), nil, nil, nil, (68, 48, 36), nil, nil, nil, (20, 20, 28), nil, nil, nil, (20, 28, 16), nil, nil, nil, nil, (6, 27, 26), (6, 25, 27), (6, 25, 26), (20, 20, 16), nil, nil, nil, nil, nil, nil, nil, (68, 12, 48), nil, nil, nil, (40, 8, 56), nil, nil, nil, nil, nil, nil, nil, (68, 12, 36), nil, nil, nil, nil, nil, nil, nil, (40, 8, 40), nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, (58, 59, 42), (41, 41, 57), nil, nil, (75, 38, 51), (69, 37, 49), nil, nil, nil, (21, 29, 21), nil, (53, 28, 22), nil, (21, 29, 17), (53, 19, 28), nil, (6, 27, 26), nil, (6, 27, 24), (6, 24, 26), (53, 19, 22), (21, 17, 21), nil, nil, nil, nil, nil, nil, nil, (69, 49, 13), (75, 12, 51), nil, nil, (41, 57, 9), (58, 8, 59), nil, nil, nil, nil, nil, nil, (69, 37, 13), nil, (75, 12, 38), nil, nil, nil, nil, nil, (41, 41, 9), nil, (58, 8, 42), nil, nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 42, 58), (62, 41, 56), nil, nil, (70, 38, 50), (73, 37, 48), (49, 31, 21), nil, (22, 30, 22), nil, nil, (49, 16, 31), (22, 18, 30), nil, (6, 25, 27), (6, 27, 24), nil, (6, 25, 24), nil, nil, (22, 18, 22), (49, 16, 21), nil, nil, nil, nil, nil, (73, 15, 48), (70, 14, 50), nil, nil, (62, 11, 56), (42, 10, 58), nil, nil, nil, nil, nil, (73, 37, 15), nil, (70, 38, 14), nil, nil, nil, nil, nil, (62, 11, 41), nil, (42, 10, 42), nil, nil, nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (43, 59, 43), nil, nil, nil, (71, 51, 39), nil, nil, nil, (23, 23, 31), nil, nil, nil, (23, 19, 31), (6, 25, 26), (6, 24, 26), (6, 25, 24), nil, nil, nil, nil, (23, 23, 19), nil, nil, nil, nil, nil, nil, nil, (71, 51, 15), nil, nil, nil, (43, 59, 11), nil, nil, nil, nil, nil, nil, nil, (71, 15, 39), nil, nil, nil, nil, nil, nil, nil, (43, 11, 43), nil, nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (44, 60, 44), nil, nil, nil, (20, 20, 24), nil, nil, (53, 25, 22), (20, 24, 16), nil, (53, 19, 25), nil, (20, 20, 16), (53, 19, 22), nil, nil, nil, (7, 30, 31), (7, 29, 31), (7, 29, 30), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (44, 60, 12), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (44, 44, 12), nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (59, 46, 63), (45, 61, 45), nil, nil, nil, (21, 25, 21), nil, nil, nil, (21, 25, 17), nil, nil, nil, (21, 17, 21), nil, nil, (7, 30, 31), nil, (7, 28, 31), (7, 28, 30), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (45, 61, 13), (59, 12, 63), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (45, 45, 13), nil, (59, 46, 12)],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (46, 62, 46), (63, 45, 60), nil, nil, (22, 26, 22), nil, nil, nil, (22, 18, 26), nil, nil, nil, (22, 18, 22), nil, (7, 29, 31), (7, 28, 31), nil, (7, 29, 28), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (63, 15, 60), (46, 14, 62), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (63, 15, 45), nil, (46, 14, 46), nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (47, 47, 63), (49, 26, 21), nil, nil, (23, 23, 27), nil, (49, 16, 26), nil, (23, 19, 27), nil, nil, (49, 16, 21), (23, 23, 19), (7, 29, 30), (7, 28, 30), (7, 29, 28), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (47, 15, 63), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (47, 15, 47)],
         [(32, 48, 16), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (32, 48, 0), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (8, 35, 34), (8, 35, 33), (8, 33, 34), (24, 40, 44), (50, 42, 47), nil, nil, (24, 44, 36), nil, (50, 47, 37), nil, (24, 40, 36), nil, nil, (50, 42, 37), (32, 0, 16), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, (33, 17, 49), nil, (60, 18, 48), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (33, 49, 1), (60, 48, 3), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (8, 35, 34), nil, (8, 35, 32), (8, 32, 34), nil, (25, 45, 41), nil, nil, nil, (25, 37, 45), nil, nil, nil, (25, 37, 41), nil, nil, (60, 18, 3), (33, 17, 1), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [(56, 51, 17), nil, (34, 18, 50), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (56, 0, 51), (34, 2, 50), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (8, 35, 33), (8, 35, 32), nil, (8, 32, 33), nil, nil, (26, 42, 46), nil, nil, nil, (26, 46, 38), nil, nil, nil, (26, 42, 38), nil, nil, nil, (34, 18, 2), (56, 0, 17), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, (35, 19, 51), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (35, 3, 51), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (8, 33, 34), (8, 32, 34), (8, 32, 33), nil, nil, nil, (54, 44, 41), (27, 43, 47), nil, (54, 44, 38), nil, (27, 39, 47), (54, 41, 38), nil, nil, (27, 43, 39), nil, nil, nil, (35, 3, 19), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, nil, (36, 20, 52), nil, nil, nil, nil, nil, nil, nil, (68, 48, 24), nil, nil, nil, nil, nil, nil, nil, (36, 4, 52), nil, nil, nil, (68, 12, 48), nil, nil, nil, nil, nil, nil, nil, (24, 40, 44), nil, nil, nil, nil, (9, 38, 39), (9, 37, 39), (9, 37, 38), (24, 32, 44), nil, nil, nil, (24, 40, 32), nil, nil, nil, (68, 12, 24), nil, nil, nil, (36, 20, 4), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, nil, nil, (37, 21, 53), nil, (61, 22, 52), nil, nil, nil, nil, nil, (69, 49, 25), nil, (73, 26, 48), nil, nil, nil, nil, nil, (37, 5, 53), (61, 7, 52), nil, nil, (69, 49, 13), (73, 15, 48), nil, nil, nil, nil, nil, (50, 42, 47), (25, 45, 41), nil, nil, (9, 38, 39), nil, (9, 36, 39), (9, 38, 36), nil, (25, 33, 45), (50, 47, 32), nil, nil, (25, 33, 41), nil, (50, 42, 32), (73, 26, 15), (69, 25, 13), nil, nil, (61, 22, 7), (37, 21, 5), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, nil, (57, 21, 55), nil, (38, 22, 54), nil, nil, nil, nil, nil, (75, 25, 51), nil, (70, 50, 26), nil, nil, nil, nil, nil, nil, (57, 55, 4), (38, 6, 54), nil, nil, (75, 12, 51), (70, 14, 50), nil, nil, nil, nil, nil, nil, nil, (26, 42, 46), (54, 44, 41), (9, 37, 39), (9, 36, 39), nil, (9, 37, 36), nil, (54, 44, 35), (26, 34, 46), nil, (54, 41, 35), nil, (26, 34, 42), nil, nil, nil, (70, 14, 26), (75, 12, 25), nil, nil, (38, 22, 6), (57, 21, 4), nil, nil, nil, nil, nil, nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, (39, 23, 55), nil, nil, nil, nil, nil, nil, nil, (71, 27, 51), nil, nil, nil, nil, nil, nil, nil, (39, 7, 55), nil, nil, nil, (71, 51, 15), nil, nil, nil, nil, nil, nil, nil, (27, 43, 47), (9, 37, 38), (9, 38, 36), (9, 37, 36), nil, nil, nil, nil, (27, 35, 47), nil, nil, nil, (27, 43, 35), nil, nil, nil, (71, 27, 15), nil, nil, nil, (39, 7, 23), nil, nil, nil, nil, nil, nil, nil, nil],
         [(64, 20, 60), nil, nil, nil, nil, nil, nil, nil, (40, 24, 56), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (64, 0, 60), nil, nil, nil, (40, 8, 56), nil, nil, nil, nil, nil, nil, nil, (24, 44, 36), nil, nil, nil, (24, 32, 44), nil, nil, nil, nil, (10, 42, 43), (10, 41, 43), (10, 41, 42), (24, 32, 36), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (40, 24, 8), nil, nil, nil, (64, 0, 20), nil, nil, nil],
         [nil, (65, 21, 61), nil, (74, 22, 60), nil, nil, nil, nil, nil, (41, 57, 25), nil, (62, 56, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, (65, 61, 1), (74, 3, 60), nil, nil, (41, 57, 9), (62, 11, 56), nil, nil, nil, nil, nil, nil, (25, 37, 45), nil, (54, 44, 38), nil, (25, 33, 45), (54, 44, 35), nil, (10, 42, 43), nil, (10, 40, 43), (10, 42, 40), (54, 35, 38), (25, 37, 33), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (62, 11, 26), (41, 9, 25), nil, nil, (74, 22, 3), (65, 21, 1), nil, nil],
         [(72, 63, 21), nil, (66, 22, 62), nil, nil, nil, nil, nil, (58, 25, 59), nil, (42, 58, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (72, 63, 0), (66, 2, 62), nil, nil, (58, 8, 59), (42, 10, 58), nil, nil, nil, nil, nil, (50, 47, 37), nil, (26, 46, 38), nil, nil, (50, 47, 32), (26, 34, 46), nil, (10, 41, 43), (10, 40, 43), nil, (10, 41, 40), nil, nil, (26, 34, 38), (50, 37, 32), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 10, 26), (58, 25, 8), nil, nil, (66, 2, 22), (72, 21, 0)],
         [nil, nil, nil, (67, 23, 63), nil, nil, nil, nil, nil, nil, nil, (43, 59, 27), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (67, 3, 63), nil, nil, nil, (43, 59, 11), nil, nil, nil, nil, nil, nil, nil, (27, 39, 47), nil, nil, nil, (27, 35, 47), (10, 41, 42), (10, 42, 40), (10, 41, 40), nil, nil, nil, nil, (27, 39, 35), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (43, 27, 11), nil, nil, nil, (67, 3, 23)],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (44, 28, 60), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (44, 60, 12), nil, nil, nil, (24, 40, 36), nil, nil, (54, 41, 38), (24, 40, 32), nil, (54, 41, 35), nil, (24, 32, 36), (54, 35, 38), nil, nil, nil, (11, 47, 46), (11, 47, 45), (11, 45, 46), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (44, 28, 12), nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (45, 61, 29), nil, (63, 60, 30), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (45, 61, 13), (63, 15, 60), nil, nil, (25, 37, 41), nil, nil, nil, (25, 33, 41), nil, nil, nil, (25, 37, 33), nil, nil, (11, 47, 46), nil, (11, 47, 44), (11, 44, 46), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (63, 15, 30), (45, 29, 13), nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (59, 29, 63), nil, (46, 62, 30), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (59, 12, 63), (46, 14, 62), nil, nil, nil, (26, 42, 38), nil, nil, nil, (26, 34, 42), nil, nil, nil, (26, 34, 38), nil, (11, 47, 45), (11, 47, 44), nil, (11, 44, 45), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (46, 14, 30), (59, 12, 29)],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (47, 31, 63), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (47, 15, 63), (50, 42, 37), nil, nil, (27, 43, 39), nil, (50, 42, 32), nil, (27, 43, 35), nil, nil, (50, 37, 32), (27, 39, 35), (11, 45, 46), (11, 44, 46), (11, 44, 45), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (47, 15, 31)],
         [(32, 32, 16), nil, nil, (60, 18, 33), nil, nil, nil, nil, nil, nil, nil, nil, (68, 24, 36), nil, nil, (73, 26, 37), (32, 32, 0), nil, (60, 33, 3), nil, nil, nil, nil, nil, (68, 12, 36), nil, (73, 37, 15), nil, nil, nil, nil, nil, (32, 0, 16), (60, 18, 3), nil, nil, (68, 12, 24), (73, 26, 15), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (12, 51, 50), (12, 51, 49), (12, 50, 49), (28, 56, 60), (51, 63, 58), nil, nil, (28, 52, 60), nil, (51, 53, 63), nil, (28, 52, 56), nil, nil, (51, 53, 58)],
         [nil, (33, 17, 33), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (69, 37, 25), nil, nil, nil, (33, 33, 1), nil, nil, nil, nil, nil, nil, nil, (69, 37, 13), nil, nil, nil, nil, nil, nil, nil, (33, 17, 1), nil, nil, nil, (69, 25, 13), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (12, 51, 50), nil, (12, 51, 48), (12, 50, 48), nil, (29, 57, 61), nil, nil, nil, (29, 53, 61), nil, nil, nil, (29, 53, 57), nil, nil],
         [nil, nil, (34, 18, 34), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (70, 38, 26), nil, nil, nil, (34, 2, 34), nil, nil, nil, nil, nil, nil, nil, (70, 38, 14), nil, nil, nil, nil, nil, nil, nil, (34, 18, 2), nil, nil, nil, (70, 14, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, (12, 51, 49), (12, 51, 48), nil, (12, 48, 49), nil, nil, (30, 58, 62), nil, nil, nil, (30, 54, 62), nil, nil, nil, (30, 54, 58), nil],
         [(56, 34, 17), nil, nil, (35, 35, 19), nil, nil, nil, nil, nil, nil, nil, nil, (75, 38, 25), nil, nil, (71, 27, 39), nil, (56, 34, 0), nil, (35, 3, 35), nil, nil, nil, nil, nil, (75, 12, 38), nil, (71, 15, 39), nil, nil, nil, nil, nil, nil, (56, 0, 17), (35, 3, 19), nil, nil, (75, 12, 25), (71, 27, 15), nil, nil, nil, nil, nil, nil, nil, nil, (12, 50, 49), (12, 50, 48), (12, 48, 49), nil, nil, nil, (55, 57, 60), (31, 63, 59), nil, (55, 54, 60), nil, (31, 55, 63), (55, 57, 54), nil, nil, (31, 55, 59)],
         [nil, nil, nil, nil, (36, 36, 20), nil, nil, (61, 22, 37), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (36, 36, 4), nil, (61, 37, 7), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (36, 20, 4), (61, 22, 7), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (28, 56, 60), nil, nil, nil, nil, (13, 55, 54), (13, 55, 53), (13, 53, 54), (28, 60, 48), nil, nil, nil, (28, 56, 48), nil, nil, nil],
         [nil, nil, nil, nil, nil, (37, 21, 37), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (37, 37, 5), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (37, 21, 5), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (51, 63, 58), (29, 57, 61), nil, nil, (13, 55, 54), nil, (13, 55, 52), (13, 54, 52), nil, (29, 49, 61), (51, 48, 63), nil, nil, (29, 49, 57), nil, (51, 48, 58)],
         [nil, nil, nil, nil, nil, nil, (38, 22, 38), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (38, 6, 38), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (38, 22, 6), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (30, 58, 62), (55, 57, 60), (13, 55, 53), (13, 55, 52), nil, (13, 53, 52), nil, (55, 60, 51), (30, 50, 62), nil, (55, 57, 51), nil, (30, 58, 50), nil],
         [nil, nil, nil, nil, (57, 21, 38), nil, nil, (39, 23, 39), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (57, 38, 4), nil, (39, 7, 39), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (57, 21, 4), (39, 7, 23), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (31, 63, 59), (13, 53, 54), (13, 54, 52), (13, 53, 52), nil, nil, nil, nil, (31, 51, 63), nil, nil, nil, (31, 51, 59)],
         [nil, nil, nil, nil, nil, nil, nil, nil, (40, 24, 40), nil, nil, (62, 41, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (40, 8, 40), nil, (62, 11, 41), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (40, 24, 8), (62, 11, 26), nil, nil, nil, nil, nil, nil, (28, 52, 60), nil, nil, nil, (28, 60, 48), nil, nil, nil, nil, (14, 59, 58), (14, 59, 57), (14, 58, 57), (28, 52, 48), nil, nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, (41, 41, 25), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (41, 41, 9), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (41, 9, 25), nil, nil, nil, nil, nil, nil, nil, (29, 53, 61), nil, (55, 54, 60), nil, (29, 49, 61), (55, 60, 51), nil, (14, 59, 58), nil, (14, 59, 56), (14, 58, 56), (55, 54, 51), (29, 49, 53), nil, nil],
         [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 42, 26), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 10, 42), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (42, 10, 26), nil, nil, nil, nil, nil, (51, 53, 63), nil, (30, 54, 62), nil, nil, (51, 48, 63), (30, 50, 62), nil, (14, 59, 57), (14, 59, 56), nil, (14, 56, 57), nil, nil, (30, 54, 50), (51, 48, 53)],
         [nil, nil, nil, nil, nil, nil, nil, nil, (58, 25, 42), nil, nil, (43, 27, 43), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (58, 8, 42), nil, (43, 11, 43), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (58, 25, 8), (43, 27, 11), nil, nil, nil, nil, nil, nil, nil, (31, 55, 63), nil, nil, nil, (31, 51, 63), (14, 58, 57), (14, 58, 56), (14, 56, 57), nil, nil, nil, nil, (31, 51, 55)],
         [(64, 20, 40), nil, nil, (74, 41, 22), nil, nil, nil, nil, nil, nil, nil, nil, (44, 28, 44), nil, nil, (63, 45, 30), nil, nil, nil, nil, (64, 0, 40), nil, (74, 41, 3), nil, nil, nil, nil, nil, (44, 44, 12), nil, (63, 15, 45), nil, nil, nil, nil, nil, nil, nil, nil, nil, (64, 0, 20), (74, 22, 3), nil, nil, (44, 28, 12), (63, 15, 30), nil, nil, (28, 52, 56), nil, nil, (55, 57, 54), (28, 56, 48), nil, (55, 57, 51), nil, (28, 52, 48), (55, 54, 51), nil, nil, nil, (15, 62, 63), (15, 61, 63), (15, 61, 62)],
         [nil, (65, 21, 41), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (45, 29, 45), nil, nil, nil, nil, nil, nil, nil, (65, 1, 41), nil, nil, nil, nil, nil, nil, nil, (45, 45, 13), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (65, 21, 1), nil, nil, nil, (45, 29, 13), nil, nil, nil, (29, 53, 57), nil, nil, nil, (29, 49, 57), nil, nil, nil, (29, 49, 53), nil, nil, (15, 62, 63), nil, (15, 60, 63), (15, 60, 62)],
         [nil, nil, (66, 42, 22), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (46, 46, 30), nil, nil, nil, nil, nil, nil, nil, (66, 2, 42), nil, nil, nil, nil, nil, nil, nil, (46, 14, 46), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (66, 2, 22), nil, nil, nil, (46, 14, 30), nil, nil, nil, (30, 54, 58), nil, nil, nil, (30, 58, 50), nil, nil, nil, (30, 54, 50), nil, (15, 61, 63), (15, 60, 63), nil, (15, 61, 60)],
         [(72, 42, 21), nil, nil, (67, 23, 43), nil, nil, nil, nil, nil, nil, nil, nil, (59, 46, 29), nil, nil, (47, 31, 47), nil, nil, nil, nil, nil, (72, 42, 0), nil, (67, 3, 43), nil, nil, nil, nil, nil, (59, 46, 12), nil, (47, 15, 47), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (72, 21, 0), (67, 3, 23), nil, nil, (59, 12, 29), (47, 15, 31), (51, 53, 58), nil, nil, (31, 55, 59), nil, (51, 48, 58), nil, (31, 51, 59), nil, nil, (51, 48, 53), (31, 51, 55), (15, 61, 62), (15, 60, 62), (15, 61, 60), nil]
    ]
}
