//
//  StorageHelper.swift
//  qubic
//
//  Created by Chris McElroy on 7/5/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation

class Storage {
    static func array(_ key: Key) -> [Any]? {
        UserDefaults.standard.array(forKey: key.rawValue)
    }
	
	static func dictionary(_ key: Key) -> [String: Any]? {
		UserDefaults.standard.dictionary(forKey: key.rawValue)
	}
    
    static func int(_ key: Key) -> Int {
        UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    static func string(_ key: Key) -> String? {
        UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func set(_ value: Any?, for key: Key) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
}
