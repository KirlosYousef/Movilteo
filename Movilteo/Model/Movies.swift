//
//  Movies.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 10..
//

import Foundation

struct Movies: Decodable {
    let page: Int
    let totalPages: Int
    let all: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case all = "results"
    }
}
