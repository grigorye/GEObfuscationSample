//
//  AESCrypt.swift
//  GEObfuscationSample
//
//  Created by Grigory Entin on 02.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

// Borrowed from http://sketchytech.blogspot.nl/2016/02/resurrecting-commoncrypto-in-swift-for.html

let key = "12345678901234567890123456789012"
let iv = "iv-salt-string--" // string of 16 characters in length

extension String {
	
	func aesEncrypt(key: String = key, iv: String = iv, options: Int = kCCOptionPKCS7Padding) -> String? {
		guard let keyData = key.data(using: .utf8) as NSData?, let data = self.data(using: .utf8) as NSData?, let cryptData = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) else {
			return nil
		}
		let keyLength = size_t(kCCKeySizeAES128)
		let operation: CCOperation = UInt32(kCCEncrypt)
		let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
		let options: CCOptions = UInt32(options)
		var numBytesEncrypted: size_t = 0
		let cryptStatus = CCCrypt(
			operation,
			algoritm,
			options,
			keyData.bytes,
			keyLength,
			iv,
			data.bytes,
			data.length,
			cryptData.mutableBytes,
			cryptData.length,
			&numBytesEncrypted
		)
		guard UInt32(cryptStatus) == UInt32(kCCSuccess) else {
			return nil
		}
		cryptData.length = Int(numBytesEncrypted)
		let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
		return base64cryptString
	}
	
	func aesDecrypt(key: String = key, iv: String = iv, options: Int = kCCOptionPKCS7Padding) -> String? {
		guard let keyData = key.data(using: .utf8) as NSData?, let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters), let cryptData = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) else {
			return nil
		}
		let keyLength = size_t(kCCKeySizeAES128)
		let operation: CCOperation = UInt32(kCCDecrypt)
		let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
		let options: CCOptions = UInt32(options)
		
		var numBytesEncrypted: size_t = 0
		let cryptStatus = CCCrypt(
			operation,
			algoritm,
			options,
			keyData.bytes,
			keyLength,
			iv,
			data.bytes,
			data.length,
			cryptData.mutableBytes,
			cryptData.length,
			&numBytesEncrypted
		)
		
		guard UInt32(cryptStatus) == UInt32(kCCSuccess) else {
			return nil
		}
		cryptData.length = Int(numBytesEncrypted)
		let unencryptedMessage = String(data: cryptData as Data, encoding: .utf8)
		return unencryptedMessage
	}
}
