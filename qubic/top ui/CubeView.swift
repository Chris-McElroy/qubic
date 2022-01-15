//
//  CubeView.swift
//  qubic
//
//  Created by 4 on 7/27/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct CubeView : UIViewRepresentable {
    let view = SCNView()
    let scene = SCNScene()
    let cube = SceneHelper.makeBox()

    func makeUIView(context: Context) -> SCNView {
        let pos = SCNVector3(-2.0,2.0,2.0)
        let rot = SCNVector3(-0.615479709,-.pi/4,0.0) // magic number is -atan(1/sqrt(2))
		scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        scene.rootNode.addChildNode(SceneHelper.makeCamera(pos: pos, rot: rot, scale: 1))
        scene.rootNode.addChildNode(SceneHelper.makeOmniLight())
        scene.rootNode.addChildNode(SceneHelper.makeAmbiLight())
        cube.setColor(.primary())
        scene.rootNode.addChildNode(cube)
        SceneHelper.prepSCNView(view: view, scene: scene)
        return view
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        cube.setColor(.primary())
    }
    
    func rotate(right: Bool) {
        let angle: CGFloat = .pi/2*(right ? 1 : -1)
        let rotateAction = SCNAction.rotate(by: angle, around: SCNVector3(0,1,0), duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        cube.runAction(rotateAction)
    }
    
	func flipCube(duration: TimeInterval = 0.5) {
        let rotateAction = SCNAction.rotate(by: .pi, around: SCNVector3(1,0,1), duration: duration)
        rotateAction.timingMode = .easeInEaseOut
        cube.runAction(rotateAction)
    }
    
    func resetCube() {
        var rot = abs(cube.rotation.w)
        while rot > 0.5 { rot -= .pi/4 }
        if abs(rot) > 0.001 {
            let rotateAction = SCNAction.rotate(toAxisAngle: SCNVector4(0,0,0,0), duration: 0.3)
            rotateAction.timingMode = .easeInEaseOut
            cube.runAction(rotateAction)
        }
    }
}

struct CubeView_Previews: PreviewProvider {
    static var previews: some View {
        CubeView()
    }
}
