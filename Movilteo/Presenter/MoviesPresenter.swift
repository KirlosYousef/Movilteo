//
//  MoviesPresenter.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import RxSwift
//import RealmSwift

protocol MoviesViewPresenter: class {
    func fetchMovies(page: Int)
}

/// Presenter for the MoviesVC.
class MoviesPresenter: MoviesViewPresenter{
    
    weak private var moviesView: MoviesView?
    private let bag = DisposeBag()
    private let apiService: APIService
    let moviesSequence = PublishSubject<Movie>()
    let allMoviesSequence = PublishSubject<Movies>()
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    /// Linking the view with the moviesView variable.
    func attachView(_ view: MoviesView?) {
        if let view = view {
            moviesView = view
        }
        
        fetchMovies(page: 1)
        
        self.moviesSequence.subscribe(onNext: {
            self.moviesView?.addMovies(movie: $0)
        }).disposed(by: bag)
    }
    
    /// Sending to the API Service to fetch the movies.
    func fetchMovies(page: Int) {
        self.moviesView?.setEmpty()
        APIService.shared.fetchMovies(page: page) { moviesRes in
            
            self.moviesView?.setMaxPages(to: moviesRes.totalPages)
            
            for movie in moviesRes.all{
                self.moviesSequence.onNext(movie)
            }
        }
    }
}
