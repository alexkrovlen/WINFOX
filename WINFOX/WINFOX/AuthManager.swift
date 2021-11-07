//
//  AuthManager.swift
//  WINFOX
//
//  Created by  Admin on 04.11.2021.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private var verificationId: String?
    
    public func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            self?.verificationId = verificationId
            completion(true)
        }
    }
    
    public func verifyCode(smsCode: String, completion: @escaping (Bool, String) -> Void) {
        guard let verificationId = verificationId else {
            completion(false, "")
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)

        auth.signIn(with: credential) { result, error in
            guard result != nil, error == nil else {
                completion(false, "")
                return
            }
            print("id")
            print(self.auth.currentUser?.uid)
            guard let uid = self.auth.currentUser?.uid else {
                completion(true, "")
                return
            }
            completion(true, uid)
        }
    }
    
    public func logout() {
        try? auth.signOut()
    }
}
