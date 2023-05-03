//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 30.04.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak private var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var likeButtonAction : (() -> ())?

    @IBAction private func likeButtonTap(_ sender: Any) {
        likeButtonAction?()
    }
    
    func setLike(_ like: Bool) {
        let likeImage = like ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}

