//
//  GEObfuscationSampleTests.swift
//  GEObfuscationSampleTests
//
//  Created by Grigory Entin on 28.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest
@testable import GEObfuscationSample

class GEObfuscationSampleTests: XCTestCase {
	
	/// See https://www.mikeash.com/pyblog/friday-qa-2015-07-31-tagged-pointer-strings.html
	
	let nonTaggedUnobfuscated = ("foo" + "bar" + "baz") + ("foo" + "bar" + "baz")
	let taggedUnobfuscated = "Bar"
	
	// MARK: -
	
	func testCopyWithNonTagged() {
		testCopy(nonTaggedUnobfuscated)
	}
	
	func testCopyWithTagged() {
		testCopy(taggedUnobfuscated)
	}
	
	func testCopyViolationDetectionWithNonTagged() {
		testCopyViolationDetection(nonTaggedUnobfuscated)
	}
	
	func testCopyViolationDetectionWithTagged() {
		testCopyViolationDetection(taggedUnobfuscated)
	}
	
	func testNoCopyWithNonTagged() {
		testCopy(nonTaggedUnobfuscated)
	}
	
	func testNoCopyWithTagged() {
		testCopy("Foo")
	}
	
	// MARK: -
	
	func testCopy(_ s: String) {
		var copy: String?
		let obfuscated = ObfuscatedString(s)
		XCTAssertNoThrow(
			try obfuscated.withUnobfuscated(allowCopy: true) {
				XCTAssertEqual($0, s)
				copy = $0
			}
		)
		XCTAssertEqual(copy, s)
	}
	
	func testCopyViolationDetection(_ s: String) {
		var copy: String?
		let obfuscated = ObfuscatedString(s)
		XCTAssertThrowsError(
			try obfuscated.withUnobfuscated(allowCopy: false) {
				XCTAssertEqual($0, s)
				copy = $0
			}
		) { error in
			switch error {
			case ObfuscatedStringError.copyViolation(let className):
				if s == taggedUnobfuscated {
					XCTAssertEqual(className, "NSTaggedPointerString")
				} else {
					XCTAssertNotEqual(className, "NSTaggedPointerString")
				}
			default:
				XCTFail()
			}
		}
		XCTAssertEqual(copy, s)
	}
	
	func testNoCopy(_ s: String) {
		let obfuscated = ObfuscatedString(s)
		XCTAssertNoThrow(
			try obfuscated.withUnobfuscated(allowCopy: false) {
				_ = $0
			}
		)
	}
}
