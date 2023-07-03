//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 11.05.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let nulProfileImage = UIImage(named: "NulProfileImage") ?? UIImage(systemName: "person.crop.circle.fill")!
    private var profileImage: UIImageView?
    private var nameLabel: UILabel = UILabel()
    private var loginLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers = Set<CALayer>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addProfileImage()
        addProfileLabel(label: nameLabel,
                 text: "",
                 color: .ypWhite, font: UIFont.boldSystemFont(ofSize: 23.0))
        addProfileLabel(label: loginLabel,
                 text: "",
                 color: .ypGray,
                 font: UIFont.systemFont(ofSize: 13.0))
        addProfileLabel(label: descriptionLabel,
                 text: "",
                 color: .ypWhite,
                 font: UIFont.systemFont(ofSize: 13.0))
        addLogoutButton()
        
        updateProfileDetails(profile: profileService.profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func updateProfileDetails(profile: Profile?) {
        self.nameLabel.text = profile?.name
        self.loginLabel.text = profile?.loginName
        self.descriptionLabel.text = profile?.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        print(">>> \(url)")
        profileImage?.kf.setImage(with: url,
                                  placeholder: nulProfileImage)
        animationLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
    }
    
    private func addProfileImage() {
        let profileImage = UIImageView(image: nulProfileImage)
        profileImage.tintColor = .ypGray
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
        view.addSubview(profileImage)
        profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        profileImage.layer.addSublayer(gradient)
        self.profileImage = profileImage
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    private func addProfileLabel(label: UILabel, text: String?, color: UIColor, font: UIFont) {
        guard let yAnchor = view.subviews.last?.bottomAnchor else { return }
        label.text = text
        label.textColor = color
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        label.topAnchor.constraint(equalTo: yAnchor, constant: 8).isActive = true

        let gradient = CAGradientLayer()
        label.sizeToFit()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width - 32, height: font.pointSize))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = font.pointSize / 2
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        label.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    private func addLogoutButton() {
        guard let profileImage else { return }
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "button_logout") ?? UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapLogoutButton() {
        OAuth2TokenStorage().token = nil
        OAuth2Service.cleanCookie()
        
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
}
