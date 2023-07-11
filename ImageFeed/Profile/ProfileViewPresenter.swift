//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 11.07.2023.
//

import UIKit

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
//    func updateAvatar()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        view?.updateProfileDetails(profile: ProfileService.shared.profile)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        self.updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url)
    }
    
    func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default){ [weak self] _ in
            guard let self else { return }
            self.logout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        view?.present(alert, animated: true)
    }
    
    private func logout() {
        OAuth2TokenStorage().token = nil
        OAuth2Service.cleanCookie()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
}
