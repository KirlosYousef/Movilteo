//
//  Genres.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 09. 13..
//

import Foundation
import RealmSwift

class Genres: Object, Decodable{
    var all = List<Genre>()
    
    enum CodingKeys: String, CodingKey {
        case all = "genres"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let genres = try container.decodeIfPresent([Genre].self, forKey: .all) ?? [Genre(from: decoder)]
        all.append(objectsIn: genres)
    }
}
