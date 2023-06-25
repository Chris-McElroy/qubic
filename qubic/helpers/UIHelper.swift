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

func timeLabel(for time: Double?) -> String {
	guard let time else { return "untimed" }
	if time == -1 { return "untimed" }
	return time < 60 ? "\(Int(time)) sec" : "\(Int(time)/60) min"
}

// laterDO integrate with hpicker itself
struct EnableHPicker: ViewModifier {
	let on: Bool
	let height: CGFloat = 42
	
	func body(content: Content) -> some View {
		ZStack {
			content
			Fill(height)
				.opacity(on ? 0.0 : 0.6)
				.animation(.linear(duration: 0.15))
		}
	}
}

struct GameViewLayout: ViewModifier {
	@ObservedObject var layout = Layout.main // observing to fix Tutorial sizing on alternate size devices
	
	func body(content: Content) -> some View {
		content
			.frame(height: layout.safeHeight)
			.background(Fill()) // at some point the top bar was gray on iPhone SE 3 during the tutorial, i thought it was the color of this that was off but now it doesn't seem to be, and it's mysteriously fixed itself as well
			.frame(height: layout.fullHeight)
			.zIndex(100)
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
			.modifier(Oligopoly(size: 26))
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
	func makeBody(configuration: Self.Configuration) -> some View {
		ZStack {
			Fill(moreButtonHeight)
			configuration.label
				.modifier(Oligopoly(size: 20))
				.foregroundColor(Color.primary)
				.padding(8)
				.opacity(configuration.isPressed ? 0.25 : 1.0)
		}
    }
}

struct Solid: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(1.0)
    }
}

struct Standard: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.modifier(Oligopoly(size: 16))
			.opacity(1.0)
	}
}

struct Name: View {
    let name: String
    let color: Color
	let rounded: Bool
	let opaque: Bool
    let action: () -> Void
	
	init(for player: Player, opaque: Bool = true, action: @escaping () -> Void = {}) {
		name = player.name
		color = .of(n: player.color)
		rounded = player.rounded
		self.opaque = opaque
		self.action = action
	}
	
	init(name: String, color: Color, rounded: Bool, opaque: Bool = true, action: @escaping () -> Void = {}) {
		self.name = name
		self.color = color
		self.rounded = rounded
		self.opaque = opaque
		self.action = action
	}
    
    var body: some View {
        Button(name, action: action)
			.lineLimit(1)
			.padding(.horizontal, 5)
			.foregroundColor(.white)
			.frame(minWidth: 140, maxWidth: 160, minHeight: 40)
			.background(Fill(color: color).opacity(opaque ? 1 : 0.55))
			.cornerRadius(rounded ? 100 : 4)
			.buttonStyle(Solid())
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

struct Oligopoly: ViewModifier {
	let size: CGFloat
	
	func body(content: Content) -> some View {
		content.font(.custom("Oligopoly Regular", size: size))
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

