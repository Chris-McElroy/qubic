//
//  BoardView.swift
//  qubic
//
//  Created by 4 on 8/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct BoardView: UIViewRepresentable {
    let boardScene: BoardScene
    func makeUIView(context: Context) -> SCNView { boardScene.reset(); return boardScene.view }
    func updateUIView(_ scnView: SCNView, context: Context) {}
//    func rotate(right: Bool) { boardScene.rotate(right: right) }
//    func load(_ data: GameData) { boardScene.load(data) }
}

class BoardScene: ObservableObject {
    @Published var data: GameData = GameData()
    var goBack: () -> Void = {}
    var cancelBack: () -> Bool = { true }
    let view = SCNView()
    let help = SceneHelper()
    let scene = SCNScene()
    let base = SCNNode()
    let dots: [SCNNode] = (0..<64).map { _ in SceneHelper().makeDot(color: getUIColor(33), size: 0.45) }
    var moves: [SCNNode] = []
    var nextMove: SCNNode? = nil
    let nextMovePos = [SCNVector3(0,-11.3,0),SCNVector3(0,11.3,0)]
    var currentLines: [SCNNode?] = Array(repeating: nil, count: 76)
    let normalScale = SCNVector3(1,1,1)
    let selectedScale = SCNVector3(1.3,1.3,1.3)
    
    init() {
        scene.rootNode.addChildNode(help.makeCamera())
        scene.rootNode.addChildNode(help.makeOmniLight())
        scene.rootNode.addChildNode(help.makeAmbiLight())
        for (p, dot) in dots.enumerated() { setPosition(for: dot, at: p) }
        scene.rootNode.addChildNode(base)
        help.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func reset() {
        for move in moves {
            move.removeFromParentNode()
        }
        moves.removeAll()
        for dot in dots {
            dot.opacity = 1
        }
        for l in 0..<76 {
            currentLines[l]?.removeFromParentNode()
            currentLines[l] = nil
        }
        nextMove?.removeFromParentNode()
        nextMove = nil
    }
    
    func setPosition(for node: SCNNode, at p: Int) {
        let flat = SIMD3<Float>(Float(p/16), Float(p%4), Float((p/4)%4)) - 1.5
        node.position = SCNVector3(2*flat.x, -5.2*flat.y, flat.z*2)
        base.addChildNode(node)
    }
    
    func load() {
        for p in data.preset { loadMove(p) }
//        setNextMove()
        if data.myTurn != data.turn { queueOpMove() }
    }
    
    func loadMove(_ move: Int) {
        // Assumes no wins!
        let turn = data.turn
        guard data.processMove(move) != nil else { print("Invalid load move!"); return }
        addCube(move: move, color: data.colors[turn])
    }
    
    func rotate(right: Bool) {
        let angle = help.dToR(right ? 90 : -90)
        let rotateAction = SCNAction.rotate(by: angle, around: help.yAxis, duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if cancelBack() {
            let hit = gestureRecognize.location(in: view)
            let hitResults = view.hitTest(hit, options: [:])
            guard let result = hitResults.first?.node else { return }
            if let p = dots.firstIndex(of: result) {
                if data.turn == data.myTurn && data.winner == nil {
                    processMove(p)
                    if data.winner == nil { queueOpMove() }
                }
            } else if moves.contains(result) {
                result.runAction(help.getFullRotate(1.0))
            }
        }
    }
    
    func queueOpMove() {
        let move = data.getMove()
        let pause = data.getPause()
        Timer.scheduledTimer(withTimeInterval: pause, repeats: false) { _ in
            self.processMove(move)
        }
    }
    
    func processMove(_ move: Int) {
        let turn = data.turn
        guard let wins = data.processMove(move) else { print("Invalid move!"); return }
//        let delay = moveCube(move: move, color: data.colors[turn]) + 0.1
        addCube(move: move, color: data.colors[turn])
        moves.last?.runAction(help.getHalfRotate())
        if !wins.isEmpty {
            data.winner = turn
            if turn == data.myTurn { updateWins() }
            Timer.scheduledTimer(withTimeInterval: 0, repeats: false, block: {_ in
                self.showWinLines(wins, self.data.colors[turn])
                self.base.runAction(self.help.getFullRotate(1.45))
            })
        } else {
//            setNextMove()
        }
    }
    
    func showFR() {
        
    }
    
    func moveCube(move: Int, color: UIColor) -> TimeInterval {
        let cube = nextMove ?? help.makeBox(color: color, size: 0.86)
        nextMove?.removeFromParentNode()
        nextMove = nil
        moves.append(cube)
        base.addChildNode(cube)
        let pos = dots[move].simdPosition
        let time = TimeInterval(distance(pos, cube.simdPosition)/40.0 + 0.2)
        let translate = SCNAction.move(to: SCNVector3(pos), duration: time)
        translate.timingMode = .easeIn
        let fade = SCNAction.fadeOut(duration: time)
        fade.timingMode = .easeIn
        cube.runAction(translate)
        dots[move].runAction(fade)
        return time
    }
    
    func addCube(move: Int, color: UIColor) {
        let cube = help.makeBox(color: color, size: 0.86)
        moves.append(cube)
        base.addChildNode(cube)
        cube.position = dots[move].position
        dots[move].opacity = 0
    }
    
    func showWinLines(_ wins: [WinLine], _ color: UIColor) {
        for line in wins {
            let start = SIMD3<Float>(dots[line.start].position)
            let end = SIMD3<Float>(dots[line.end].position)
            let lineNode = help.makeLine(from: start, to: end, color: color)
            base.addChildNode(lineNode)
            currentLines[line.line] = lineNode
        }
    }
    
    func setNextMove() {
        let newMove = help.makeBox(color: data.colors[data.turn], size: 0.86)
        newMove.position = nextMovePos[data.turn == data.myTurn ? 0 : 1]
        scene.rootNode.addChildNode(newMove)
        nextMove = newMove
    }
    
    func updateWins() {
        if data.mode == .daily {
            var streak = UserDefaults.standard.integer(forKey: streakKey)
            let lastDC = UserDefaults.standard.integer(forKey: lastDCKey)
            if lastDC == Date().getInt() { return }
            if lastDC < Date().getInt() - 1 { streak = 0 }
            UserDefaults.standard.setValue(Date().getInt(), forKey: lastDCKey)
            UserDefaults.standard.setValue(streak + 1, forKey: streakKey)
            UIApplication.shared.applicationIconBadgeNumber = 0
            let content = UNMutableNotificationContent()
            content.badge = 1
            var tomorrow = DateComponents()
            tomorrow.hour = 0
            tomorrow.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrow, repeats: false)
            let request = UNNotificationRequest(identifier: badgeKey, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        } else if data.mode == .tricky {
            UserDefaults.standard.setValue([1], forKey: trickyKey)
        } else if data.mode == .beginner {
            UserDefaults.standard.setValue(1, forKey: beginnerKey)
        } else if data.mode == .defender {
            UserDefaults.standard.setValue(1, forKey: defenderKey)
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardScene: BoardScene())
    }
}
