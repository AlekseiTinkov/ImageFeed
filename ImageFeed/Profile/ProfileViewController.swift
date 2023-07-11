//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 11.05.2023.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: UIViewController {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar(_ url: URL)
    func updateProfileDetails(profile: Profile?)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    private let nulProfileImage = UIImage(named: "NulProfileImage") ?? UIImage(systemName: "person.crop.circle.fill")!
    private var profileImage: UIImageView?
    private var nameLabel: UILabel = UILabel()
    private var loginLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        
        presenter?.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configView() {
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
        self.profileImage = profileImage
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
    
    func updateProfileDetails(profile: Profile?) {
        self.nameLabel.text = profile?.name
        self.loginLabel.text = profile?.loginName
        self.descriptionLabel.text = profile?.bio
    }
    
    func updateAvatar(_ url: URL) {
        self.profileImage?.kf.setImage(with: url,
                                  placeholder: nulProfileImage)
    }
    
    @objc
    private func didTapLogoutButton() {
        presenter?.didTapLogoutButton()
    }

}
