//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 30.04.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
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

    @IBAction func didTapLikeButton(_ sender: Any) {
        like = !like
    }
    
}

