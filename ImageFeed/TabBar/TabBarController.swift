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
        ) as! any ImagesListViewControllerProtocol & UIViewController
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
                    title: nil,
                    image: UIImage(named: "tab_profile_active"),
                    selectedImage: nil
                )
        
        let imagesListViewPresenter = ImagesListViewPresenter(imagesListService: ImagesListService.shared)
        imagesListViewController.presenter = imagesListViewPresenter
        imagesListViewPresenter.view = imagesListViewController
        
        let profileViewPresenter = ProfileViewPresenter(profileService: ProfileService.shared, profileImageService: ProfileImageService.shared)
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
