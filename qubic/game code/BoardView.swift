//
//  BoardView.swift
//  qubic
//
//  Created by 4 on 8/15/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct BoardViewRep: UIViewRepresentable {
    private let boardView: BoardView = BoardView()
    func makeUIView(context: Context) -> SCNView { boardView.view }
    func updateUIView(_ scnView: SCNView, context: Context) { }
    func rotate(right: Bool) { boardView.rotate(right: right) }
    func load(_ data: GameData) { boardView.load(data) }
}

private class BoardView {
    var data: GameData = GameData()
    
    let view = SCNView()
    let help = SceneHelper()
    let scene = SCNScene()
    let base = SCNNode()
    let cube: [SCNNode] = (0..<64).map { _ in SceneHelper().makeBox(size: 0.86) }
    var currentLines: [SCNNode?] = Array(repeating: nil, count: 76)
    var selection: SCNNode? = nil
    let normalScale = SCNVector3(1,1,1)
    let selectedScale = SCNVector3(1.3,1.3,1.3)
    
    init() {
        scene.rootNode.addChildNode(help.makeCamera())
        scene.rootNode.addChildNode(help.makeOmniLight())
        scene.rootNode.addChildNode(help.makeAmbiLight())
        for i in 0..<64 {
            let flat = SIMD3<Float>(Float(i/16), Float(i%4), Float((i/4)%4)) - 1.5
            cube[i].position = SCNVector3(2*flat.x, -5.2*flat.y, flat.z*2)
            base.addChildNode(cube[i])
        }
        scene.rootNode.addChildNode(base)
        help.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    func load(_ givenData: GameData) {
        data = givenData
        for p in data.preset { processMove(p) }
        selection?.scale = normalScale
    }
    
    func rotate(right: Bool) {
        let angle = help.dToR(right ? 90 : -90)
        let rotateAction = SCNAction.rotate(by: angle, around: help.yAxis, duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let hit = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(hit, options: [:])
        guard let result = hitResults.first?.node else { clearSelection(); return }
        guard let p = cube.firstIndex(of: result) else { clearSelection(); return }
        if result == selection {
            clearSelection()
            if data.getTurn() == data.myTurn && data.winner == nil {
                processMove(p)
                if data.winner == nil { queueOpMove() }
            }
        } else {
            selectCube(result)
        }
    }
    
    func queueOpMove() {
        let move = data.getMove()
        let pause = data.pauseTime()
        Timer.scheduledTimer(withTimeInterval: pause, repeats: false) { _ in
            self.processMove(move)
        }
    }
    
    func processMove(_ move: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            guard let wins = data.processMove(move) else { print("Invalid move!"); return }
            let n = data.nextTurn()
            cube[move].geometry?.firstMaterial?.diffuse.contents = data.playerColor[n]
            if n != data.myTurn { selectCube(cube[move]) }
            if !wins.isEmpty {
                data.winner = n
                if n == data.myTurn { updateStreak() }
                showWinLines(wins, data.playerColor[n])
                base.runAction(help.getFullRotate())
            }
        }
    }
    
    func showWinLines(_ wins: [WinLine], _ color: UIColor) {
        for line in wins {
            let start = SIMD3<Float>(cube[line.start].position)
            let end = SIMD3<Float>(cube[line.end].position)
            let lineNode = help.makeLine(from: start, to: end, color: color)
            base.addChildNode(lineNode)
            currentLines[line.line] = lineNode
        }
    }
    
    func clearSelection() {
        selection?.scale = normalScale
        selection = nil
    }
    
    func selectCube(_ result: SCNNode) {
        selection?.scale = normalScale
        selection = result
        selection?.scale = selectedScale
    }
    
    func updateStreak() {
        var streak = UserDefaults.standard.integer(forKey: DCStreakKey)
        let lastDC = UserDefaults.standard.integer(forKey: LastDCKey)
        if lastDC == Date().getInt() { return }
        if lastDC < Date().getInt() - 1 { streak = 0 }
        UserDefaults.standard.setValue(Date().getInt(), forKey: LastDCKey)
        UserDefaults.standard.setValue(streak + 1, forKey: DCStreakKey)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardViewRep()
    }
}
