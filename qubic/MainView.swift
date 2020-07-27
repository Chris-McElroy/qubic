//
//  MainView.swift
//  qubic
//
//  Created by 4 on 7/25/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State var expanded: Bool = false
    
    let cube = CubeView()
    
    var body: some View {
        addBackground(height: nil, insert:
            AnyView(
                VStack {
                    upperStack
                        .offset(y: expanded ? -400 : 250)
                    lowerStack
                        .offset(y: expanded ? -335 : 400)
                    Spacer(minLength: 100)
                        .offset(y: expanded ? 0 : 400)
                    moreButton
                    Spacer(minLength: 270)
                        .offset(y: expanded ? 0 : 400)
                }
                    .frame(height: 1200)
            )
        )
            .gesture(scrollGestures)
    }
    
    var upperStack: some View {
        VStack {
            Spacer()
                .frame(height: 20)
            Text("qubic")
                .font(.custom("Oligopoly Regular", size: 24))
                .padding(.top, 10)
            cube
                .onTapGesture(count: 2) {
                    self.cube.resetCube()
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 10)
            Spacer()
                .frame(height: 29)
            TrainView() {print("train")}
            SolveView() {print("solve")}
            PlayView() {print("play")}
        }
    }
    
    var lowerStack: some View {
        VStack {
            AboutView() {}
            AboutView() {}
            AboutView() {}
        }
    }
    
    var moreButton: some View {
        addBackground(height: 50, insert:
            AnyView(
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
            )
        )
    }
    
    var scrollGestures: some Gesture {
        DragGesture()
            .onEnded { drag in
                let h = drag.predictedEndTranslation.height
                let w = drag.predictedEndTranslation.width
                if abs(h)/abs(w) > 1 {
                    if self.expanded == (h > 0) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            self.expanded.toggle()
                        }
                    } else if h > 0 {
                        self.cube.flipCube()
                    }
                } else {
                    self.cube.spinCube(dir: w > 0 ? 1 : -1)
                }
            }
    }
}

struct addBackground : View {
    let height: CGFloat?
    let insert: AnyView
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(UIColor.systemBackground))
                .frame(height: height)
            insert
        }
    }
}

struct primaryLabel: View {
    let name: String
    
    var body: some View {
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

struct secondaryLabel: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.custom("Oligopoly Regular", size: 20))
            .foregroundColor(.primary)
            .padding(8)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
//        MainView()
//            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
//            .preferredColorScheme(.dark)
    }
}
