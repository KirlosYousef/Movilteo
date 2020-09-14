//
//  Movie.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import RealmSwift

class Movie: Object, Decodable{
    
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var backdropPath: String?
    @objc dynamic var posterPath: String?
    @objc dynamic var overview: String = ""
    @objc dynamic var voteAverage: Double = 0.0
    let genreIds = List<Int>()
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.posterPath = try container.decode(String.self, forKey: .posterPath)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        let genres = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? [Int(from: decoder)]
        genreIds.append(objectsIn: genres)
    }
    
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
        case genreIds = "genre_ids"
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
    
    /// Deprecated
    var voteAveragePercentText: String {
        return "\(Int(voteAverage * 10))%"
    }
    
    /// Deprecated
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        return ratingText
    }
}
