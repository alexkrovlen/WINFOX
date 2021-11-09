//
//  CodeViewController.swift
//  WINFOX
//
//  Created by  Svetlana Frolova on 04.11.2021.
//

import UIKit

class CodeViewController: UIViewController {

    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    
    var timer: Timer = Timer()
    var count: Int = 120
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        
    }
    
    private func backgroundSetting() {
        sendButton.layer.cornerRadius = 6
        timerButton.layer.cornerRadius = 6
        timerButton.isEnabled = false
        timerButton.backgroundColor = .systemGray5
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
    }
    
    @objc func timerCounter() {
        if count <= 0 {
            timerButton.isEnabled = true
            timerButton.backgroundColor = UIColor(red: 91 / 255, green: 214 / 255, blue: 226 / 255, alpha: 1)
            timer.invalidate()
            count = 1
        }
        count = count - 1
        let time = secondsToMinutesSeconds(seconds: count)
        let timeString = makeTimeString(minutes: time.0, seconds: time.1)
        timerLabel.text = "Повторный код можно запросить через \(timeString)"
    }
    
    private func secondsToMinutesSeconds(seconds: Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
    
    func makeTimeString(minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    @IBAction func tapGetCode(_ sender: Any) {
        timerButton.isEnabled = false
        timerButton.backgroundColor = .systemGray5
        count = 121
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        guard let number = phoneNumber else { return }
        AuthManager.shared.startAuth(phoneNumber: number) { success in
            guard success else { return }
        }
    }
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        if let code = codeTF.text, !code.isEmpty {
            AuthManager.shared.verifyCode(smsCode: code) { [weak self] success, uid in
                guard success else { return }
                DispatchQueue.main.async {
                    guard let number = self?.phoneNumber else { return }
                    RequestManager.shared.checkUser(phoneNumber: number, uid: uid) { [weak self] success in
                        DispatchQueue.main.async {
                            if success {
                                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                                let vc = storyboard.instantiateViewController(withIdentifier: "account") as! UITabBarController
                                self?.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let alert = UIAlertController(title: "Error", message: "Something went wrong. Try again later.", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
