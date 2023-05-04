//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 29.04.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
        return image.size.height / image.size.width * ( tableView.bounds.width - 16 * 2 ) + 4 * 2
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { ///
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.likeButtonAction = { [] in
            print("Testing aspect ratio\npicture number: \(indexPath.row)")
            let image = UIImage(named: self.photosName[indexPath.row])
            let imageWidth = image?.size.width ?? 0
            let imageHeight = image?.size.height ?? 1
            print("picture size: w=\(imageWidth), h=\(imageHeight), w/h=\(imageWidth / imageHeight)")
            print("cellImage size: w=\(imageListCell.cellImage.bounds.width), h=\(imageListCell.cellImage.bounds.height), w/h=\(imageListCell.cellImage.bounds.width / imageListCell.cellImage.bounds.height)")
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.setLike(indexPath.row % 2 != 0)
    }
}

