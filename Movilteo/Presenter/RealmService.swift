//
//  RealmService.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 15..
//

import Foundation
import RealmSwift

class RealmService{
    
    static let shared = RealmService()
    let realm = try! Realm()
    
    func addToDB(movies: Movies){
        try! self.realm.write {
            self.realm.add(movies, update: .modified)
        }
    }
    
    func fetchMoviesFromDB(page: Int, completionHandler: @escaping (Result<Movies, FetchingError>) -> Void){
        let movies = realm.objects(Movies.self).first { movies -> Bool in
            return movies.page == page
        }
        if movies != nil {
            completionHandler(.success(movies!))
        } else {
            completionHandler(.failure(.noStoredMovies))
        }
    }
}
