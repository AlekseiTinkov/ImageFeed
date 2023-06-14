//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 14.06.2023.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.name = "\(result.firstName) \(result.lastName)"
        self.loginName = "@\(username)"
        self.bio = result.bio
    }
}

final class ProfileService {
    private var task: URLSessionTask?
    private var lastToken: String?
    private let urlSession = URLSession.shared
    static let shared = ProfileService()
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        task?.cancel()
        lastToken = token
        let request = selfProfileRequest(token)
        let task = object(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let responseBody):
                self.profile = Profile(from: responseBody)
                guard let profile = self.profile else {return}
                completion(.success(profile))
                self.profile = profile
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastToken = nil
                
            }
        }
        self.task = task
        task.resume()
    }
    
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result {
                    return try decoder.decode(ProfileResult.self, from: data)
                    
                }
            }
            completion(response)
        }
    }
    
    private func selfProfileRequest(_ token: String) -> URLRequest {
        let url = DefaultBaseURL.appendingPathComponent("/me")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
