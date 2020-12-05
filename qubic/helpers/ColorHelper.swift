//
//  ColorHelper.swift
//  qubic
//
//  Created by 4 on 7/27/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

extension Color {
    public static var systemBackground: Color = Color(UIColor.systemBackground)
    
}

extension UIColor {
    public static var null: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.95)
}

func getUIColor(_ n: Int) -> UIColor {
    switch (n) {
    case 0: return UIColor(red: 0.15, green: 0.5, blue: 1.0, alpha: 1.0)
    case 1: return .magenta
    case 2: return .green
    case 33: return UIColor.null.withAlphaComponent(0.5)
    default: return .white
    }
}

func getColor(_ n: Int) -> Color {
    return Color(UIColor(red: 0.15, green: 0.5, blue: 1.0, alpha: 1.0))
}
