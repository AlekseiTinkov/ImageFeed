//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Алексей Тиньков on 17.07.2023.
//

@testable import ImageFeed
import XCTest

class Image_FeedUITests: XCTestCase {
    let testEmail = ""
    let testPassword = ""
    let testName = "Aleksei Tinkov"
    let testUsername = "@boofle"
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(testEmail)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(testPassword)
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        _ = cell.waitForExistence(timeout: 2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        _ = cellToLike.waitForExistence(timeout: 2)
        cellToLike.buttons["LikeButton"].tap()
        
        _ = cellToLike.waitForExistence(timeout: 3)

        cellToLike.buttons["LikeButton"].tap()
        
        _ = cellToLike.waitForExistence(timeout: 3)
        
        cellToLike.tap()
        
        _ = cellToLike.waitForExistence(timeout: 10)
        
        let image = app.scrollViews.images.element(boundBy: 0)

        image.pinch(withScale: 3, velocity: 1) // zoom in

        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["BackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts[testName].exists)
        XCTAssertTrue(app.staticTexts[testUsername].exists)
        
        app.buttons["LogoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}



