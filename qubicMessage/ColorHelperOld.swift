//
//  ColorHelperOld.swift
//  qubic
//
//  Created by Chris McElroy on 5/19/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI

extension UIColor {
    public static var null: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.95)
    
    static func of(n: Int) -> UIColor {
        let nums = Color.playerColors[n]
        return UIColor(hue: CGFloat(nums.h), saturation: CGFloat(nums.s), brightness: CGFloat(nums.b), alpha: 1)
    }
	
	static func presetOf(n: Int) -> UIColor {
		of(n: n)
	}
    
    static func primary() -> UIColor {
        let nums = Color.playerColors[4]
        return UIColor(hue: CGFloat(nums.h), saturation: CGFloat(nums.s), brightness: CGFloat(nums.b), alpha: 1)
    }
    
    static func secondary() -> UIColor {
        let nums = Color.playerColors[4]
        return UIColor(hue: CGFloat(nums.h), saturation: CGFloat(nums.s), brightness: CGFloat(nums.b)*0.75, alpha: 1)
    }
    
    static func tertiary() -> UIColor {
        let nums = Color.playerColors[4]
        return UIColor(hue: CGFloat(nums.h), saturation: CGFloat(nums.s), brightness: CGFloat(nums.b)*0.5, alpha: 1)
    }
}

extension Color {
    public static var systemBackground: Color = Color(UIColor.systemBackground)
    public static var label: Color = Color(UIColor.label)
    
    static let playerColors: [(h: Double, s: Double, b: Double)] = [
        (h: 0.075,  s: 1,       b: 1),      // orange
        (h: 0,      s: 1,       b: 1),      // red
        (h: 0.842,  s: 1,       b: 1),      // pink
        (h: 0.749,  s: 1,       b: 1),      // purple
        (h: 0.59,   s: 1,       b: 1),      // blue
        (h: 0.56,   s: 0.71,    b: 1),      // cyan
        (h: 0.33,   s: 1,       b: 1),      // lime
        (h: 0.376,  s: 1,       b: 0.552),  // green
        (h: 0.136,  s: 1,       b: 1),      // gold
    ]
    
    static func of(n: Int) -> Color {
        let nums = playerColors[n]
        return Color(hue: nums.h, saturation: nums.s, brightness: nums.b)
    }
    
    static func primary() -> Color {
        let nums = playerColors[4]
        return Color(hue: nums.h, saturation: nums.s, brightness: nums.b)
    }

    static func secondary() -> Color {
        let nums = playerColors[4]
        return Color(hue: nums.h, saturation: nums.s, brightness: nums.b*0.75)
    }

    static func tertiary() -> Color {
        let nums = playerColors[4]
        return Color(hue: nums.h, saturation: nums.s, brightness: nums.b*0.5)
    }
}


