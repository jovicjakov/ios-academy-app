//
//  PostReview.swift
//  TV Shows
//
//  Created by Jakov on 30.07.2022..
//

import Foundation

struct ReviewsResponsePost: Codable {
    let review: ReviewPost
}

struct ReviewPost: Codable {
    let id: String
    let comment: String
    let rating: Double
    let showID: Double
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case comment = "comment"
        case rating = "rating"
        case showID = "show_id"
        case user = "user"
    }
}
