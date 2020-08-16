//
//  Movies.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 10..
//

import Foundation
import RealmSwift

class Movies: Object, Decodable{
    @objc dynamic var page: Int = 0
    dynamic var totalPages: Int?
    var all = List<Movie>()
    
    override class func primaryKey() -> String? {
        return "page"
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case all = "results"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decode(Int.self, forKey: .page)
        self.totalPages = try container.decode(Int.self, forKey: .totalPages)
        // Map JSON Array response
        let movies = try container.decodeIfPresent([Movie].self, forKey: .all) ?? [Movie(from: decoder)]
        all.append(objectsIn: movies)
    }
}
