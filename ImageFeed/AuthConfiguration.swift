//
//  Constants.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 03.06.2023.
//

import Foundation

let AccessKey = "-LMxqxJkobLT2u5QQ7RgPcg-Q_32HpL4w3dR0wO0wVw"
let SecretKey = "KZEEburx3QE61jIkEEwHL4it2T4lgWnzH5gbTOv1PD0"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"

let AccessScope = "public+read_user+write_likes"

let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
private let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 authURLString: UnsplashAuthorizeURLString,
                                 defaultBaseURL: DefaultBaseURL)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
