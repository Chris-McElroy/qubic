//
//  UIHelper.swift
//  qubic
//
//  Created by 4 on 8/17/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

//00000000-0000-0000-0000-000000000000
var myID: String = Storage.string(.uuid) ?? "00000000000000000000000000000000"
var messagesID: String {
    if let id = Storage.string(.messagesID) {
        return id
    } else {
        let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
        Storage.set(id, for: .messagesID)
        return id
    }
}

enum Opacity: Double {
    case clear = 0
    case half = 0.3
    case full = 1
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
    
    static var int: Int {
        let midnight = Calendar.current.startOfDay(for: Date())
        return Calendar.current.ordinality(of: .day, in: .era, for: midnight) ?? 0
    }
    
    static var now: TimeInterval {
        timeIntervalSinceReferenceDate
    }
    
    static var ms: Int {
        Int(now*1000)
    }
}

extension Timer {
    @discardableResult static func after(_ delay: TimeInterval, run: @escaping () -> Void) -> Timer {
        scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in run() })
    }
    
    @discardableResult static func every(_ delay: TimeInterval, run: @escaping () -> Void) -> Timer {
        scheduledTimer(withTimeInterval: delay, repeats: true, block: { _ in run() })
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

struct Blank: View {
    let height: CGFloat?
    
    init(_ height: CGFloat? = nil) {
        self.height = height
    }
    
    var body: some View {
        Spacer().frame(height: height)
    }
}

let mainButtonHeight: CGFloat = 92
let moreButtonHeight: CGFloat = 50
let nameButtonWidth: CGFloat = 180
var bottomButtonSpace: CGFloat = 50
let bottomButtonHeight: CGFloat = 50
let bottomButtonFrame: CGFloat = 100

struct MainStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Oligopoly Regular", size: 26))
            .foregroundColor(.white)
            .frame(width: 200, height: mainButtonHeight-22)
            .background(Rectangle().foregroundColor(color).cornerRadius(100))
//            .background(LinearGradient(gradient: Gradient(colors: [.init(red: 0.1, green: 0.3, blue: 1), .blue]), startPoint: .leading, endPoint: .trailing))
//            .cornerRadius(100)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .shadow(radius: 4, x: 0, y: 3)
            .frame(width: 200, height: mainButtonHeight)
            .background(Fill())
//            .zIndex(10)
    }
}

struct MoreStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Oligopoly Regular", size: 20))
            .foregroundColor(.primary)
            .padding(8)
            .frame(height: moreButtonHeight)
            .background(Fill())
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

func UIName(text: String, color: Color, action: Selector?) -> UIView {
    let button = UIButton(type: .custom)
    button.setTitle(text, for: .normal)
    button.setTitleColor(.black, for: .normal)
//    button.frame = CGRect(x: 0, y: 0, width: nameButtonWidth, height: 40)
//    button.backgroundColor = .red
    if action != nil { button.addTarget(.none, action: action!, for: .touchDown) }
    return button
}

extension UIButton {
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        //NSAttributedStringKey.foregroundColor : UIColor.blue
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

extension UILabel {
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}

//extension View {
//    func navigate<SomeView: View>(to view: SomeView, when binding: Binding<Bool>) -> some View {
//        modifier(NavigateModifier(destination: view, binding: binding))
//    }
//}

