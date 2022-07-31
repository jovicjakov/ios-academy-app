//
//  WriteReviewViewController.swift
//  TV Shows
//
//  Created by Jakov on 30.07.2022..
//

import UIKit
import Alamofire
import MBProgressHUD

final class WriteReviewViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var enterCommentTextField: UITextField!
    @IBOutlet private weak var submitReviewButton: UIButton!
    @IBOutlet private weak var ratingView: RatingView!
    
    // MARK: - Properties
    
    private var rating: Double!
    public var show_id: Double!
    public var review: ReviewsResponse!
    public var authInfo: AuthInfo!
    
    // MARK: - Delegates
    
    private weak var delegate: ReviewsListDelegate?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction func submitReviewButtonTouched() {
        guard
            let comment = enterCommentTextField.text,
            !comment.isEmpty
        else {
            submitReviewFailed()
            return
        }
        submitReviewWith(comment: comment)
    }
    
    @IBAction func writingBegan() {
        submitReviewButton.isEnabled = true
    }
    
    // MARK: - Utility methoods
    
    private func setupUI() {
        let closeViewItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeView)
        )
        closeViewItem.tintColor = UIColor.init(red: 0.322, green: 0.212, blue: 0.549, alpha: 1)
        navigationItem.leftBarButtonItem = closeViewItem
        
        ratingView.configure(withStyle: .large)
        ratingView.isEnabled = false
        
        submitReviewButton.isEnabled = false
        enterCommentTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your comment here...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )
    }
    
    private func submitReviewFailed() {
        let alert = UIAlertController(title: "Failed to submit comment", message: "The operation couldn't be completed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func closeView() {
        self.dismiss(animated: true)
    }
}

// MARK: - Register + automatic JSON parsing

private extension WriteReviewViewController {
    
    func submitReviewWith(comment: String) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        struct reviewData: Codable {
            let rating: Int
            let comment: String
            let show_id: Double
        }
        
        let parameters = reviewData(rating: 2, comment: comment, show_id: show_id)
        
        AF
            .request(
                "https://tv-shows.infinum.academy/reviews",
                method: .post,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: HTTPHeaders(authInfo.headers)
            )
            .validate()
            .responseDecodable(of: ReviewsResponsePost.self) { [weak self] dataResponse in
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                switch dataResponse.result {
                case .success(let reviewsResponse):
                    print("API/Serialization success: \(reviewsResponse)")
                    self.delegate?.refreshTableView()
                    self.dismiss(animated: true)
                case .failure(let error):
                    print("API/Serialization failure: \(error)")
                    self.submitReviewFailed()
                }
            }
    }
}
