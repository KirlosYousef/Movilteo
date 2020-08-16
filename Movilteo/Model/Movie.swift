//
//  Movie.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import RealmSwift

class Movie: Object, Decodable {
    
    @objc dynamic var id: Int
    @objc dynamic var title: String?
    @objc dynamic var backdropPath: String?
    @objc dynamic var posterPath: String?
    @objc dynamic var overview: String
    @objc dynamic var voteAverage: Double
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
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
        if posterPath == nil {
            return URL(string: "https://upload.wikimedia.org/wikipedia/en/6/60/No_Picture.jpg")!
        }
        
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
