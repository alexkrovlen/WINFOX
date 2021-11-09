//
//  LoginController.swift
//  WINFOX
//
//  Created by Svetlana Frolova on 03.11.2021.
//

import UIKit

class LoginController: UIViewController {
    
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    
    private let maxNumberCount = 11
    private let regex = try? NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func backgroundSetting() {
        codeButton.layer.cornerRadius = 6
        numberTF.delegate = self
        numberTF.keyboardType = .numberPad
    }
    @IBAction func getCode(_ sender: UIButton) {
        guard let numberTF = numberTF.text else { return }
        var number = numberTF.filter{ $0 != "-" && $0 != "(" && $0 != ")"}
        number = number.filter{$0 != " "}
        let codeCountry = number.filter{$0 != "+" }.first ?? "0"
        if number.count < 11 || codeCountry != "7" {
            let alert = UIAlertController(title: "Error", message: "Not correct phone number. Change number and try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            AuthManager.shared.startAuth(phoneNumber: number) { [weak self] success in
                guard success else {
                    let alert = UIAlertController(title: "Server error", message: "Try again later.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: .main)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CodeViewController") as! CodeViewController
                    vc.phoneNumber = number
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    private func formatNumber(phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
        guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else { return "+" }
        guard let regex = regex else { return "" }
        let range = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")
        
        if number.count > maxNumberCount {
            let maxIndex = number.index(number.startIndex, offsetBy: maxNumberCount)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        if shouldRemoveLastDigit {
            let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        let maxIndex = number.index(number.startIndex, offsetBy: number.count)
        let regRange = number.startIndex..<maxIndex
        if number.count < 4 {
            let pattern = "(\\d)(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2 ", options: .regularExpression, range: regRange)
        } else if number.count < 5 {
            let pattern = "(\\d)(\\d{3})"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) ", options: .regularExpression, range: regRange)
        } else if number.count < 7 {
            let pattern = "(\\d)(\\d{3})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3", options: .regularExpression, range: regRange)
        } else if number.count < 9 {
            let pattern = "(\\d)(\\d{3})(\\d{3})"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-", options: .regularExpression, range: regRange)
        } else if number.count < 11 {
            let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-", options: .regularExpression, range: regRange)
        } else {
            let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-$5", options: .regularExpression, range: regRange)
        }
        
        return "+" + number
    }
    
}

extension LoginController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullString = (textField.text ?? "") + string
        textField.text = formatNumber(phoneNumber: fullString, shouldRemoveLastDigit: range.length == 1)
        return false
    }
}
