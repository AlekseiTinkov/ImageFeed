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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private var likeButton: UIButton!
    
    var likeButtonAction : (() -> ())?
    
    func setLike(_ like: Bool) {
        let likeImage = like ? UIImage(named: "button_like_on") : UIImage(named: "button_like_off")
        likeButton.setImage(likeImage, for: .normal)
    }

    @IBAction private func likeButtonTap(_ sender: Any) {
        likeButtonAction?()
    }
}

