//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 11.07.2023.
//

import UIKit

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func getPhotosCount() -> Int
    func getImageListCell(indetPath: IndexPath) -> UITableViewCell
    func getHeightFotTableWiewRow(heightForRowAt indexPath: IndexPath) -> CGFloat
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol, ImagesListCellDelegate {
    weak var view: ImagesListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    private let nulPhotoImage = UIImage(named: "NulPhotoImage") ?? UIImage()
    
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
    }
    
    private func updateTableViewAnimated() {
        let oldCount = view?.getTableViewNumberOfRows() ?? 0
        let newCount = ImagesListService.shared.photos.count

        if oldCount < newCount {
            let newPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.insertTableViewRows(newPath: newPaths)
        }
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = view?.getTableViewIndexPath(cell: cell) else { return }
        let photo = ImagesListService.shared.photos[indexPath.row]
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) {(result: Result<Bool, Error>) in
            switch result {
            case .success(let isLike):
                cell.like = isLike
            case .failure(let error):
                print(">>> Error set like : \(error)")
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func getPhotosCount() -> Int {
        return ImagesListService.shared.photos.count
    }
    
    func getImageListCell(indetPath indexPath: IndexPath) -> UITableViewCell {
        let cell = view?.getTableViewCell(cellForRowAt: indexPath) //tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func getHeightFotTableWiewRow(heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = ImagesListService.shared.photos[indexPath.row].size
        let aspectRatio = imageSize.height / imageSize.width
        let width = (view?.getTableViewBoundsWidth() ?? 0) - 16 * 2
        return  aspectRatio * width + 4 * 2
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        guard
            let url = URL(string: ImagesListService.shared.photos[indexPath.row].thumbImageURL)
        else { return }
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: nulPhotoImage) {[weak self] _ in
            guard let self else { return }
            view?.reloadTableViewRows(indexPaths: [indexPath])
            //self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        if let createdAt = ImagesListService.shared.photos[indexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = nil
        }
        cell.like = ImagesListService.shared.photos[indexPath.row].isLiked
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}