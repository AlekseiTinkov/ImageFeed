//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 30.04.2023.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    var like: Bool! {
        didSet {
            let likeImage = like ? UIImage(named: "button_like_on") : UIImage(named: "button_like_off")
            likeButton.setImage(likeImage, for: .normal)
        }
    }
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private var likeButton: UIButton!

    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        cellImage.kf.cancelDownloadTask()
    }
    
    @IBAction func didTapLikeButton(_ sender: Any) {
        UIBlockingProgressHUD.show()
        delegate?.imageListCellDidTapLike(self)
    }
    
}
