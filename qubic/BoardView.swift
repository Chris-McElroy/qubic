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
    let scene = SCNScene()
    let help = SceneHelper()
    let base = SCNNode()
    let cube: [SCNNode] = (0..<64).map { _ in SceneHelper().makeBox(size: 0.86) }
    
    func makeUIView(context: Context) -> SCNView {
        addLightsNCamera()
        addCubes()
        return help.prepSCNView(scene: scene)
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
    }
    
    func addLightsNCamera() {
        let pos = SCNVector3(x: -5.65, y: 5.2, z: 10.0)
        let rot = SCNVector3(x: -0.403, y: -0.5135, z: 0)
        scene.rootNode.addChildNode(help.makeCamera(pos: pos, rot: rot, scale: 10))
        scene.rootNode.addChildNode(help.makeOmniLight())
        scene.rootNode.addChildNode(help.makeAmbiLight())
    }
    
    func addCubes() {
        base.position = SCNVector3(0,0,0)
        let xPositions: [CGFloat] = [-3,-1,1,3]
        let yPositions: [CGFloat] = [7.8, 2.6, -2.6, -7.8]
        let zPositions: [CGFloat] = [3,1,-1,-3]
        for i in 0..<64 {
            let x = i/16
            let y = i % 4
            let z = (i/4) % 4
            cube[i].position = SCNVector3(xPositions[x], yPositions[y], zPositions[z])
            base.addChildNode(cube[i])
        }
        scene.rootNode.addChildNode(base)
    }
    
    public func rotate(right: Bool) {
        print(right)
        let angle = help.dToR(90*(right ? 1 : -1))
        let rotateAction = SCNAction.rotate(by: angle, around: SCNVector3(0,1,0), duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}
