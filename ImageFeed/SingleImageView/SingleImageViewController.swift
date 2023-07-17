//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 15.05.2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageUrl: String!
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityIdentifier = "BackButton"
        scrollView.minimumZoomScale = 0.03
        scrollView.maximumZoomScale = 1.25
        showImage()
    }
    
    private func showImage() {
        guard
            let url = URL(string: imageUrl)
        else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url)  { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showErrorAlert()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image else { return }
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale))) // исправил на масштабирование самой большой стороне
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: nil,
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default){ [weak self] _ in
            guard let self else { return }
            self.showImage()
        })
        alert.addAction(UIAlertAction(title: "Не надо", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [imageView.image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
