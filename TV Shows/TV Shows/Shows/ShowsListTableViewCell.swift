//
//  ShowsListTableViewCell.swift
//  TV Shows
//
//  Created by Jakov on 31.07.2022..
//

import UIKit

final class ShowsListTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 16,y: 0,width: 64,height: 90)
        self.textLabel?.frame = CGRect(x: 104, y: 45, width: self.frame.width - 45, height: 20)
        self.textLabel?.font = UIFont.systemFont(ofSize: 17)
        self.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
        self.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
}
