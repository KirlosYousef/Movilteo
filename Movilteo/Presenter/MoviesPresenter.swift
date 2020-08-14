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
    let moviesSequence = PublishSubject<Movie>()
    let searchedMoviesSequence = PublishSubject<Movie>()
    
    /// Linking the view with the moviesView variable.
    func attachView(_ view: MoviesView?) {
        if let view = view {
            moviesView = view
        }
        
        fetchMovies(page: 1)
        
        self.moviesSequence.subscribe(onNext: {
            self.moviesView?.addMovies(movie: $0)
        }).disposed(by: bag)
        
        self.searchedMoviesSequence.subscribe(onNext: {
            self.moviesView?.addMovies(movie: $0)
        }).disposed(by: bag)
    }
    
    /// Sending to the API Service to fetch the movies.
    func fetchMovies(page: Int) {
        
        self.moviesView?.setEmpty()
        
        APIService.shared.fetchMovies(page: page) { moviesRes in
            
            self.moviesView?.setMaxPages(to: moviesRes.totalPages)
            self.moviesView?.setCurrentPage(to: moviesRes.page)
            
            for movie in moviesRes.all{
                self.moviesSequence.onNext(movie)
            }
            
            self.moviesView?.reload()
        }
    }
    
    /// Sending to the API Service to fetch the movies with searching keyword.
    func fetchMovies(withKeyword keyword: String, page: Int){
        
        self.moviesView?.setEmpty()
        
        let keywordMerged = keyword.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        APIService.shared.searchMovie(for: keywordMerged, page: page) { moviesRes in
            
            self.moviesView?.setMaxPages(to: moviesRes.totalPages)
            self.moviesView?.setCurrentPage(to: moviesRes.page)
            
            
            for movie in moviesRes.all{
                self.searchedMoviesSequence.onNext(movie)
            }
            
            self.moviesView?.reload()
        }
    }
}
