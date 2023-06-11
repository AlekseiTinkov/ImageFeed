//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 07.06.2023.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "token") ?? nil
        }
        set {
            return UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
}
