//
//  UIHelper.swift
//  qubic
//
//  Created by 4 on 8/17/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

// Keys
let DCStreakKey = "DCStreak"
let LastDCKey = "LastDC"
let badgeKey = "qubic badge notification"

extension Dictionary {
    func add(_ newElement: Element) -> Dictionary {
        merging([newElement], uniquingKeysWith: { (old, _) in old } )
    }
}

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}

extension Date {
    func isYesterday() -> Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func getInt() -> Int {
        let midnight = Calendar.current.startOfDay(for: self)
        return Calendar.current.ordinality(of: .day, in: .era, for: midnight) ?? 0
    }
}

struct Fill: View {
    let height: CGFloat?
    
    init(_ height: CGFloat? = nil) {
        self.height = height
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(.systemBackground)
            .frame(height: height)
    }
}

let mainButtonHeight: CGFloat = 92
let moreButtonHeight: CGFloat = 50
let nameButtonWidth: CGFloat = 180

struct MainStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Oligopoly Regular", size: 26))
            .foregroundColor(.white)
            .frame(width: 200, height: mainButtonHeight-22)
            .background(LinearGradient(gradient: Gradient(colors: [.init(red: 0.1, green: 0.3, blue: 1), .blue]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(100)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .shadow(radius: 4, x: 0, y: 3)
            .frame(width: 200, height: mainButtonHeight)
            .background(Fill())
            .cornerRadius(30)
            .zIndex(1)
    }
}

struct MoreStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Oligopoly Regular", size: 20))
            .foregroundColor(.primary)
            .padding(8)
            .opacity(configuration.isPressed ? 0.25 : 1.0)
    }
}

struct Solid: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(1.0)
    }
}

struct NameStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(1.0)
            .foregroundColor(.white)
            .frame(width: nameButtonWidth, height: 40)
            .background(Rectangle().foregroundColor(color))
            .cornerRadius(100)
    }
}

struct Name: View {
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(text, action: action).buttonStyle(NameStyle(color: color))
    }
}

//extension View {
//    func navigate<SomeView: View>(to view: SomeView, when binding: Binding<Bool>) -> some View {
//        modifier(NavigateModifier(destination: view, binding: binding))
//    }
//}
