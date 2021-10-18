//
//  UIHelper.swift
//  qubic
//
//  Created by 4 on 8/17/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct Fill: View {
    let height: CGFloat?
	let color: Color
    
	init(_ height: CGFloat? = nil, color: Color = .systemBackground) {
        self.height = height
		self.color = color
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(color)
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
var backButtonSpace: CGFloat = 50 // space for menus = menuSpace - bottombuttonspace
let backButtonHeight: CGFloat = 50 // actual height of the bottom buttons
let backButtonFrame: CGFloat = 150 // height of the entire bottom button view, just needs to be big enough but doesn't matter otherwise

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
	// TODO what is this?
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

struct BoundSize: ViewModifier {
	/*
	 sizes:
	 
	 extraSmall
	 small
	 medium
	 large
	 extraLarge
	 extraExtraLarge
	 extraExtraExtraLarge
	 accessibilityMedium
	 accessibilityLarge
	 accessibilityExtraLarge
	 accessibilityExtraExtraLarge
	 accessibilityExtraExtraExtraLarge
	 */
	
	@Environment(\.sizeCategory) var currentSize
	let min: ContentSizeCategory
	let max: ContentSizeCategory
	var size: ContentSizeCategory {
		if #available(iOS 14.0, *) {
			if currentSize < min {
				return min
			} else if currentSize > max {
				return max
			}
			return currentSize
		} else {
			return .large // standard
		}
	}
	
	func body(content: Content) -> some View {
		content
			.environment(\.sizeCategory, size)
	}
}

struct PopupModifier: ViewModifier {
	func body(content: Content) -> some View {
		content.background(
			Fill()
				.frame(width: Layout.main.width + 100)
				.shadow(radius: 20) // Z index didn't stop the shadows from covering
		)
	}
}

//extension View {
//    func navigate<SomeView: View>(to view: SomeView, when binding: Binding<Bool>) -> some View {
//        modifier(NavigateModifier(destination: view, binding: binding))
//    }
//}

