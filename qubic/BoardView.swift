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
    let boardViewClass: BoardViewClass
    let help = SceneHelper()
    
    init(_ preset: [Int]) {
        boardViewClass = BoardViewClass(preset)
    }
    
    func makeUIView(context: Context) -> SCNView {
        return boardViewClass.view
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
    }
    
    func rotate(right: Bool) {
        let angle = help.dToR(90*(right ? 1 : -1))
        let rotateAction = SCNAction.rotate(by: angle, around: help.yAxis, duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        boardViewClass.base.runAction(rotateAction)
    }
}

class BoardViewClass {
    let playerColor = [getUIColor(1), getUIColor(2)]
    let myTurn: Int
    var winner: Int? = nil
    
    let board = Board()
    let help = SceneHelper()
    let view = SCNView()
    let scene = SCNScene()
    let base = SCNNode()
    let cube: [SCNNode] = (0..<64).map { _ in SceneHelper().makeBox(size: 0.86) }
    var currentLines: Dictionary<Int, SCNNode> = [:]
    var selection: SCNNode? = nil
    let normalScale = SCNVector3(1,1,1)
    let selectedScale = SCNVector3(1.3,1.3,1.3)
    
    init(_ preset: [Int]) {
        myTurn = preset.count % 2
        addLightsNCamera()
        addCubes()
        for p in preset { processMove(p) }
        help.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
//        print("a", preset)
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
    
    @objc private func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//        @Environment(\.preset) var preset: [Int]
//        print("h", preset)
        selection?.scale = normalScale
        let hit = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(hit, options: [:])
        guard let result = hitResults.first?.node else { return }
        guard let p = cube.firstIndex(of: result) else { return }
        if result == selection {
            if getTurn() == myTurn && winner == nil {
                processMove(p)
                queueOpMove()
            }
            selection = nil
        } else {
            selection = result
            selection?.scale = selectedScale
        }
    }
    
    private func processMove(_ move: Int) {
        guard board.pointEmpty(move) else { print("point already full"); return }
        let n = getTurn()
        let wins = board.get1stOrderWinsFor(n)
        board.addMove(p: move)
        cube[move].geometry?.firstMaterial?.diffuse.contents = playerColor[n]
        if wins.contains(move) {
            winner = n
            for l in linesThruPoint[move] {
                if board.status[n][l] == 4 && currentLines[l] == nil {
                    let start = SIMD3<Float>(cube[pointsInLine[l][0]].position)
                    let end = SIMD3<Float>(cube[pointsInLine[l][3]].position)
                    let lineNode = help.makeLine(from: start, to: end)
                    lineNode.geometry?.firstMaterial?.diffuse.contents = playerColor[n]
                    base.addChildNode(lineNode)
                    currentLines[l] = lineNode
                }
            }
            let rotate = SCNAction.rotate(by: .pi*2, around: help.yAxis, duration: 1.7)
            rotate.timingMode = .easeOut
            base.runAction(rotate)
        }
    }

    private func queueOpMove() {
       let opMove = getOpMove()
       let pause = Double.random(in: board.has1stOrderCheck(myTurn) ? 0.5..<1.0 : 2.0..<3.0)
       Timer.scheduledTimer(withTimeInterval: pause, repeats: false, block: { _ in
           self.processMove(opMove)
       })
    }
    
    private func getOpMove() -> Int {
        var options = board.get1stOrderWinsFor(myTurn)
        if options.isEmpty {
            options = Array(0..<64)
            options.removeAll { board.pointFull($0) }
        }
        return options.randomElement() ?? 0
    }
    
    private func getTurn() -> Int {
        return board.move[0].count - board.move[1].count
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView([])
    }
}
