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
    var photos: [ImageFeed.Photo] = []
    
    func fetchPhotosNextPage() {
        for i in (1...photosPerPage) {
            photos.append(.init(id: "\(i)", size: CGSize(width: 1024, height: 1024), createdAt: nil, welcomeDescription: "123", thumbImageURL: "https://ya.ru/t", largeImageURL: "https://ya.ru/l", isLiked: false))
        }
        NotificationCenter.default
            .post(
                name: ImagesListService.DidChangeNotification,
                object: self)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        photos[photos.firstIndex(where: {$0.id == photoId})!].isLiked = isLike
        completion(.success(isLike))
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var fetchedPhotos = 0
    var likedPhoto: Bool?
    var presenter: ImageFeed.ImagesListViewPresenterProtocol?
    
    func getTableViewNumberOfRows() -> Int { 0 }
    
    func getTableViewIndexPath(cell: ImageFeed.ImagesListCell) -> IndexPath? { IndexPath()}
    
    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell? { UITableViewCell() }
    
    func getTableViewBoundsWidth() -> CGFloat { CGFloat() }
    
    func insertTableViewRows(newPath: [IndexPath]) {
        self.fetchedPhotos = newPath.count
    }
    
    func reloadTableViewRows(indexPaths: [IndexPath]) {}
    
    func setLike(indexPath: IndexPath, isLike: Bool) {
        self.likedPhoto = isLike
    }
}

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var viewDidLoadCalled = false
    var view: ImageFeed.ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getPhotosCount() -> Int { 0}
    
    func getHeightFotTableWiewRow(heightForRowAt indexPath: IndexPath) -> CGFloat { CGFloat() }
    
    func isLastRow(indexPath: IndexPath) -> Bool { false }
    
    func fetchPhotosNextPage() {}
    
    func configCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) {}
}

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let controller = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        _ = controller.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testFetchPhotos() {
        //given
        let imagesListServiceMoc = ImagesListServiceMoc()
        let controller = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter(imagesListService: imagesListServiceMoc)
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertEqual(controller.fetchedPhotos, photosPerPage)
        
        //when 2
        presenter.fetchPhotosNextPage()
        
        //then 2
        XCTAssertEqual(controller.fetchedPhotos, photosPerPage * 2)
    }
    
    func testChangeLike() {
        //given
        let imagesListServiceMoc = ImagesListServiceMoc()
        let controller = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter(imagesListService: imagesListServiceMoc)
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        presenter.viewDidLoad()
        presenter.fetchPhotosNextPage()
        presenter.changeLike(indexPath: IndexPath(row: 0, section: 0))
        
        //then
        XCTAssertEqual(controller.likedPhoto, true)
        
        //when 2
        presenter.changeLike(indexPath: IndexPath(row: 0, section: 0))
        
        //then 2
        XCTAssertEqual(controller.likedPhoto, false)
    }
}
