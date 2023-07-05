//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 16.06.2023.
//

import Foundation

private struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
    let large: String
}

final class ProfileImageService {
    private var task: URLSessionTask?
    private var lastUsername: String?
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUsername == username { return }
        task?.cancel()
        lastUsername = username
        let request = makeProfileImageRequest(token: token, username: username)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let responseBody):
                let profileImageURL = responseBody.profileImage.large
                completion(.success(profileImageURL))
                self.avatarURL = profileImageURL
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
                
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastUsername = nil
                
            }
        }
        self.task = task
        task.resume()
    }
}
    
extension ProfileImageService {
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest {
        let url = DefaultBaseURL.appendingPathComponent("/users/\(username)")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
