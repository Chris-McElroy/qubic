//
//  MainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import SceneKit

struct MainView: View {
    @State var expanded: Bool = false
    
    let mainCube = CubeScene()
    
    var body: some View {
        ZStack {
            // background rectangle for swiping to work
            Rectangle()
                // has to be colored to work
                .foregroundColor(Color(UIColor.systemBackground))
            VStack {
                VStack {
                    Text("qubic")
                        .font(.custom("Oligopoly Regular", size: 24))
                        .padding(.top, 10)
                    mainCube
                        .padding(.horizontal, 80)
                        .padding(.vertical, 10)
                    Spacer()
                    TrainView() {print("train")}
                    SolveView() {print("solve")}
                    PlayView() {print("play")}
                }
                    .offset(y: expanded ? -400 : 0)
                Spacer()
                    .offset(y: expanded ? 0 : 400)
                moreButton
            }
        }
            .gesture(DragGesture()
                .onEnded { drag in
                    let h = drag.predictedEndTranslation.height
                    let w = drag.predictedEndTranslation.width
                    if abs(h)/abs(w) > 1 {
                        if expanded == (h > 0) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                self.expanded.toggle()
                            }
                        }
                    } else {
                        self.mainCube.spinCube(dir: w > 0 ? 1 : -1)
                    }
                })
    }
    
    var moreButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.expanded.toggle()
            }
        }) {
            VStack {
                Text(expanded ? "back" : "more")
                    .font(.custom("Oligopoly Regular", size: 16))
                    .animation(nil)
                Text("↓")
                    .rotationEffect(Angle(degrees: expanded ? 180 : 0))
            }
        }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 5)
            .padding(.bottom,10)
    }
}

struct CubeScene : UIViewRepresentable {
    let scene = SCNScene()
    let help = SceneHelper()

    func makeUIView(context: Context) -> SCNView {
        scene.rootNode.addChildNode(help.makeCamera(pos: SCNVector3(3,3.1,3), rot: SCNVector3(-36,45,0)))
        scene.rootNode.addChildNode(help.makeOmniLight())
        scene.rootNode.addChildNode(help.makeAmbiLight())
        scene.rootNode.addChildNode(help.makeBox(name: "cube", pos: SCNVector3(0,0,0), color: UIColor(red: 0.15, green: 0.5, blue: 1.0, alpha: 1.0)))
        return help.prepSCNView(scene: scene)
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
    }
    
    public func spinCube(dir: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.6
        let boxNode = scene.rootNode.childNode(withName: "cube", recursively: false)
        boxNode?.eulerAngles.y += GLKMathDegreesToRadians(90*dir)
        SCNTransaction.commit()
    }
}

struct primaryButton: View {
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.custom("Oligopoly Regular", size: 24))
                .foregroundColor(.white)
                .frame(minWidth: 100, idealWidth: 200, maxWidth: 200, minHeight: 40, idealHeight: 50, maxHeight: 60, alignment: .center)
                .background(LinearGradient(gradient: Gradient(colors: [.init(red: 0.1, green: 0.3, blue: 1), .blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(100)
                .shadow(radius: 4, x: 0, y: 5)
                .padding()
            
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
//        MainView()
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .preferredColorScheme(.dark)
    }
}
