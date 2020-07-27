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
    let scene = SCNScene()
    let help = SceneHelper()
    let name = "cube"

    func makeUIView(context: Context) -> SCNView {
        scene.rootNode.addChildNode(help.makeCamera(pos: SCNVector3(3,3.1,3), rot: SCNVector3(-36,45,0)))
        scene.rootNode.addChildNode(help.makeOmniLight())
        scene.rootNode.addChildNode(help.makeAmbiLight())
        scene.rootNode.addChildNode(help.makeBox(name: name, pos: SCNVector3(0,0,0), color: UIColor(red: 0.15, green: 0.5, blue: 1.0, alpha: 1.0)))
        return help.prepSCNView(scene: scene)
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
    }
    
    public func spinCube(dir: Float) {
        let boxNode = scene.rootNode.childNode(withName: name, recursively: false)
        let rotateAction = SCNAction.rotate(by: help.dToR(90*dir), around: SCNVector3(0,1,0), duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        boxNode?.runAction(rotateAction)
    }
    
    public func flipCube() {
        let boxNode = scene.rootNode.childNode(withName: name, recursively: false)
        let rotateAction = SCNAction.rotate(by: help.dToR(180), around: SCNVector3(1,0,-1), duration: 0.5)
        rotateAction.timingMode = .easeInEaseOut
        boxNode?.runAction(rotateAction)
    }
    
    public func resetCube() {
        let boxNode = scene.rootNode.childNode(withName: name, recursively: false)
        var rot = abs(boxNode?.rotation.w ?? 0)
        while rot > 0.5 { rot -= .pi/4 }
        if abs(rot) > 0.001 {
            let rotateAction = SCNAction.rotate(toAxisAngle: SCNVector4(0,0,0,0), duration: 0.3)
            rotateAction.timingMode = .easeInEaseOut
            boxNode?.runAction(rotateAction)
        }
    }
}

struct CubeView_Previews: PreviewProvider {
    static var previews: some View {
        CubeView()
    }
}
