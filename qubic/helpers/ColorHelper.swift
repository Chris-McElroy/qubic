//
//  ColorHelper.swift
//  qubic
//
//  Created by 4 on 7/27/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

extension UIColor {
    public static var null: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.95)
    
    static func primary(_ n: Int) -> UIColor {
        switch (n) {
        case 0: return UIColor(red: 0.15, green: 0.51, blue: 1.0, alpha: 1.0)
        case 1: return .magenta
        case 2: return .green
        case 3: return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case 4: return .cyan
        case 5: return .orange
        case 6: return .red
        case 33: return UIColor.null.withAlphaComponent(0.5)
        default: return .white
        }
    }
    
    static func secondary(_ n: Int) -> UIColor {
        switch (n) {
        case 0: return UIColor(red: 0.094, green: 0.36, blue: 0.74, alpha: 1.0)
        case 1: return .magenta
        case 2: return .green
        case 3: return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case 4: return .cyan
        case 5: return .orange
        case 6: return .red
        case 33: return UIColor.null.withAlphaComponent(0.5)
        default: return .white
        }
    }
    
    static func tertiary(_ n: Int) -> UIColor {
        switch (n) {
        case 0: return UIColor(red: 0.051, green: 0.24, blue: 0.51, alpha: 1.0)
        case 1: return .magenta
        case 2: return .green
        case 3: return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case 4: return .cyan
        case 5: return .orange
        case 6: return .red
        case 33: return UIColor.null.withAlphaComponent(0.5)
        default: return .white
        }
    }
}

extension Color {
    public static var systemBackground: Color = Color(UIColor.systemBackground)
    
    static func primary(_ n: Int) -> Color {
        return Color(UIColor.primary(n))
    }

    static func secondary(_ n: Int) -> Color {
        return Color(UIColor.secondary(n))
    }

    static func tertiary(_ n: Int) -> Color {
        return Color(UIColor.tertiary(n))
    }
}
