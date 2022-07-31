//
//  Show.swift
//  TV Shows
//
//  Created by Jakov on 27.07.2022..
//

import Foundation

struct ShowsResponse: Decodable {
    let shows: [Show]
}

struct Show: Decodable {
    let id: String
    let average_rating: Double?
    let description: String?
    let image_url: String
    let no_of_reviews: Double
    let title: String
}
