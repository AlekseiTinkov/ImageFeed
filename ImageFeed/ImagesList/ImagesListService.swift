//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 25.06.2023.
//

import Foundation

private struct PhotoResult: Decodable {
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

private struct LikeResult: Decodable {
    let photo: PhotoResult
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

private var dateFormatter = ISO8601DateFormatter()

private extension PhotoResult {
    func convertToViewModel() -> Photo {
        return Photo(id: self.id,
              size: .init(width: self.width, height: self.height),
              createdAt: dateFormatter.date(from: self.createdAt),
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
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let responseBody):
                let photos = responseBody.map {
                    $0.convertToViewModel()
                }
                self.photos += photos
                self.lastLoadedPage = nextPage
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
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil { return }
        let request = makeLikeRequest(photoId: photoId, isLike: isLike)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let responseBody):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index].isLiked = responseBody.photo.isLiked
                }
                completion(.success(responseBody.photo.isLiked))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
 
}

extension ImagesListService {
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
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest {
        let httpMethod = isLike ? "POST" : "DELETE"
        var request =  URLRequest.makeHTTPRequest(
                path: "/photos/\(photoId)/like",
                httpMethod: httpMethod,
                baseURL: DefaultBaseURL
            )
        request.setValue("Bearer \(OAuth2TokenStorage().token.unwrap)", forHTTPHeaderField: "Authorization")
        return request
    }
}


