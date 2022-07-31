//
//  Cell1TableViewCell.swift
//  TV Shows
//
//  Created by Jakov on 30.07.2022..
//

import UIKit

final class Cell1TableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet public weak var showImage: UIImageView!
    @IBOutlet public weak var descriptionText: UITextView!
    @IBOutlet public weak var reviewsLabel: UILabel!
    @IBOutlet public weak var numberOfReviewsLabel: UILabel!
    @IBOutlet public weak var ratingView: RatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.configure(withStyle: .small)
        ratingView.isEnabled = false
    }
    
    func configure(with show: Show) {
//        ratingView.setRoundedRating(show.average_rating!)
    }
}
