//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 08.06.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service.shared
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = OAuth2TokenStorage().token {
            self.fetchProfile(token)
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
           }
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
            }
        }
    }
    
    //ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
    
    private func fetchProfileImage(token: String, username: String) {
        profileImageService.fetchProfileImageURL(token: token, username: username){ _ in }
    }
}
