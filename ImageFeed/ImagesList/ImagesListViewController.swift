//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 29.04.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    private let nulPhotoImage = UIImage(named: "NulPhotoImage") ?? UIImage()
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                updateTableViewAnimated()
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            //let image = UIImage(named: photosName[indexPath.row])
            //viewController.image = image
            // TO DO
            guard
                let url = URL(string: ImagesListService.shared.photos[indexPath.row].thumbImageURL)
            else { return }
            print(">>> \(url)")

            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableViewAnimated() {
//        print(">>> photos.count = \(ImagesListService.shared.photos.count)")
        
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = ImagesListService.shared.photos.count

        if oldCount < newCount {
            let newPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: newPaths, with: .automatic)
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
//        return image.size.height / image.size.width * ( tableView.bounds.width - 16 * 2 ) + 4 * 2
        
        let imageSize = ImagesListService.shared.photos[indexPath.row].size
        return imageSize.height / imageSize.width * ( tableView.bounds.width - 16 * 2 ) + 4 * 2
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == ImagesListService.shared.photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImagesListService.shared.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
//        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
//        cell.selectionStyle = UITableViewCell.SelectionStyle.none
//
//        cell.cellImage.image = image
        
        guard
            let url = URL(string: ImagesListService.shared.photos[indexPath.row].thumbImageURL)
        else { return }
        print(">>> \(indexPath.row)")
        print(">>> \(url)")
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: nulPhotoImage)
        cell.cellImage.kf.setImage(with: url, placeholder: nulPhotoImage) {[weak self] _ in
            guard let self else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        //cell.dateLabel.text = dateFormatter.string(from: Date())
        //cell.like = (indexPath.row % 2 != 0)
        cell.dateLabel.text = dateFormatter.string(from: ImagesListService.shared.photos[indexPath.row].createdAt)
        cell.like = ImagesListService.shared.photos[indexPath.row].isLiked
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = ImagesListService.shared.photos[indexPath.row]
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) {(result: Result<Bool, Error>) in
            switch result {
            case .success(let isLike):
                cell.like = isLike
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print(">>> Error set like : \(error)")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

