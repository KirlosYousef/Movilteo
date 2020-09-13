//
//  Genre.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 09. 13..
//

import Foundation
import RealmSwift

class Genre: Object, Decodable {
    
    @objc dynamic var id: Int
    @objc dynamic var name: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
