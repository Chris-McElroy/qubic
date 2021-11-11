//
//  TutorialBoardView.swift
//  qubic
//
//  Created by Chris McElroy on 11/7/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct TutorialBoardView: UIViewRepresentable {
	func makeUIView(context: Context) -> SCNView { return TutorialBoardScene.tutorialMain.view }
	func updateUIView(_ scnView: SCNView, context: Context) { }
}

class TutorialBoardScene: BoardScene {
	static let tutorialMain = TutorialBoardScene()
	var pannedOut = false
	
	override init() {
		super.init()
		reset()
	}
	
	override func reset() {
		super.reset()
		
		camera.position = SCNVector3(-1, 10, -1)
		camera.rotation = SCNVector4(1, 0, 0, -Float.pi/2)
		camera.camera?.orthographicScale = 6.7
		
		for i in 0..<64 where ![0, 1, 2, 4, 5, 6, 8, 9, 10].contains(i) {
			self.spaces[i].opacity = 0
		}
		
		pannedOut = false
	}
	
	@objc override func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		guard pannedOut else {
			if TutorialLayout.main.readyToContinue {
				panOut()
			}
			return
		}
	}
	
	func panOut() {
		pannedOut = true
		
		let duration1 = 1.2
		let zoomAction = SCNAction.customAction(duration: duration1, action: { node, time in
			node.camera?.orthographicScale = 6.7 + (9.5 - 6.7)*(time / duration1)
		})
		let moveAction1 = SCNAction.move(to: SCNVector3(x: 0, y: 10, z: 0), duration: duration1)
		let rotateAction1 = SCNAction.rotate(by: -0.53, around: SCNVector3(0,1,0), duration: duration1)
		let cameraMove1 = SCNAction.group([zoomAction, moveAction1, rotateAction1])
		cameraMove1.timingMode = .easeInEaseOut
		camera.runAction(cameraMove1)
		
		let fadeInAction = SCNAction.fadeIn(duration: 0.6)
		fadeInAction.timingMode = .easeInEaseOut
		
		for i in 0..<64 where ![0, 1, 2, 4, 5, 6, 8, 9, 10].contains(i) {
			spaces[i].runAction(fadeInAction)
		}
		
		let duration2 = 1.6
		let moveAction2 = SCNAction.move(to: SCNVector3(x: -5.65, y: 4.9, z: 10.0), duration: duration2)
		let rotateAction2 = SCNAction.rotateTo(x: -0.403, y: -0.5135, z: 0, duration: duration2, usesShortestUnitArc: true)
		let cameraMove2 = SCNAction.group([moveAction2, rotateAction2])
		cameraMove2.timingMode = .easeInEaseOut
		Timer.after(duration1) { self.camera.runAction(cameraMove2) }
	}
}
