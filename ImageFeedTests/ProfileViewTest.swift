//
//  ProfileViewTest.swift
//  ImageFeedTests
//
//  Created by Алексей Тиньков on 17.07.2023.
//

@testable import ImageFeed
import XCTest

let testUserName = "UserName"
let testFirstName = "FirstName"
let testLastName = "LastName"
let testBio = "Bio"

final class ProfileImageServiceMoc: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        self.avatarURL = "https://avatar.xyz"
        NotificationCenter.default
            .post(
                name: ProfileImageService.DidChangeNotification,
                object: self)
    }
}

final class ProfileServiceMoc: ProfileServiceProtocol {
    var profile: ImageFeed.Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeed.Profile, Error>) -> Void) {
        profile = Profile(from: .init(username: testUserName, firstName: testFirstName, lastName: testLastName, bio: testBio))
    }
    
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var avatarUpdated = false
    var profile: Profile?
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    
    func updateAvatar(_ url: URL) {
        self.avatarUpdated = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
        self.profile = profile
    }
    
    func presentViewController(viewContriller: UIViewController) {
    }
    
    func didTapLogoutButton() {
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var logoutCalled = false
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    func viewDidLoad() {
    }
    
    func didTapLogoutButton() {
        self.logoutCalled = true
    }
    
    
}

final class ProfileViewTests: XCTestCase {
    func testUpdateAvatar() {
        //given
        let imageService = ProfileImageServiceMoc()
        let presenter = ProfileViewPresenter(profileService: ProfileService.shared, profileImageService: imageService)
        let controller = ProfileViewControllerSpy()
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        presenter.viewDidLoad()
        imageService.fetchProfileImageURL(token: "token", username: "user", { _ in })
        
        //then
        XCTAssertTrue(controller.avatarUpdated)
    }
    
    func testUpdateUserInfo() {
        //given
        let profileService = ProfileServiceMoc()
        let presenter = ProfileViewPresenter(profileService: profileService, profileImageService: ProfileImageService().self)
        let controller = ProfileViewControllerSpy()
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        profileService.fetchProfile("", completion: { _ in })
        presenter.viewDidLoad()
        
        //then
        XCTAssertEqual(controller.profile?.name, "\(testFirstName) \(testLastName)")
        XCTAssertEqual(controller.profile?.loginName, "@\(testUserName)")
        XCTAssertEqual(controller.profile?.bio, testBio)
    }
    
    func testLogout() {
        //given
        let controller = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        presenter.view = controller
        controller.presenter = presenter
        
        //when
        controller.didTapLogoutButton()
        
        //then
        XCTAssertTrue(presenter.logoutCalled)
    }
}
