//
//  Cell2TableViewCell.swift
//  TV Shows
//
//  Created by Jakov on 30.07.2022..
//

import UIKit

final class Cell2TableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet public weak var userEmailLabel: UILabel!
    @IBOutlet public weak var userImage: UIImageView!
    @IBOutlet public weak var userReviewText: UITextView!
    @IBOutlet public weak var ratingView: RatingView!
    
    // MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingView.configure(withStyle: .small)
        ratingView.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.frame = CGRect(x: 16,y: 0,width: 50,height: 50)
    }
        
    // MARK: - Utility methods
    private func configure(with show: Show) {
        //ratingView.setRoundedRating(show.average_rating)
    }

}
