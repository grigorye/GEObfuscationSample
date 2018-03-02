//
//  GEObfuscationSampleUITests.swift
//  GEObfuscationSampleUITests
//
//  Created by Grigory Entin on 01.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest

/// The tests rely on the external tool that scans the memory for a given string. See `matches` in MemoryScanning.swift.
/// It's *assumed* that the tool indeed gives the correct answer/is "the source of truth".
/// The tests confirm the correctness of obfuscation by verifying that
/// 1) The secret (and obfuscated version) is indeed in memory when expected (while the secret is manipulated in UI).
/// 2) The secret (and obfuscated version) is not in memory when expected (when the secret is not manipulated in UI/obfuscated version is purged).
/// - Tag: Obfuscated-Value-Wrapper
class GEObfuscationSampleUITests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// For now, we expect some failures for short secrets. But we want to run all checks anyway (as failed checks shouldn't affect the other things. See ** SHORT-SECRETS ** below.
		continueAfterFailure = true
		XCUIApplication().launch()
	}
	
	let app = XCUIApplication()
	
	let processName = "GEObfuscationSample"
	
	// MARK: -
	
	func testLongLongSecret() {
		test(secret: "FooBarBazFooBarBaz")
	}
	
	func testLongSecret() {
		test(secret: "FooBarBaz")
	}
	
	func testShortSecret() {
		test(secret: "Baz")
	}
	
	// MARK: -
	
	func test(secret: String) {
		/// Shortcut used in XCTAsserts below for locating secret (or its obfuscated version) in memory.
		func secretMatches(obfuscated: Bool = false) -> [String] {
			let stringToMatch = obfuscated ? obfuscate(secret) : secret
			guard let secretMatches = try? matches(for: stringToMatch, inProcessWithName: processName) else {
				return ["MATCH-INTERNAL-FAILURE"]
			}
			return secretMatches
		}
		
		// Sanity checking. Make sure we didn't accidentally place the same string (or its obfuscated version) in memory for some reason.
		XCTAssertEqual([], secretMatches())
		XCTAssertEqual([], secretMatches(obfuscated: true))
		
		let secretAlert = app.alerts["Secret"]
		
		// We should have it in memory after typing.
		do {
			XCUIApplication().buttons["Edit Secret"].tap()
			secretAlert.staticTexts["Secret"].tap()
			let secretSecureTextField = secretAlert.collectionViews.secureTextFields["Secret"]
			secretSecureTextField.typeText(secret)
			XCTAssertNotEqual([], secretMatches())
			XCTAssertEqual([], secretMatches(obfuscated: true))
		}
		
		// We should not have secret *but* obfuscated version in memory after dismissing the alert.
		do {
			secretAlert.buttons["OK"].tap()
			XCTAssertEqual([], secretMatches())
			// ** SHORT-SECRETS **
			// This fails for short secrets. Probably due to NSTaggedPointerStrings or something. Couldn't figure it out yet.
			// Probably it's not that important as it *doesn't* fail for long secrets. Hence there's a chance that short secrets handled the same way as the long ones, with exclusion of the backing storage. And if obfuscation works for long secrets, it should work for short ones as well.
			// Anyway it might make sense to investigate it further/force short secrets stored exactly the same way as the long ones.
			// Btw, it's false positive, so it really doesn't mean that implementation indeed has a problem. It just indicates that we lack information about the real-time behaviour. We need it *here* just as a way to prove that obfuscated version indeed disappeared from memory after we purge it (see the next step ("Purge Secret").
			XCTAssertNotEqual([], secretMatches(obfuscated: true))
		}
		
		// After purging the obfuscated version we shouldn't have it in memory either.
		do {
			app.buttons["Purge Secret"].tap()
			XCTAssertEqual([], secretMatches())
			XCTAssertEqual([], secretMatches(obfuscated: true))
		}
	}
}
