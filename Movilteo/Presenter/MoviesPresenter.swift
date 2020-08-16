//
//  MoviesPresenter.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import RxSwift

/// Presenter for the MoviesVC.
class MoviesPresenter: MoviesViewPresenter{
    
    weak private var moviesView: MoviesView?
    private let bag = DisposeBag()
    private let moviesSequence = PublishSubject<Movie>()
    private let searchedMoviesSequence = PublishSubject<Movie>()
    
    /// Linking the view with the moviesView variable.
    func attachView(_ view: MoviesView?) {
        if let view = view {
            moviesView = view
        }
        
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
        
        APIService.shared.fetchMovies(page: page) { result in
            switch result{
            
            // When receiving data from the API...
            case .success(let moviesData):
                self.showMovies(moviesData: moviesData)
                
                RealmService.shared.addToDB(movies: moviesData)
                
            // If no internet connection, try the local databse.
            case .failure(_):
                
                RealmService.shared.fetchMoviesFromDB(page: page) { storedResult in
                    switch storedResult{
                    
                    // When receiving data from the database...
                    case .success(let moviesData):
                        self.showMovies(moviesData: moviesData)
                        
                    // If no data available on the databse.
                    case .failure(let err):
                        print(err)
                    }
                }
            }
        }
    }
    
    /// Sends back the movies data to the view to show.
    private func showMovies(moviesData: Movies){
        
        self.moviesView?.setMaxPages(to: moviesData.totalPages ?? 1)
        self.moviesView?.setCurrentPage(to: moviesData.page)
        
        for movie in moviesData.all{
            
            ImagesService.shared.saveImage(posterURL: movie.posterURL, movieID: String(movie.id))
            
            self.moviesSequence.onNext(movie)
        }
        self.moviesView?.reload()
    }
    
    /**
     Sending to the API Service to fetch the movies with searching keyword.
     
     - Parameters:
        - withKeyword: The word to search for.
        - page: Page number of the searching results.
     */
    func searchForMovies(withKeyword keyword: String, page: Int){
        
        self.moviesView?.setEmpty()
        
        let keywordMerged = keyword.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        APIService.shared.searchMovie(for: keywordMerged, page: page) { moviesRes in
            
            self.moviesView?.setMaxPages(to: moviesRes.totalPages!)
            self.moviesView?.setCurrentPage(to: moviesRes.page)
            
            
            for movie in moviesRes.all{
                self.searchedMoviesSequence.onNext(movie)
                self.moviesView?.reload()
            }            
        }
    }
}

protocol MoviesViewPresenter: class {
    func attachView(_ view: MoviesView?)
    func fetchMovies(page: Int)
    func searchForMovies(withKeyword keyword: String, page: Int)
}
