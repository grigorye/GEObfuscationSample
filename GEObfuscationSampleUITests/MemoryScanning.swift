//
//  MemoryScanning.swift
//  GEObfuscationSampleUITests
//
//  Created by Grigory Entin on 01.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

/// Returns an array corresponding to the matches of the given string in the memory of  the given process.
func matches(for string: String, inProcessWithName processName: String) throws -> [String] {
	//
	// We expect that https://github.com/msoap/shell2http is launched on the same host as the given process, like below:
	//
	//     shell2http -port=8193 -form /grep-stringdups-1 'stringdups -minimumCount=1 "${v_process_or_pid:?}"|grep "${v_grep_arg:?}" || true'
	//
	// Hence it's possible to use it for iOS Simulator, but not for iOS devices (unless there's a way to attach
	//
	let url = URL(string: "http://localhost:8193/grep-stringdups-1?process_or_pid=\(processName)&grep_arg=\(string.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!
	
	let session = URLSession.shared
	
	let group = DispatchGroup()
	group.enter()
	var requestOutput = ""
	var requestError: Error?
	let task = session.dataTask(with: url) { data, response, error in
		defer { group.leave() }
		if let error = error {
			requestError = error
			return
		}
		guard let data = data else {
			assert(false)
			return
		}
		requestOutput = String(data: data, encoding: .utf8)!
	}
	task.resume()
	
	group.wait()
	
	if let requestError = requestError {
		throw requestError
	}
	guard requestOutput != "" else {
		return []
	}
	let matches = requestOutput.components(separatedBy: "\n")
	return matches
}
