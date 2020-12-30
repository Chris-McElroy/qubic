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
    
    func makeUIView(context: Context) -> SCNView { return boardScene.view }
    func updateUIView(_ scnView: SCNView, context: Context) {
        boardScene.updateColors(for: context.environment.colorScheme)
    }
    
}

class BoardScene {
    let game: Game
    let view =  SCNView()
    let scene = SCNScene()
    let base = SCNNode()
    var dots: [SCNNode] = (0..<64).map { _ in SceneHelper.makeDot(color: .primary(33), size: 0.68) } // was let
    var moves: [SCNNode] = [] // TODO make this a constant array
    var winLines: [SCNNode?] = Array(repeating: nil, count: 76) // TODO same
    
    init(game: Game) {
        self.game = game
        scene.rootNode.addChildNode(SceneHelper.makeCamera())
        scene.rootNode.addChildNode(SceneHelper.makeOmniLight())
        scene.rootNode.addChildNode(SceneHelper.makeAmbiLight())
        for (p, dot) in dots.enumerated() { setPosition(for: dot, at: p) }
        scene.rootNode.addChildNode(base)
        SceneHelper.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func updateColors(for colorScheme: ColorScheme) {
        // TODO fix this shit
        let color: UIColor = colorScheme == .dark ? .white : .black
        for dot in dots {
            for child in dot.childNodes {
                if child.geometry?.name != "clear" {
                    child.setColor(color)
                }
            }
        }
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
            winLines[l]?.removeFromParentNode()
            winLines[l] = nil
        }
    }
    
    func setPosition(for node: SCNNode, at p: Int) {
        let flat = SIMD3<Float>(Float(p%4), Float(p/16), Float((p/4)%4)) - 1.5
        node.position = SCNVector3(2*flat.x, -5.2*flat.y, flat.z*2)
        base.addChildNode(node)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard game.cancelBack() else { return }
        let hit = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(hit, options: [:])
        guard let result = hitResults.first?.node else { return }
        if let p = dots.firstIndex(where: { $0.childNodes.contains(result) || $0 == result }) {
            if let user = game.player[game.myTurn] as? User {
                user.move(at: p)
            }
        } else if moves.contains(result) == true {
            result.runAction(SceneHelper.getFullRotate(1.0))
        }
    }
    
    func showMove(_ move: Int) {
//        let delay = moveCube(move: move, color: game.colors[turn]) + 0.1
        spinDots([])
        if UserDefaults.standard.integer(forKey: dotKey) == 0 {
            placeCube(move: move, color: .primary(game.player[game.turn].color))
        } else {
            addCube(move: move, color: .primary(game.player[game.turn].color))
            moves.last?.runAction(SceneHelper.getHalfRotate())
        }
    }
    
    func showReplayMove(_ move: Int) {
        spinDots([])
        let color = UIColor.primary(game.player[game.turn].color)
        
        if UserDefaults.standard.integer(forKey: dotKey) == 0 {
            placeCube(move: move, color: color, opacity: 0.7)
        } else {
            addCube(move: move, color: color, opacity: 0.7)
            moves.last?.runAction(SceneHelper.getHalfRotate())
        }
    }
    
    func showWin(_ wins: [WinLine]) {
        showWinLines(wins, .primary(game.player[game.winner ?? 0].color))
        base.runAction(SceneHelper.getFullRotate(1.45))
    }
    
    func showWinLines(_ wins: [WinLine], _ color: UIColor) {
        for win in wins {
            let start = SIMD3<Float>(dots[win.start].position)
            let end = SIMD3<Float>(dots[win.end].position)
            let lineNode = SceneHelper.makeLine(from: start, to: end, color: color)
            base.addChildNode(lineNode)
            winLines[win.line] = lineNode
        }
    }
    
    func clearWinLines() {
        for win in winLines {
            win?.removeFromParentNode()
//            win?.opacity = 0
        }
    }
    
    func rotate(right: Bool) {
        let rotateAction = SCNAction.rotate(by: right ? .pi/2 : -.pi/2, around: SCNVector3(0,1,0), duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
    
    func moveCube(move: Int, color: UIColor) -> TimeInterval {
        let cube = SceneHelper.makeBox(color: color, size: 0.86) // was nextMove ??
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
    
    func addCube(move: Int, color: UIColor, opacity: CGFloat = 1.0) {
        let cube = SceneHelper.makeBox(color: color, size: 0.86)
        moves.append(cube)
        base.addChildNode(cube)
        cube.position = dots[move].position
        cube.opacity = opacity
        dots[move].opacity = 0
    }
    
    func placeCube(move: Int, color: UIColor, opacity: CGFloat = 1.0) {
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
        let fade = SCNAction.fadeOpacity(to: opacity, duration: 0.15)
        rotate.timingMode = .easeIn
        translate.timingMode = .easeIn
        let placeAction = SCNAction.group([translate, rotate, fade])
        cube.runAction(placeAction)
        let dotFade = SCNAction.fadeOut(duration: 0.21)
        dotFade.timingFunction = { time in time > 0.2 ? 0 : 1 }
        dots[move].runAction(dotFade)
    }
    
    func undoMove(_ move: Int) {
        guard let cube = moves.popLast() else { return }
        clearWinLines()
        spinDots([])
        let dot = dots[move]
        dot.opacity = 1
        var upPos = cube.position
        upPos.y += 0.4
        let newRot = SCNVector4(.random(in: -1...1), 0, .random(in: -1...1), .random(in: 0.20...0.4))
        let translate = SCNAction.move(to: upPos, duration: 0.16)
        let rotate = SCNAction.rotate(toAxisAngle: newRot, duration: 0.16)
        let fade = SCNAction.fadeOut(duration: 0.15)
        rotate.timingMode = .easeIn
        translate.timingMode = .easeIn
        let unPlaceAction = SCNAction.group([translate, rotate, fade])
        cube.runAction(unPlaceAction)
        Timer.scheduledTimer(withTimeInterval: 0.20, repeats: false, block: { _ in
            cube.removeFromParentNode()
        })
    }
    
    func remove(_ move: Int) {
        guard let cube = moves.popLast() else { return }
        let dot = dots[move]
        dot.opacity = 1
        cube.opacity = 0
        cube.removeFromParentNode()
    }
    
    func spinDots(_ list: Set<Int>) {
        let spin = SCNAction.rotate(by: .pi*2, around: SCNVector3(0,1,0), duration: 1.0)
        let spinBack = SCNAction.rotate(toAxisAngle: SCNVector4(0,1,0,0), duration: 0.1)
        let longSpin = SCNAction.repeatForever(spin)
        for (i,d) in dots.enumerated() {
            if list.contains(i) {
                d.runAction(longSpin)
            } else {
                d.removeAllActions()
                d.runAction(spinBack)
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardScene: BoardScene(game: Game()))
    }
}
