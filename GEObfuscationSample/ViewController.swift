//
//  ViewController.swift
//  GEObfuscationSample
//
//  Created by Grigory Entin on 28.02.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var obfuscatedSecret: ObfuscatedString?
	
	@IBOutlet var allowCopySwitch: UISwitch!
	
	@IBAction func editSecret(_ sender: Any) {
		editSecret(allowCopy: allowCopySwitch.isOn)
	}
	
	@IBAction func purgeSecret(_ sender: Any) {
		obfuscatedSecret = nil
	}
	
	func editSecret(allowCopy: Bool) {
		let alertController = UIAlertController(title: "Secret", message: nil, preferredStyle: .alert)
		alertController.addTextField { [weak self] textField in
			textField.isSecureTextEntry = true
			textField.placeholder = "Secret"
			do {
				try self?.obfuscatedSecret?.withUnobfuscated(allowCopy: allowCopy) { text in
					textField.text = text
				}
			} catch {
				textField.text = nil
				textField.placeholder = "Secret (Copy Violation)"
			}
		}
		let secretTextField = alertController.textFields!.last!
		alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			self?.obfuscatedSecret = {
				guard let unobfuscatedSecret = secretTextField.text else {
					assert(false)
					return nil
				}
				secretTextField.text = nil
				return ObfuscatedString(unobfuscatedSecret)
			}()
		})
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alertController, animated: true)
	}
}
