//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 03.06.2023.
//

import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
                    \.estimatedProgress,
                    options: [],
                    changeHandler: { [weak self] _, _ in
                        guard let self = self else { return }
//                        self.updateProgress()
                        self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
                    })
        
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "UnsplashWebView"
//        let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
//        guard var urlComponents = URLComponents(string: UnsplashAuthorizeURLString) else { return }
//        urlComponents.queryItems = [
//            URLQueryItem(name: "client_id", value: AccessKey),
//            URLQueryItem(name: "redirect_uri", value: RedirectURI),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "scope", value: AccessScope)
//        ]
//        let url = urlComponents.url!
//        let request = URLRequest(url: url)
//        webView.load(request)
        presenter?.viewDidLoad()
//        updateProgress()
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }

//    private func updateProgress() {
//        progressView.progress = Float(webView.estimatedProgress)
//        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
//    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

//private func code(from navigationAction: WKNavigationAction) -> String? {
//    if
//        let url = navigationAction.request.url,
//        let urlComponents = URLComponents(string: url.absoluteString),
//        urlComponents.path == "/oauth/authorize/native",
//        let items = urlComponents.queryItems,
//        let codeItem = items.first(where: { $0.name == "code" })
//    {
//        return codeItem.value
//    } else {
//        return nil
//    }
//}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
            self.dismiss(animated: true)
        } else {
            decisionHandler(.allow)
        }
    }
}

