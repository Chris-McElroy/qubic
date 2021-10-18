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
    func makeUIView(context: Context) -> SCNView { return BoardScene.main.view }
    func updateUIView(_ scnView: SCNView, context: Context) {
		// see below comment for explanation
//        BoardScene.main.updateColors(for: context.environment.colorScheme)
    }
}

class BoardScene {
    static let main = BoardScene()
    
    let view =  SCNView()
    let scene = SCNScene()
    let base = SCNNode()
    var spaces: [SCNNode] = (0..<64).map { _ in SceneHelper.getSpace(size: 0.86-3*lineWidth) } // size was color: .primary(33), size: 0.68
	let moves: [SCNNode] = (0..<64).map { _ in SceneHelper.makeBox(size: 0.86, name: "cube") }
    let winLines: [SCNNode] = (0..<76).map {
        let start = SIMD3<Float>(coords(for: Board.pointsInLine[$0][0]))
        let end = SIMD3<Float>(coords(for: Board.pointsInLine[$0][3]))
        return SceneHelper.makeLine(from: start, to: end)
    }
	var mostRecentRotate: CGPoint? = nil
	var rotationStart: SCNVector4 = SCNVector4(0,0,0,0)
	var mostRecentTap: Date? = nil
	var potentialMove: Int? = nil
//	var rotationSpeed: CGFloat = 0
//	var lastRotationAngle: CGFloat = 0
//	var lastRotationTime: Date = Date()
//	var wentSlow: Bool = true
	
    init() {
        scene.rootNode.addChildNode(SceneHelper.makeCamera())
        scene.rootNode.addChildNode(SceneHelper.makeOmniLight())
        scene.rootNode.addChildNode(SceneHelper.makeAmbiLight())
        for (p, space) in spaces.enumerated() {
            space.position = BoardScene.coords(for: p)
			moves[p].opacity = 0
			space.addChildNode(moves[p])
            base.addChildNode(space)
        }
        scene.rootNode.addChildNode(base)
        SceneHelper.prepSCNView(view: view, scene: scene)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
	// commenting out because i think this was actually causing the problem
	/*
	 it was:
	 - not checking the correct names (should be child.name for most of them)
	 - making things .white or .black so if it missed an update later it would break
	 
	 if there still is an issue, i can use the sceneWillEnterForeground function in sceneDelegate to trigger a change
	 
	 */
//    func updateColors(for colorScheme: ColorScheme) {
//        let color: UIColor = colorScheme == .dark ? .white : .black
//		print(color == UIColor.white)
//        for space in spaces {
//            for child in space.childNodes {
//                if child.geometry?.name != "clear" {
//                    child.setColor(color)
//                }
//            }
//        }
//    }
    
    func reset() {
		base.removeAllActions()
		Timer.after(0.1, run: {
			self.base.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
		})
        
        for move in moves {
            move.removeAllActions()
			Timer.after(0.1, run: {
				move.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
			})
			move.opacity = 0
			move.position = SCNVector3(0,0,0)
        }
        for space in spaces {
            space.removeAllActions()
			Timer.after(0.1, run: {
				space.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
			})
//            dot.removeFromParentNode()
        }
//        dots = (0..<64).map { _ in SceneHelper.makeDot(color: .primary(33), size: 0.68) }
//        for (p, dot) in dots.enumerated() {
//            dot.position = BoardScene.coords(for: p)
//            base.addChildNode(dot)
//        }
        for l in 0..<76 {
            winLines[l].removeFromParentNode()
        }
		
		potentialMove = nil
    }
    
    func resetSpaces() {
        for space in spaces {
            space.removeFromParentNode()
        }
        spaces = (0..<64).map { _ in SceneHelper.getSpace(size: 0.86-3*lineWidth) }
        for (p, space) in spaces.enumerated() {
            space.position = BoardScene.coords(for: p)
			space.addChildNode(moves[p])
            base.addChildNode(space)
        }
    }
	
	func updateSpaceColors() {
		for (p, space) in spaces.enumerated() {
			for part in space.childNodes {
				if part.name == "clear" {
					part.setColor(.clear)
				} else if part.name != "cube" {
					part.setColor(.label)
				}
			}
			let moveDown = moves[p].parent != nil && moves[p].position.y == space.position.y
			space.opacity = moveDown ? 0 : 1
		}
	}
    
    static func coords(for p: Int) -> SCNVector3 {
        let flat = SIMD3<Float>(Float(p%4), Float(p/16), Float((p/4)%4)) - 1.5
        return SCNVector3(2*flat.x, -5.2*flat.y, flat.z*2)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		if GameLayout.main.hidePopups() { return }
        let hit = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(hit, options: [:])
        guard let result = hitResults.first?.node else {
			if let oldTap = mostRecentTap, oldTap.distance(to: Date()) < 0.5 {
				resetRotation()
				mostRecentTap = nil
			} else {
				mostRecentTap = Date()
			}
			return
		}
        if let p = spaces.firstIndex(where: { $0.childNodes.contains(result) || $0 == result }) {
			if moves[p].opacity > 0 {
				// make sure it's settled to avoid rowen's bug
				if moves[p].position.y == 0 {
					spaces[p].runAction(SceneHelper.getFullRotate(1.0))
				}
				return
			}
            let turn = Game.main.gameState == .active ? Game.main.turn : Game.main.myTurn
			if Game.main.gameState == .active && GameLayout.main.nextOpacity == .full {
				Game.main.notificationGenerator.notificationOccurred(.error)
				GameLayout.main.flashNextArrow()
				// TODO shouldn't this return here??
            }
            if let user = Game.main.player[turn] as? User, Game.main.premoves.isEmpty {
				if Storage.int(.confirmMoves) == 0 {
					if p == potentialMove {
						potentialMove = nil
						spinMoves()
						user.move(at: p)
					} else {
						potentialMove = potentialMove == nil ? p : nil
						spinMoves()
					}
				} else {
					user.move(at: p)
				}
            } else if Game.main.gameState == .active && Storage.int(.premoves) == 0 {
                if Game.main.premoves.contains(p) {
                    Game.main.premoves = []
                } else {
                    Game.main.premoves.append(p)
                }
                spinMoves()
            }
		}
    }
    
    func showMove(_ move: Int, wins: [Int]?, ghost: Bool = false) {
//        let delay = moveCube(move: move, color: game.colors[turn]) + 0.1
        spinMoves()
        let turn = Game.main.turn^1
        let color = UIColor.of(n: Game.main.player[turn].color)
        placeCube(move: move, color: color, opacity: ghost ? 0.7 : 1)
        
        if let lines = wins {
            showWins(lines, color: color, ghost: ghost)
        } else if !ghost && Game.main.gameState != .active && Game.main.movesBack == 0 {
			print("got here", Game.main.gameState)
            spinBoard()
        }
        
//        if Storage.int(.dot) == 0 {
//        } else {
//            addCube(move: move, color: color, opacity: ghost ? 0.7 : 1)
//            moves.last?.runAction(SceneHelper.getHalfRotate())
//        }
    }
    
    private func showWins(_ lines: [Int], color: UIColor, ghost: Bool = false) {
        Game.main.timers.append(Timer.after(0.2, run: {
            for line in lines {
                self.winLines[line].setColor(color)
                self.winLines[line].opacity = ghost ? 0.3 : 1
                self.base.addChildNode(self.winLines[line])
            }
            if !ghost { self.spinBoard() }
        }))
    }
    
    func spinBoard() {
        base.runAction(SceneHelper.getFullRotate(1.45))
    }
    
    private func hideWins(_ lines: [Int]) {
        for line in lines {
            winLines[line].opacity = 0
            winLines[line].removeFromParentNode()
        }
    }
    
    func rotate(right: Bool) {
        let rotateAction = SCNAction.rotate(by: right ? .pi/2 : -.pi/2, around: SCNVector3(0,1,0), duration: 0.4)
        rotateAction.timingMode = .easeInEaseOut
        base.runAction(rotateAction)
    }
	
	func rotate(angle: CGFloat, start: CGPoint) {
		if start != mostRecentRotate {
			mostRecentRotate = start
			rotationStart = base.rotation
//			wentSlow = false
		}
//		let lastSpeed = abs(rotationSpeed)
//		rotationSpeed = (angle - lastRotationAngle)/CGFloat(lastRotationTime.distance(to: time) + 0.000001)
//		if !wentSlow && max(lastSpeed, abs(rotationSpeed)) < 200 && min(lastSpeed, abs(rotationSpeed)) > 0.01 { wentSlow = true }
//		lastRotationTime = time
//		lastRotationAngle = angle
		var nextRotation = rotationStart
		nextRotation.y = nextRotation.y >= 0 ? 1 : -1
		nextRotation.w += Float(angle/150)*nextRotation.y
		let rotateAction = SCNAction.rotate(toAxisAngle: nextRotation, duration: 0.1)
		rotateAction.timingMode = .easeOut
		base.runAction(rotateAction)
	}
	
	func resetRotation() {
		base.removeAllActions()
		Game.main.timers.append(Timer.after(0.1, run: {
			let newW = (self.base.rotation.w / (.pi/2)).rounded(.toNearestOrAwayFromZero) * .pi/2
			let distance = Double(abs(self.base.rotation.w - newW))
			let newRot = SCNVector4(0, self.base.rotation.y, 0, newW)
			if distance > 0.001 {
				let rotateAction = SCNAction.rotate(toAxisAngle: newRot, duration: max(0.1, distance/3))
				rotateAction.timingMode = .easeInEaseOut
				self.base.runAction(rotateAction)
			}
		}))
	}
	
	func endRotate() {
		mostRecentRotate = nil
	}
//		if mostRecentRotate == nil { return }
//		if newSwiping && wentSlow { return }
//		let goingPos = (rotationSpeed > 0) == (base.rotation.y > 0)
//		let minRot = base.rotation.w/(.pi/2) + (goingPos ? 0.5 : -0.5)
//		let alreadyPos = minRot > 0
//		let roundingRule: FloatingPointRoundingRule = goingPos == alreadyPos ? .awayFromZero : .towardZero
//		let endW = minRot.rounded(roundingRule)*(.pi/2)
//		let endRotation = SCNVector4(0, rotationStart.y, 0, endW)
//		let duration = max(0.12, abs(Double(endW - base.rotation.w)/Double(rotationSpeed/150 + 0.00001)))
//		if newSwiping || (duration < 0.4 || abs(rotationSpeed) > 500) {
//			let rotateAction = SCNAction.rotate(toAxisAngle: endRotation, duration: duration) //max(0.2, Double(100/abs(rotationSpeed))))
//			rotateAction.timingMode = .easeOut
////			print(duration)
//			base.runAction(rotateAction)
//		}
//		mostRecentRotate = nil
//	}
    
//    func moveCube(move: Int, color: UIColor) -> TimeInterval {
//        let cube = moves[move]
//        cube.setColor(color)
//        base.addChildNode(cube)
//        let pos = spaces[move].simdPosition
//        let time = TimeInterval(distance(pos, cube.simdPosition)/40.0 + 0.2)
//        let translate = SCNAction.move(to: SCNVector3(pos), duration: time)
//        translate.timingMode = .easeIn
//        let fade = SCNAction.fadeOut(duration: time)
//        fade.timingMode = .easeIn
//        cube.runAction(translate)
//        spaces[move].runAction(fade)
//        return time
//    }
    
    func addCube(move: Int, color: UIColor, opacity: CGFloat = 1.0) {
        let cube = moves[move]
        cube.setColor(color)
        spaces[move].addChildNode(cube)
        cube.position = SCNVector3(0,0,0)
        cube.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
        cube.opacity = opacity
    }
    
    func placeCube(move: Int, color: UIColor, opacity: CGFloat = 1.0) {
        let cube = moves[move]
        cube.setColor(color)
        cube.opacity = 0.3
        cube.position = SCNVector3(0,0.4,0)
        cube.rotation = SCNVector4(.random(in: -1...1), 0, .random(in: -1...1), .random(in: 0.20...0.4))
        let translate = SCNAction.move(to: SCNVector3(0,0,0), duration: 0.16)
        let rotate = SCNAction.rotate(toAxisAngle: SCNVector4(x: 0, y: 0, z: 0, w: 0), duration: 0.16)
        let fade = SCNAction.fadeOpacity(to: opacity, duration: 0.15)
        rotate.timingMode = .easeIn
        translate.timingMode = .easeIn
        let placeAction = SCNAction.group([translate, rotate, fade])
        cube.runAction(placeAction)
    }
    
    func undoMove(_ move: Int) {
        spinMoves()
        let cube = moves[move]
        let newRot = SCNVector4(.random(in: -1...1), 0, .random(in: -1...1), .random(in: 0.20...0.4))
        let translate = SCNAction.move(to: SCNVector3(0, 0.4, 0), duration: 0.16)
        let rotate = SCNAction.rotate(toAxisAngle: newRot, duration: 0.16)
        let fade = SCNAction.fadeOut(duration: 0.15)
        rotate.timingMode = .easeIn
        translate.timingMode = .easeIn
        let unPlaceAction = SCNAction.group([translate, rotate, fade])
        cube.runAction(unPlaceAction)
        hideWins(Board.linesThruPoint[move])
    }
    
    func remove(_ move: Int) {
		moves[move].opacity = 0
    }
    
    func spinMoves() {
		var list: Set<Int> = Set(Game.main.premoves)
		if list.isEmpty {
			if let potentialMove = potentialMove {
				list = Set([potentialMove])
			} else if GameLayout.main.showWinsFor != nil {
				list = GameLayout.main.currentHintMoves ?? []
			}
		}
        for (i, space) in spaces.enumerated() {
            if space.actionKeys.contains(Key.spin.rawValue) != list.contains(i) {
                if list.contains(i) {
                    let spin = SCNAction.rotate(by: .pi*2, around: SCNVector3(0,1,0), duration: 1.0)
                    let longSpin = SCNAction.repeatForever(spin)
                    space.removeAllActions()
                    space.runAction(longSpin, forKey: Key.spin.rawValue)
                } else {
                    let dir: Float = space.rotation.y > 0 ? 1 : -1
                    let next = dir*((dir*space.rotation.w/(.pi/2)).rounded(.up))*(.pi/2)
                    let dist = abs(next - space.rotation.w)
                    let spinBack = SCNAction.rotate(toAxisAngle: SCNVector4(0,dir,0,next), duration: Double(dist/(.pi*2)))
                    space.removeAllActions()
                    space.runAction(spinBack)
                }
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}
