//
//  ObfuscatedString.swift
//  GEObfuscationSample
//
//  Created by Grigory Entin on 28.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

public enum ObfuscatedStringError: Error {
	case copyViolation(className: String)
}

public struct ObfuscatedString {
	
	private var obfuscatedImp: NSString // NSString for now, just to keep storage the same as for unobfuscated version.
	private var obfuscated: String {
		return obfuscatedImp as String
	}
	
	/// The only way to access the unobfuscated value.
	/// - parameter allowCopy: Disables validation for no copy of unobfuscated value.
	/// - parameter handler: Block for processing the unobfuscated value.
	/// - parameter unobfuscated: The unobfuscated value.
	/// - Tag: withUnobfuscated
	func withUnobfuscated(allowCopy: Bool, _ handler: (_ unobfuscated: String) -> Void) throws {
		weak var x: NSString?
		autoreleasepool {
			let unobfuscatedNSString = NSString(string: unobfuscate(self.obfuscated))
			x = unobfuscatedNSString
			let unobfuscated = unobfuscatedNSString as String
			handler(unobfuscated)
		}
		if !allowCopy, x != nil {
			let className = NSString(utf8String: object_getClassName(x))! as String
			throw ObfuscatedStringError.copyViolation(className: className)
		}
	}
	
	init(_ unobfuscated: String = "") {
		self.obfuscatedImp = obfuscate(unobfuscated) as NSString
		// print(NSString(utf8String: object_getClassName(self.obfuscatedImp))! as String)
	}
}
