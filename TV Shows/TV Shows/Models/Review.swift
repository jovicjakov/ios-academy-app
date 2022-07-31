//
//  Review.swift
//  TV Shows
//
//  Created by Jakov on 30.07.2022..
//

import Foundation

struct ReviewsResponse: Decodable {
    let reviews: [Review]
}

struct Review: Decodable {
    let id: String
    let comment: String
    let rating: Double
    let show_id: Double
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case comment = "comment"
        case rating = "rating"
        case show_id = "show_id"
        case user = "user"
    }
}


