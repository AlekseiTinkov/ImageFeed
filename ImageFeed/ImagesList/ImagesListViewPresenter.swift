//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 11.07.2023.
//

import UIKit
import ProgressHUD

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func getPhotosCount() -> Int
    func getHeightFotTableWiewRow(heightForRowAt indexPath: IndexPath) -> CGFloat
    func isLastRow(indexPath: IndexPath) -> Bool
    func fetchPhotosNextPage()
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol, ImagesListCellDelegate {
    weak var view: ImagesListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    private let nulPhotoImage = UIImage(named: "NulPhotoImage") ?? UIImage()
    var imagesListService: ImagesListServiceProtocol
    
    init(imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = view?.getTableViewNumberOfRows() ?? 0
        let newCount = imagesListService.photos.count

        if oldCount < newCount {
            let newPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.insertTableViewRows(newPath: newPaths)
        }
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = view?.getTableViewIndexPath(cell: cell) else { return }
        changeLike(indexPath: indexPath)
    }
    
    func changeLike(indexPath: IndexPath) {
        ProgressHUD.show()
        let photo = imagesListService.photos[indexPath.row]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {(result: Result<Bool, Error>) in
            switch result {
            case .success(let isLike):
                self.view?.setLike(indexPath: indexPath, isLike: isLike)
            case .failure(let error):
                print(">>> Error set like : \(error)")
            }
            ProgressHUD.dismiss()
        }
    }
    
    func getPhotosCount() -> Int {
        return imagesListService.photos.count
    }
    
    func getHeightFotTableWiewRow(heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = imagesListService.photos[indexPath.row].size
        let aspectRatio = imageSize.height / imageSize.width
        let width = (view?.getTableViewBoundsWidth() ?? 0) - 16 * 2
        return  aspectRatio * width + 4 * 2
    }
    
    func isLastRow(indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 == imagesListService.photos.count
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
   func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        guard
            let url = URL(string: imagesListService.photos[indexPath.row].thumbImageURL)
        else { return }
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: nulPhotoImage) {[weak self] _ in
            guard let self else { return }
            self.view?.reloadTableViewRows(indexPaths: [indexPath])
        }
        if let createdAt = imagesListService.photos[indexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = nil
        }
        cell.like = imagesListService.photos[indexPath.row].isLiked
        cell.likeButton.accessibilityIdentifier = "LikeButton"
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
