//
//  Obfuscation.swift
//  GEObfuscationSample
//
//  Created by Grigory Entin on 01.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

#if false
	/// Obfuscation sample.
	public func obfuscate(_ unobfuscated: String) -> String {
		return String(unobfuscated.reversed())
	}
	
	/// Obfuscation sample.
	public func unobfuscate(_ obfuscated: String) -> String {
		return String(obfuscated.reversed())
	}
#else
	/// Obfuscation sample.
	public func obfuscate(_ unobfuscated: String) -> String {
		return unobfuscated.aesEncrypt()!
	}
	
	/// Obfuscation sample.
	public func unobfuscate(_ obfuscated: String) -> String {
		return obfuscated.aesDecrypt()!
	}
#endif
