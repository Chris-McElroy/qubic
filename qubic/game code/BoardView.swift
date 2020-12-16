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
    @Published var showDCAlert: Bool = false
    let view = SCNView()
    let scene = SCNScene()
    let base = SCNNode()
    var dots: [SCNNode] = (0..<64).map { _ in SceneHelper.makeDot(color: .primary(33), size: 0.68) } // was let
    var moves: [SCNNode] = []
    var nextMove: SCNNode? = nil
    let nextMovePos = [SCNVector3(0,-11.3,0),SCNVector3(0,11.3,0)]
    var currentLines: [SCNNode?] = Array(repeating: nil, count: 76)
    let normalScale = SCNVector3(1,1,1)
    let selectedScale = SCNVector3(1.3,1.3,1.3)
    
    init() {
        scene.rootNode.addChildNode(SceneHelper.makeCamera())
        scene.rootNode.addChildNode(SceneHelper.makeOmniLight())
        scene.rootNode.addChildNode(SceneHelper.makeAmbiLight())
        for (p, dot) in dots.enumerated() { setPosition(for: dot, at: p) }
        scene.rootNode.addChildNode(base)
        SceneHelper.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func reset() {
        for move in moves {
            move.removeFromParentNode()
        }
        moves.removeAll()
        for dot in dots {
            dot.removeFromParentNode()
        }
        dots = (0..<64).map { _ in SceneHelper.makeDot(color: .primary(33), size: 0.68) }
        for (p, dot) in dots.enumerated() { setPosition(for: dot, at: p) }
        for l in 0..<76 {
            currentLines[l]?.removeFromParentNode()
            currentLines[l] = nil
        }
        nextMove?.removeFromParentNode()
        nextMove = nil
    }
    
    func setPosition(for node: SCNNode, at p: Int) {
        let flat = SIMD3<Float>(Float(p%4), Float(p/16), Float((p/4)%4)) - 1.5
        node.position = SCNVector3(2*flat.x, -5.2*flat.y, flat.z*2)
        base.addChildNode(node)
    }
    
    func load() {
        for p in data.preset { loadMove(p) }
//        setNextMove()
        data.player[data.turn].move(with: processMove)
    }
    
    func loadMove(_ move: Int) {
        // Assumes no wins!
        let turn = data.turn
        guard data.processMove(move) != nil else { print("Invalid load move!"); return }
        addCube(move: move, color: .primary(data.player[turn].color))
    }
    
    func rotate(right: Bool) {
        let rotateAction = SCNAction.rotate(by: right ? .pi/2 : -.pi/2, around: SCNVector3(0,1,0), duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if cancelBack() {
            let hit = gestureRecognize.location(in: view)
            let hitResults = view.hitTest(hit, options: [:])
            guard let result = hitResults.first?.node else { return }
            if let p = dots.firstIndex(where: { $0.childNodes.contains(result) || $0 == result }) {
                if data.winner == nil {
                    if let user = data.player[data.turn] as? User {
                        user.move(at: p)
                    }
                }
            } else if moves.contains(result) {
                result.runAction(SceneHelper.getFullRotate(1.0))
            }
        }
    }
    
    func processMove(_ move: Int) {
        let turn = data.turn
        guard let wins = data.processMove(move) else { print("Invalid move!"); return }
//        let delay = moveCube(move: move, color: data.colors[turn]) + 0.1
        if UserDefaults.standard.integer(forKey: dotKey) == 0 {
            placeCube(move: move, color: .primary(data.player[turn].color))
        } else {
            addCube(move: move, color: .primary(data.player[turn].color))
            moves.last?.runAction(SceneHelper.getHalfRotate())
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        if wins.isEmpty {
            data.player[data.turn].move(with: processMove)
        } else {
            data.winner = turn
            if turn == data.myTurn { updateWins() }
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {_ in
                self.showWinLines(wins, .primary(self.data.player[turn].color))
                self.base.runAction(SceneHelper.getFullRotate(1.45))
            })
        }
    }
    
    func showFR() {
        
    }
    
    func moveCube(move: Int, color: UIColor) -> TimeInterval {
        let cube = nextMove ?? SceneHelper.makeBox(color: color, size: 0.86)
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
        let cube = SceneHelper.makeBox(color: color, size: 0.86)
        moves.append(cube)
        base.addChildNode(cube)
        cube.position = dots[move].position
        dots[move].opacity = 0
    }
    
    func placeCube(move: Int, color: UIColor) {
        let cube = SceneHelper.makeBox(color: color, size: 0.86)
        moves.append(cube)
        base.addChildNode(cube)
        var newPos = dots[move].position
        newPos.y += 0.4
        cube.opacity = 0.3
        cube.position = newPos
        cube.rotation = SCNVector4(.random(in: -1...1), 0, .random(in: -1...1), .random(in: 0.20...0.4))
        let translate = SCNAction.move(to: dots[move].position, duration: 0.16)
        let rotate = SCNAction.rotate(toAxisAngle: SCNVector4(x: 0, y: 0, z: 0, w: 0), duration: 0.16)
        let fade = SCNAction.fadeIn(duration: 0.15)
        rotate.timingMode = .easeIn
        translate.timingMode = .easeIn
        cube.runAction(fade)
        cube.runAction(translate)
        cube.runAction(rotate)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in self.dots[move].opacity = 0 })
    }
    
    func showWinLines(_ wins: [WinLine], _ color: UIColor) {
        for line in wins {
            let start = SIMD3<Float>(dots[line.start].position)
            let end = SIMD3<Float>(dots[line.end].position)
            let lineNode = SceneHelper.makeLine(from: start, to: end, color: color)
            base.addChildNode(lineNode)
            currentLines[line.line] = lineNode
        }
    }
    
    func setNextMove() {
        let newMove = SceneHelper.makeBox(color: .primary(data.player[data.turn].color), size: 0.86)
        newMove.position = nextMovePos[data.turn == data.myTurn ? 0 : 1]
        scene.rootNode.addChildNode(newMove)
        nextMove = newMove
    }
    
    func updateWins() {
        if data.mode == .daily {
            Notifications.ifUndetermined {
                DispatchQueue.main.async {
                    self.showDCAlert = true
                }
            }
            Notifications.setBadge(justSolved: true, dayInt: data.dayInt ?? Date().getInt())
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
