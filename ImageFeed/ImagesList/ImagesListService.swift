//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 25.06.2023.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let welcomeDescription: String?
    let isLiked: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls
    }
    
    struct UrlsResult: Decodable {
        let thumbImageURL: String
        let largeImageURL: String
        
        enum CodingKeys: String, CodingKey {
            case thumbImageURL = "thumb"
            case largeImageURL = "full"
        }
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

private extension PhotoResult {
    func convertToViewModel() -> Photo {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return Photo(id: self.id,
              size: .init(width: self.width, height: self.height),
              createdAt: formatter.date(from: self.createdAt) ?? Date(),
              welcomeDescription: self.welcomeDescription,
              thumbImageURL: self.urls.thumbImageURL,
              largeImageURL: self.urls.largeImageURL,
              isLiked: self.isLiked
        )
    }
}

final class ImagesListService {
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    static let shared = ImagesListService()
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = makeImagesListRequest(page: nextPage)
        let task = object(for: request) { (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let responseBody):
                let photos = responseBody.map {
                    $0.convertToViewModel()
                }
                self.photos += photos
                print(">>> Read \(photos.count) new photos. Total \(self.photos.count) photos")
                NotificationCenter.default
                    .post(
                        name: ImagesListService.DidChangeNotification,
                        object: self)
                
                self.task = nil
            case .failure(let error):
                print(">>> ImagesList loading error = \(error)")
            }
        }
        self.task = task
        task.resume()
    }
}

extension ImagesListService {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<[PhotoResult], Error>) -> Void
    ) -> URLSessionTask {
        return urlSession.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
            completion(result)
        }
    }
    
    private func makeImagesListRequest(page: Int) -> URLRequest {
        let url = DefaultBaseURL.appendingPathComponent("/photos")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

        urlComponents?.queryItems = [
            .init(name: "page", value: "\(page)"),
            .init(name: "per_page", value: "10")
        ]

        guard let imagesListUrl = urlComponents?.url else {
            preconditionFailure(">>> Error imagesListUrl creation")
        }
        
        var request = URLRequest(url: imagesListUrl)
        request.setValue("Bearer \(OAuth2TokenStorage().token.unwrap)", forHTTPHeaderField: "Authorization")
        return request
    }
}


