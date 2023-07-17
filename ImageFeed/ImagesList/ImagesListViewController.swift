//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 29.04.2023.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    func getTableViewNumberOfRows() -> Int
    func getTableViewIndexPath(cell: ImagesListCell) -> IndexPath?
    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func getTableViewBoundsWidth() -> CGFloat
    func insertTableViewRows(newPath: [IndexPath])
    func reloadTableViewRows(indexPaths: [IndexPath])
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
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
            viewController.imageUrl = ImagesListService.shared.photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func getTableViewNumberOfRows() -> Int {
        return tableView.numberOfRows(inSection: 0)
    }
    
    func getTableViewIndexPath(cell: ImagesListCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
    func insertTableViewRows(newPath: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: newPath, with: .automatic)
        }
    }
    
    func reloadTableViewRows(indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func getTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
    }
    
    func getTableViewBoundsWidth() -> CGFloat {
        return tableView.bounds.width
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.getHeightFotTableWiewRow(heightForRowAt: indexPath) ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if presenter?.isLastRow(indexPath: indexPath) == true {
            presenter?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getPhotosCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        presenter?.getImageListCell(indetPath: indexPath) ?? UITableViewCell()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.imageListCellDidTapLike(cell)
    }
}

