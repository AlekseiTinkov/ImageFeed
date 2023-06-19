//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 07.06.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "Auth token"
    static let shared = OAuth2TokenStorage()
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
