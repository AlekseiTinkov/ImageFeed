//
//  ImagesListTest.swift
//  ImageFeedTests
//
//  Created by Алексей Тиньков on 17.07.2023.
//

@testable import ImageFeed
import XCTest

let photosPerPage = 10

final class ImagesListServiceMoc: ImagesListServiceProtocol {
    var likeChanged = false
    var photos: [ImageFeed.Photo] = []
    
    func fetchPhotosNextPage() {
        for i in (1...photosPerPage) {
            photos.append(.init(id: "\(i)", size: CGSize(width: 1024, height: 1024), createdAt: nil, welcomeDescription: "123", thumbImageURL: "https://ya.ru/t", largeImageURL: "https://ya.ru/l", isLiked: true))
        }
        NotificationCenter.default
            .post(
                name: ImagesListService.DidChangeNotification,
                object: self)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        likeChanged = true
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var fetchedPhotos = 0
    var presenter: ImageFeed.ImagesListViewPresenterProtocol?
    
    func getTableViewNumberOfRows() -> Int { return 0 }
    
    func getTableViewIndexPath(cell: ImageFeed.ImagesListCell) -> IndexPath? { return IndexPath()}
    
    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell { return UITableViewCell() }
    
    func getTableViewBoundsWidth() -> CGFloat { return CGFloat() }
    
    func insertTableViewRows(newPath: [IndexPath]) {
        fetchedPhotos = newPath.count
    }
    
    func reloadTableViewRows(indexPaths: [IndexPath]) {}
    
    
}

final class ImagesListTests: XCTestCase {
    func testfetchPhotos() {
        //given
        let imagesListServiceSpy = ImagesListServiceMoc()
        let controller = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter(imagesListService: imagesListServiceSpy)
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        presenter.viewDidLoad()
        presenter.fetchPhotosNextPage()
        
        //then
        XCTAssertEqual(controller.fetchedPhotos, photosPerPage)
    }
}
