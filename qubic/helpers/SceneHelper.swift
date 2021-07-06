//
//  SceneHelper.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SceneKit

var lineWidth: CGFloat = 0.008

class SceneHelper {
    static func makeCamera(pos: SCNVector3, rot: SCNVector3, scale: Double) -> SCNNode {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = pos
        cameraNode.eulerAngles = rot
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = scale
        return cameraNode
    }
    
    static func makeCamera() -> SCNNode {
        let pos = SCNVector3(x: -5.65, y: 4.9, z: 10.0)
        let rot = SCNVector3(x: -0.403, y: -0.5135, z: 0)
        let scale = 9.5
        return makeCamera(pos: pos, rot: rot, scale: scale)
    }
    
    static func makeOmniLight() -> SCNNode {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
        omniLightNode.light?.attenuationStartDistance = 2000
        omniLightNode.position = SCNVector3(x: -25, y: 250, z: 100)
        return omniLightNode
    }
    
    static func makeAmbiLight() -> SCNNode {
        let ambiLightNode = SCNNode()
        ambiLightNode.light = SCNLight()
        ambiLightNode.light?.type = SCNLight.LightType.ambient
        ambiLightNode.light?.color = UIColor(white: 0.4, alpha: 1.0)
        return ambiLightNode
    }
    
    static func makeBox(size: CGFloat = 1.0) -> SCNNode {
        let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        return boxNode
    }
    
//    static func makeDot(color: UIColor = UIColor.null, size: CGFloat = 1.0) -> SCNNode {
//        var dotNode = getSpace(size: 0.86-3*lineWidth)
//        let dotType = Storage.int(.dot)
//        if dotType == 1 {
//            dotNode = getBlankCube(size: 0.52)
//        } else if dotType == 2 {
//            dotNode = SCNNode(geometry: SCNBox(width: size, height: size, length: size, chamferRadius: 0))
//            dotNode.setColor(color)
//        } else if dotType == 3 {
//            dotNode = SCNNode(geometry: SCNSphere(radius: 0.45))
//            dotNode.setColor(color)
//        } else if dotType == 4 {
//            dotNode = getAxesPoint(size: 0.6)
//        }
//        return dotNode
//    }
    
//    static func getAxesPoint(size: CGFloat) -> SCNNode {
//        let line = SCNCylinder(radius: lineWidth, height: size)
//        line.firstMaterial?.diffuse.contents = UIColor.label
//        let xNode = SCNNode(geometry: line)
//        let yNode = SCNNode(geometry: line)
//        let zNode = SCNNode(geometry: line)
//        xNode.rotation = SCNVector4(0,0,1,CGFloat.pi/2)
//        zNode.rotation = SCNVector4(1,0,0,CGFloat.pi/2)
//        let base = SCNNode(geometry: SCNSphere(radius: 0.45))
//        base.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
////        let core = SCNNode(geometry: SCNSphere(radius: 0.04))
////        core.setColor(.black)
//        base.addChildNode(xNode)
//        base.addChildNode(yNode)
//        base.addChildNode(zNode)
////        base.addChildNode(core)
//        return base
//    }
//
//    static func getBlankCube(size: CGFloat) -> SCNNode {
//        let line = SCNCylinder(radius: lineWidth, height: size)
//        let xNodes = (0..<4).map { _ in SCNNode(geometry: line) }
//        let yNodes = (0..<4).map { _ in SCNNode(geometry: line) }
//        let zNodes = (0..<4).map { _ in SCNNode(geometry: line) }
//        let offsets = [(-size/2,-size/2),(size/2,-size/2),(-size/2,size/2),(size/2,size/2)]
//        xNodes.forEach { $0.rotation = SCNVector4(0,0,1,CGFloat.pi/2) }
//        zNodes.forEach { $0.rotation = SCNVector4(1,0,0,CGFloat.pi/2) }
//        xNodes.forEach { $0.setColor(.label) }
//        yNodes.forEach { $0.setColor(.label) }
//        zNodes.forEach { $0.setColor(.label) }
//        let base = SCNNode(geometry: SCNSphere(radius: 0.45))
//        base.setColor(.clear)
//        xNodes.forEach { base.addChildNode($0) }
//        yNodes.forEach { base.addChildNode($0) }
//        zNodes.forEach { base.addChildNode($0) }
//        for (i,node) in xNodes.enumerated() {
//            node.position = SCNVector3(0,offsets[i].0,offsets[i].1)
//        }
//        for (i,node) in yNodes.enumerated() {
//            node.position = SCNVector3(offsets[i].0,0,offsets[i].1)
//        }
//        for (i,node) in zNodes.enumerated() {
//            node.position = SCNVector3(offsets[i].0,offsets[i].1,0)
//        }
//        return base
//    }
    
    static func getSpace(size: CGFloat) -> SCNNode {
        let line = SCNCylinder(radius: lineWidth, height: size)
        let short = size/4.2
        let shortLine = SCNCylinder(radius: lineWidth, height: short)
        let xNodes = (0..<4).map { _ in SCNNode(geometry: line) }
        let yNodes = (0..<4).map { _ in SCNNode(geometry: shortLine) }
        let zNodes = (0..<4).map { _ in SCNNode(geometry: line) }
        let xOffsets = [(-size/2,-size/2),(-size/2+short,-size/2),(-size/2,size/2),(-size/2+short,size/2)]
        let yOffsets = [(-size/2,-size/2),(size/2,-size/2),(-size/2,size/2),(size/2,size/2)]
        let zOffsets = [(-size/2,-size/2),(size/2,-size/2),(-size/2,-size/2+short),(size/2,-size/2+short)]
        xNodes.forEach { $0.rotation = SCNVector4(0,0,1,CGFloat.pi/2) }
        zNodes.forEach { $0.rotation = SCNVector4(1,0,0,CGFloat.pi/2) }
        xNodes.forEach { $0.setColor(.label) }
        yNodes.forEach { $0.setColor(.label) }
        zNodes.forEach { $0.setColor(.label) }
        let box = SCNBox(width: 0.9, height: 0.34, length: 0.9, chamferRadius: 0)
        box.name = "clear"
        let wef = SCNNode(geometry: box)
        let base = SCNNode(geometry: SCNSphere(radius: 0.35))
        base.addChildNode(wef)
        wef.position.y = -0.43+0.17
        wef.setColor(.clear)
        base.setColor(.clear)
        xNodes.forEach { base.addChildNode($0) }
        yNodes.forEach { base.addChildNode($0) }
        zNodes.forEach { base.addChildNode($0) }
        for (i,node) in xNodes.enumerated() {
            node.position = SCNVector3(0,xOffsets[i].0,xOffsets[i].1)
        }
        for (i,node) in yNodes.enumerated() {
            node.position = SCNVector3(yOffsets[i].0,-size/2+short/2,yOffsets[i].1)
        }
        for (i,node) in zNodes.enumerated() {
            node.position = SCNVector3(zOffsets[i].0,zOffsets[i].1,0)
        }
        return base
    }
    
    static func makeBox(name: String, pos: SCNVector3, color: UIColor = UIColor.null, size: CGFloat = 1.0) -> SCNNode {
        let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = name
        boxNode.setColor(color)
        boxNode.position = pos
        return boxNode
    }
    
    static func prepSCNView(view: SCNView, scene: SCNScene) {
        view.scene = scene
        view.allowsCameraControl = false
        view.showsStatistics = false
        view.backgroundColor = UIColor.systemBackground
    }
    
//    func makeQuaternion(_ x: Double, _ y: Double, _ z: Double, _ d: Float) -> SCNQuaternion {
//        let glkq = makeGLKQuaternion(x, y, z, d)
//        return SCNQuaternion(x: glkq.x, y: glkq.y, z: glkq.z, w: glkq.w)
//    }
//    
//    func makeGLKQuaternion(_ x: Double, _ y: Double, _ z: Double, _ d: Float) -> GLKQuaternion {
//        let l: Double = sqrt(pow(x,2) + pow(y,2) + pow(z,2))
//        let normAxis = GLKVector3(v:(Float(x/l),Float(y/l),Float(z/l)))
//        return GLKQuaternionMakeWithAngleAndVector3Axis(Float(dToR(d)), normAxis)
//    }
    
    static func getFullRotate(_ time: Double) -> SCNAction {
        let yAxis = SCNVector3(0,1,0)
        let rotate = SCNAction.rotate(by: .pi*2, around: yAxis, duration: time)
        rotate.timingMode = .easeOut
        return rotate
    }
    
    static func getHalfRotate() -> SCNAction {
        let yAxis = SCNVector3(0,1,0)
        let rotate = SCNAction.rotate(by: .pi, around: yAxis, duration: 0.5)
        rotate.timingMode = .easeOut
        return rotate
    }
    
//    static let yAxis = SCNVector3(0,1,0)
//    sttaic let yAxisSIMD = SIMD3<Float>(0,1,0)
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
    
    static func makeLine(from start: SIMD3<Float>, to end: SIMD3<Float>) -> SCNNode {
        let yAxisSIMD = SIMD3<Float>(0,1,0)
        let vector = end - start
        let line = SCNCylinder(radius: 0.05, height: CGFloat(simd_length(vector)))
        let lineNode = SCNNode(geometry: line)
        lineNode.simdPosition = (start + end)/2
        let vector_cross = simd_cross(yAxisSIMD, vector)
        let qw = simd_length(yAxisSIMD) * simd_length(vector) + simd_dot(yAxisSIMD, vector)
        let q = simd_quatf(ix: vector_cross.x, iy: vector_cross.y, iz: vector_cross.z, r: qw)
        lineNode.simdRotate(by: q.normalized, aroundTarget: lineNode.simdPosition)
        return lineNode
    }
}

extension SCNNode {
    func setColor(_ color: UIColor) {
        self.geometry?.firstMaterial?.diffuse.contents = color
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
