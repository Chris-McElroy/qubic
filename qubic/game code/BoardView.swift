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

class BoardView {
    var data: GameData = GameData()
    
    let view = SCNView()
    private let help = SceneHelper()
    private let scene = SCNScene()
    private let base = SCNNode()
    private let cube: [SCNNode] = (0..<64).map { _ in SceneHelper().makeBox(size: 0.86) }
    private var currentLines: [SCNNode?] = Array(repeating: nil, count: 76)
    private var selection: SCNNode? = nil
    private let normalScale = SCNVector3(1,1,1)
    private let selectedScale = SCNVector3(1.3,1.3,1.3)
    
    init() {
        addLightsNCamera()
        addCubes()
        help.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    func load(_ givenData: GameData) {
        data = givenData
        addPreset()
    }
    
    private func addLightsNCamera() {
        let pos = SCNVector3(x: -5.65, y: 5.2, z: 10.0)
        let rot = SCNVector3(x: -0.403, y: -0.5135, z: 0)
        scene.rootNode.addChildNode(help.makeCamera(pos: pos, rot: rot, scale: 10))
        scene.rootNode.addChildNode(help.makeOmniLight())
        scene.rootNode.addChildNode(help.makeAmbiLight())
    }
    
    private func addCubes() {
        let xPositions: [CGFloat] = [-3,-1,1,3]
        let yPositions: [CGFloat] = [7.8, 2.6, -2.6, -7.8]
        let zPositions: [CGFloat] = [3,1,-1,-3]
        for i in 0..<64 {
            let x = xPositions[i/16]
            let y = yPositions[i % 4]
            let z = zPositions[(i/4) % 4]
            cube[i].position = SCNVector3(x, y, z)
            base.addChildNode(cube[i])
        }
        scene.rootNode.addChildNode(base)
    }
    
    private func addPreset() {
        for p in data.preset { processMove(p) }
        selection?.scale = normalScale
    }
    
    func rotate(right: Bool) {
        let angle = help.dToR(right ? 90 : -90)
        let rotateAction = SCNAction.rotate(by: angle, around: help.yAxis, duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
    
    @objc private func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let hit = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(hit, options: [:])
        guard let result = hitResults.first?.node else { clearSelection(); return }
        guard let p = cube.firstIndex(of: result) else { clearSelection(); return }
        if result == selection {
            if data.board.getTurn() == data.myTurn {
                processMove(p)
                if data.winner == nil { queueOpMove() }
            }
            clearSelection()
        } else {
            selectCube(result)
        }
    }
    
    private func queueOpMove() {
        let move = data.getMove()
        let pause = Double.random(in: data.board.has1stOrderCheck(data.myTurn) ? 0.6..<1.0 : 2.0..<3.0)
        Timer.scheduledTimer(withTimeInterval: pause, repeats: false) { _ in
            self.processMove(move)
        }
    }
    
    private func processMove(_ move: Int) {
        guard data.board.pointEmpty(move) else { print("point already full"); return }
        guard data.winner == nil else { print("game already won"); return }
        let n = data.board.getTurn()
        let wins = data.board.get1stOrderWinsFor(n)
        data.board.addMove(p: move)
        cube[move].geometry?.firstMaterial?.diffuse.contents = data.playerColor[n]
        if n != data.myTurn { selectCube(cube[move]) }
        if wins.contains(move) { displayWin(move) }
    }
    
    private func displayWin(_ move: Int) {
        let n = inc(data.board.getTurn())
        data.winner = n
        if n == data.myTurn { updateStreak() }
        for l in linesThruPoint[move] {
            if data.board.status[n][l] == 4 && currentLines[l] == nil {
                let start = SIMD3<Float>(cube[pointsInLine[l][0]].position)
                let end = SIMD3<Float>(cube[pointsInLine[l][3]].position)
                let lineNode = help.makeLine(from: start, to: end, color: data.playerColor[n])
                base.addChildNode(lineNode)
                currentLines[l] = lineNode
            }
        }
        let rotate = SCNAction.rotate(by: .pi*2, around: help.yAxis, duration: 1.7)
        rotate.timingMode = .easeOut
        base.runAction(rotate)
    }
    
    private func clearSelection() {
        selection?.scale = normalScale
        selection = nil
    }
    
    private func selectCube(_ result: SCNNode) {
        selection?.scale = normalScale
        selection = result
        selection?.scale = selectedScale
    }
    
    private func updateStreak() {
        var streak = 0
        if let lastDC = UserDefaults.standard.value(forKey: LastDCKey) as? Date, lastDC.isYesterday() {
            streak = UserDefaults.standard.integer(forKey: DCStreakKey)
        }
        UserDefaults.standard.setValue(Date(), forKey: LastDCKey)
        UserDefaults.standard.setValue(streak + 1, forKey: DCStreakKey)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardViewRep()
    }
}
