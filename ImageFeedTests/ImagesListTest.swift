//
//  ImagesListTest.swift
//  ImageFeedTests
//
//  Created by Алексей Тиньков on 17.07.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var likeChanged = false
    var photos: [ImageFeed.Photo] = []
    
    func fetchPhotosNextPage() {
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        likeChanged = true
    }
}

final class I: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListViewPresenterProtocol?
    
    func getTableViewNumberOfRows() -> Int {
        <#code#>
    }
    
    func getTableViewIndexPath(cell: ImageFeed.ImagesListCell) -> IndexPath? {
        <#code#>
    }
    
    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    func getTableViewBoundsWidth() -> CGFloat {
        <#code#>
    }
    
    func insertTableViewRows(newPath: [IndexPath]) {
        <#code#>
    }
    
    func reloadTableViewRows(indexPaths: [IndexPath]) {
        <#code#>
    }
    
    func imageListCellDidTapLike(_ cell: ImageFeed.ImagesListCell) {
        <#code#>
    }
    
    
}

final class ImagesListTests: XCTestCase {
    func testL() {
        //given
        let imagesListServiceSpy = ImagesListServiceSpy()
        let controller = ImagesListViewController()
        let presenter = ImagesListViewPresenter(imagesListService: imagesListServiceSpy)
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        controller.viewDidLoad()
        
        //then
        XCTAssertTrue(imagesListServiceSpy.likeChanged)
    }
}
