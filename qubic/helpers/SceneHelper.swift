//
//  SceneHelper.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SceneKit

struct SceneHelper {
    func makeCamera(pos: SCNVector3, rot: SCNVector3, scale: Double) -> SCNNode {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = pos
        cameraNode.eulerAngles = rot
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = scale
        return cameraNode
    }
    
    func makeOmniLight() -> SCNNode {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
        omniLightNode.light?.attenuationStartDistance = 2000
        omniLightNode.position = SCNVector3(x: -25, y: 250, z: 100)
        return omniLightNode
    }
    
    func makeAmbiLight() -> SCNNode {
        let ambiLightNode = SCNNode()
        ambiLightNode.light = SCNLight()
        ambiLightNode.light?.type = SCNLight.LightType.ambient
        ambiLightNode.light?.color = UIColor(white: 0.4, alpha: 1.0)
        return ambiLightNode
    }
    
    func makeBox(color: UIColor = UIColor.null, size: CGFloat = 1.0) -> SCNNode {
        let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.geometry?.firstMaterial?.diffuse.contents = color
        return boxNode
    }
    
    func makeBox(name: String, pos: SCNVector3, color: UIColor = UIColor.null, size: CGFloat = 1.0) -> SCNNode {
        let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = name
        boxNode.geometry?.firstMaterial?.diffuse.contents = color
        boxNode.position = pos
        return boxNode
    }
    
    func prepSCNView(view: SCNView, scene: SCNScene) {
        view.scene = scene
        view.allowsCameraControl = false
        view.showsStatistics = false
        view.backgroundColor = UIColor.systemBackground
    }
    
    func makeQuaternion(_ x: Double, _ y: Double, _ z: Double, _ d: Float) -> SCNQuaternion {
        let glkq = makeGLKQuaternion(x, y, z, d)
        return SCNQuaternion(x: glkq.x, y: glkq.y, z: glkq.z, w: glkq.w)
    }
    
    func makeGLKQuaternion(_ x: Double, _ y: Double, _ z: Double, _ d: Float) -> GLKQuaternion {
        let l: Double = sqrt(pow(x,2) + pow(y,2) + pow(z,2))
        let normAxis = GLKVector3(v:(Float(x/l),Float(y/l),Float(z/l)))
        return GLKQuaternionMakeWithAngleAndVector3Axis(Float(dToR(d)), normAxis)
    }
    
    func dToR(_ degrees: Float) -> CGFloat {
        return CGFloat(GLKMathDegreesToRadians(degrees))
    }
    
    let yAxis = SCNVector3(0,1,0)
    let yAxisSIMD = SIMD3<Float>(0,1,0)
//
//    func fillSpace(from start: SCNVector3, to end: SCNVector3) -> SCNNode {
//        let offsets: [[SIMD3<Float>]] = [
//            [SIMD3(1,1,0),SIMD3(1,1,1),SIMD3(1,0,1),SIMD3(0,0,1),
//             SIMD3(0,0,0),SIMD3(0,1,0),SIMD3(0,1,1)],  // no (1,0,0)
//            [SIMD3(1,1,1),SIMD3(0,1,1),SIMD3(0,0,1),SIMD3(0,0,0),
//             SIMD3(1,0,0),SIMD3(1,1,0),SIMD3(0,1,0)],  // no (1,0,1)
//            [SIMD3(1,0,0),SIMD3(0,0,0),SIMD3(0,1,0),SIMD3(0,1,1),
//             SIMD3(1,1,1),SIMD3(1,0,1),SIMD3(0,0,1)],  // no (1,1,0)
//            [SIMD3(1,0,1),SIMD3(1,0,0),SIMD3(1,1,0),SIMD3(0,1,0),
//             SIMD3(0,1,1),SIMD3(0,0,1),SIMD3(0,0,0)]   // no (1,1,1)
//        ]
//
//        let indices: [UInt16] = [
//            0,  1,  6,  5,  0,  6,  // bottom
//            3,  2,  1,  6,  3,  1,  // back left
//            4,  3,  6,  5,  4,  6,  // back right
//            11, 1,  2, 12, 11,  2,  // left side
//            11, 2,  1, 12, 2,  11,  // left side 2
//            2,  3,  7, 12,  2,  7,  // top left side
//            2,  7,  3, 12,  7,  2,  // top left side 2
//            8,  7,  3,  4,  8,  3,  // top right side
//            8,  3,  7,  4,  3,  8,  // top right side 2
//            8,  4,  5,  9,  8,  5,  // right side
//            8,  5,  4,  9,  5,  8,  // right side 2
//            9,  5,  0, 10,  9,  0,  // bottom right side
//            9,  0,  5, 10,  0,  9,  // bottom right side 2
//            0,  1, 11, 10,  0, 11,  // bottom left side
//            0, 11,  1, 10, 11,  0,  // bottom left side 2
//            7,  8, 13,  7, 13, 12,  // top
//            8,  9, 10,  8, 10, 13,  // front left
//           10, 11, 13, 11, 12, 13   // front right
//        ]
//
//        let dir = 2*(start.y < end.y ? 1 : 0) + (start.z < end.z ? 1 : 0)
//        let size: Float = 0.86
//        var vertices = offsets[dir].map { SIMD3(start) + ($0 - 0.5)*size }
//        vertices.append(contentsOf: offsets[dir].map { SIMD3(end) + (0.5 - $0)*size })
//        let source = SCNGeometrySource.init(vertices: vertices.map { SCNVector3($0) })
//        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
//        let geometry = SCNGeometry(sources: [source], elements: [element])
//        let node = SCNNode(geometry: geometry)
//        return node
//    }
    
    func makeLine(from start: SIMD3<Float>, to end: SIMD3<Float>, color: UIColor) -> SCNNode {
        let vector = end - start
        let line = SCNCylinder(radius: 0.05, height: CGFloat(simd_length(vector)))
        let lineNode = SCNNode(geometry: line)
        lineNode.simdPosition = (start + end)/2
        let vector_cross = simd_cross(yAxisSIMD, vector)
        let qw = simd_length(yAxisSIMD) * simd_length(vector) + simd_dot(yAxisSIMD, vector)
        let q = simd_quatf(ix: vector_cross.x, iy: vector_cross.y, iz: vector_cross.z, r: qw)
        lineNode.simdRotate(by: q.normalized, aroundTarget: lineNode.simdPosition)
        lineNode.geometry?.firstMaterial?.diffuse.contents = color
        return lineNode
    }
}

//extension SCNVector3 {
//    static func +(left: SCNVector3, right: [Float]) -> SCNVector3 {
//        return SCNVector3(left.x + right[0], left.y + right[1], left.z + right[2])
//    }
//
//    static func -(left: SCNVector3, right: (Float,Float,Float)) -> SCNVector3 {
//        return SCNVector3(left.x - right.0, left.y - right.1, left.z - right.2)
//    }
//}
