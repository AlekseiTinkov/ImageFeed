//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 08.06.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    private var logoImage: UIImageView?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service.shared
//    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = OAuth2TokenStorage().token {
            self.fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLogoImage()
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func addLogoImage() {
        let image = UIImage(named: "splash_screen_logo")
        let logoImage = UIImageView(image: image)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImage)
        view.backgroundColor = .ypBlack
        logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.logoImage = logoImage
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        print(">>> Code = \(code)")
        UIBlockingProgressHUD.show()
        fetchToken(code)
    }
    
    private func fetchToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code, completion: { result in
            switch result {
            case .success(let token):
                print(">>> Token = \(token)")
                self.fetchProfile(token)
            case .failure(let error):
                print(">>> Error fetch token: \(error)")
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
            }
        })
    }
    
    private func fetchProfile(_ token: String) {
        print(">>> \(token)")
        profileService.fetchProfile(token){ result in
            switch result {
            case .success:
                print(self.profileService.profile?.name as Any)
                self.fetchProfileImage(token: token, username: self.profileService.profile?.username ?? "")
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                print(">>> Error fetch profile")
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
            }
        }
    }
    
    private func fetchProfileImage(token: String, username: String) {
        profileImageService.fetchProfileImageURL(token: token, username: username){ _ in }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему.",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
