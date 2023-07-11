//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 19.06.2023.
//

import UIKit
 
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
                    title: nil,
                    image: UIImage(named: "tab_profile_active"),
                    selectedImage: nil
                )
        
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
        //profileViewController.delegate = self
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
