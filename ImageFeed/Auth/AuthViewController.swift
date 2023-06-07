//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 03.06.2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let showWebVieweSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebVieweSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else { return }
            webViewViewController.delegate = self
        }
        super.prepare(for: segue, sender: sender)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print(">>> Code = \(code)")
        OAuth2Service.shared.fetchOAuthToken(code, completion: { result in
            switch result {
            case .success(let token):
                print(">>> Token = \(token)")
            case .failure(let error):
                print(">>> Error = \(error)")
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
