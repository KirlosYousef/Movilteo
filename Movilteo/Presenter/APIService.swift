//
//  APIService.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import Alamofire
import UIKit


class APIService{
    
    static let shared = APIService()
    
    func fetchMovies(page: Int, _ complition: @escaping (Movies) -> ()){
        let url = "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDBApiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)"
        
        AF.request(url)
            .validate()
            .responseDecodable(of: Movies.self) { (response) in
                guard let movies = response.value else { return }
                complition(movies)
            }
    }
    
    func searchMovie(for query: String, page: Int, _ complition: @escaping (Movies) -> ()){
        let url = "https://api.themoviedb.org/3/search/movie?api_key=\(TMDBApiKey)&language=en-US&query=\(query)&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)"    
        
        AF.request(url)
            .validate()
            .responseDecodable(of: Movies.self) { (response) in
                guard let movies = response.value else { return }
                complition(movies)
            }
    }
}
