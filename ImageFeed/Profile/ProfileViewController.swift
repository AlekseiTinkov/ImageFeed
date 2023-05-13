//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 11.05.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private var profileImage: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func logoutButtonTap(_ sender: Any) {
    }
}
