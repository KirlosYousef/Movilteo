//
//  Movie.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation

struct Movie: Codable {
    
    let id: Int
    let title: String?
    let backdropPath: String?
    let posterPath: String?
    let overview: String
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case overview
        case voteAverage = "vote_average"
    }
}

protocol Displayable {
    var titleLabelText: String { get }
    var posterURL: URL { get }
    var backdropURL: URL { get }
    var voteAveragePercentText: String { get }
    var ratingText: String { get }
}


extension Movie: Displayable {
    var titleLabelText: String {
        return title ?? "Title"
    }
    
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath ?? "")")!
    }
    
    var voteAveragePercentText: String {
        return "\(Int(voteAverage * 10))%"
    }
    
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        return ratingText
    }
}