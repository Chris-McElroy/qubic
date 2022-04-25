//
//  GeneralHelper.swift
//  qubic
//
//  Created by Chris McElroy on 10/17/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
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

enum VersionType: String {
	case xCode = "xCode"
	case testFlight = "testFlight"
	case appStore = "appStore"
}

enum Opacity: Double {
	case clear = 0
	case half = 0.3
	case full = 1
}

extension Sequence where Element: AdditiveArithmetic {
	func sum() -> Element { reduce(.zero, +) }
}


func bound<N: Numeric>(_ l: N, _ m: N, _ u: N) -> N where N: Comparable {
	min(u, max(l, m))
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
