//
//  SceneHelper.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import Foundation
import SceneKit

struct SceneHelper {
    func makeCamera(pos: SCNVector3, rot: SCNVector3) -> SCNNode {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.position = pos
        cameraNode.eulerAngles.x = GLKMathDegreesToRadians(rot.x)
        cameraNode.eulerAngles.y = GLKMathDegreesToRadians(rot.y)
        cameraNode.eulerAngles.z = GLKMathDegreesToRadians(rot.z)
        return cameraNode
    }
    
    func makeOmniLight() -> SCNNode {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = UIColor(white: 0.85, alpha: 1.0)
        omniLightNode.position = SCNVector3(x: 100, y: 250, z: -25)
        omniLightNode.light?.attenuationStartDistance = 1000
        return omniLightNode
    }
    
    func makeAmbiLight() -> SCNNode {
        let ambiLightNode = SCNNode()
        ambiLightNode.light = SCNLight()
        ambiLightNode.light?.type = SCNLight.LightType.ambient
        ambiLightNode.light?.color = UIColor(white: 0.5, alpha: 1.0)
        return ambiLightNode
    }
    
    func makeBox(name: String, pos: SCNVector3, color: UIColor) -> SCNNode {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = name
        boxNode.geometry?.firstMaterial?.diffuse.contents = color
        boxNode.position = pos
        return boxNode
    }
    
    func prepSCNView(scene: SCNScene) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.systemBackground
        return scnView
    }
}
