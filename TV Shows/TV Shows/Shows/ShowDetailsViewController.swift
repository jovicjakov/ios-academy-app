//
//  ShowDetailsViewController.swift
//  TV Shows
//
//  Created by Jakov on 29.07.2022..
//

import UIKit
import Alamofire

protocol ReviewsListDelegate: AnyObject {
    func refreshTableView()
}

final class ShowDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var writeReviewButton: UIButton!
    @IBOutlet weak var showTitleLabel: UILabel!
    
    // MARK: - Properties
    
    public var show: Show!
    public var authInfo: AuthInfo!
    private var reviewsResponse: ReviewsResponse!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReviewsData()
        setupUI()
    }
    
    func refreshTableView() {
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func writeReviewNavigation() {
        pushWriteReviewController()
    }
    
    // MARK: - Utility methods
    
    @objc
    private func pushWriteReviewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let writeReviewController = storyboard.instantiateViewController(withIdentifier: "WriteReviewController") as! WriteReviewViewController
        let navigationController = UINavigationController(rootViewController: writeReviewController)
        writeReviewController.authInfo = authInfo
        writeReviewController.review = reviewsResponse
        writeReviewController.show_id = Double(show.id)
        present(navigationController, animated: true)
    }
    
    private func setupUI() {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = UIColor.lightGray
        self.view.addSubview(navigationBar)
        
        self.tableView.register(UINib.init(nibName: "Cell1TableViewCell", bundle: .main), forCellReuseIdentifier: "Cell1TableViewCell")
        self.tableView.register(UINib.init(nibName: "Cell2TableViewCell", bundle: .main), forCellReuseIdentifier: "Cell2TableViewCell")
        showTitleLabel.text = show.title
    }
}
// MARK: - UITableView

extension ShowDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + Int(show.no_of_reviews)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row ==  0) {
            let cell1:Cell1TableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell1TableViewCell", for: indexPath) as! Cell1TableViewCell
            cell1.selectionStyle = .none
            cell1.descriptionText.text = show.description
            cell1.descriptionText.isScrollEnabled = false
            
            cell1.isUserInteractionEnabled = false
            if (show.no_of_reviews > 0 && show.average_rating != nil) {
                cell1.numberOfReviewsLabel.text = String("\(Int(show.no_of_reviews)) REVIEWS, \(Double(show.average_rating!)) AVERAGE")
                //                cell1.configure(with: show)
                
                cell1.showImage.kf.setImage(
                    with: URL(string: show.image_url),
                    placeholder: UIImage(named: "ic-show-placeholder-rectangle")
                )
            } else {
                cell1.numberOfReviewsLabel.text = String("No reviews yet.")
            }
            return cell1
        }
        else if (indexPath.row >= reviewsResponse.reviews.startIndex && indexPath.row < reviewsResponse.reviews.endIndex)  {
            let cell2:Cell2TableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell2TableViewCell", for: indexPath) as! Cell2TableViewCell
            cell2.selectionStyle = .none
            cell2.userEmailLabel.text = reviewsResponse.reviews[indexPath.row].user.email
            cell2.userReviewText.text = reviewsResponse.reviews[indexPath.row].comment
            cell2.userImage.layer.masksToBounds = false
            cell2.userImage.layer.cornerRadius = cell2.userImage.frame.height/2
            cell2.userImage.clipsToBounds = true
            cell2.userImage?.kf.setImage(
                with: URL(string: reviewsResponse.reviews[indexPath.row].user.imageUrl ?? "no url"),
                placeholder: UIImage(named: "ic-profile-placeholder")
            )
            return cell2
        }
        else {
            return UITableViewCell.init(frame: CGRect.zero)
        }
    }
}

// MARK: - GET review + automatic JSON parsing

private extension ShowDetailsViewController {
    
    func getReviewsData() {
        let show_id = String(show.id)
        AF.request(
            "https://tv-shows.infinum.academy/shows/\(show_id)/reviews",
            method: .get,
            parameters: ["page": "1", "items": "20"],
            headers: HTTPHeaders(authInfo.headers)
        )
        .validate()
        .responseDecodable(of: ReviewsResponse.self) { [weak self] dataResponse in
            guard let self = self else { return }
            switch dataResponse.result {
            case .success(let reviewsResponse):
                self.reviewsResponse = reviewsResponse
                print("API/Serialization success: \(reviewsResponse)")
            case .failure(let error):
                print("API/Serialization failure: \(error)")
            }
        }
    }
}
