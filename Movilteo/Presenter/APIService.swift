//
//  APIService.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import Alamofire
import UIKit


enum FetchingError: Error {
    case noConnection
    case noStoredMovies
}

class APIService{
    
    static let shared = APIService()
    
    func fetchMovies(page: Int, completionHandler: @escaping (Result<Movies, FetchingError>) -> Void){
        let url = "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDBApiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)"
        
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        AF.request(url)
            .validate()
            .responseDecodable(of: Movies.self) { (response) in
                guard let movies = response.value else {
                    return completionHandler(.failure(.noConnection))
                }
                completionHandler(.success(movies))
            }
    }
    
    func fetchMoviesWithGenre(page: Int, genreId: Int, completionHandler: @escaping (Result<Movies, FetchingError>) -> Void){
        let url = "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDBApiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)&with_genres=\(genreId)"
        
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        AF.request(url)
            .validate()
            .responseDecodable(of: Movies.self) { (response) in
                guard let movies = response.value else {
                    return completionHandler(.failure(.noConnection))
                }
                completionHandler(.success(movies))
            }
    }
    
    func searchMovie(for query: String, page: Int, _ complition: @escaping (Movies) -> ()){
        let url = "https://api.themoviedb.org/3/search/movie?api_key=\(TMDBApiKey)&language=en-US&query=\(query)&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)"
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        AF.request(url)
            .validate()
            .responseDecodable(of: Movies.self) { (response) in
                guard let movies = response.value else { return }
                complition(movies)
            }
    }
    
    func getGenres( _ complition: @escaping (Genres) -> ()){
        let url = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(TMDBApiKey)&language=en-US"
        
        AF.request(url)
            .validate()
            .responseDecodable(of: Genres.self) { (response) in
                guard let genres = response.value else { return }
                complition(genres)
            }
    }
}
