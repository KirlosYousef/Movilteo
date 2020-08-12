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
    func getMovies(page: Int)
}

class MoviesPresenter: MoviesViewPresenter{
    
    fileprivate let apiService: APIService
    weak fileprivate var moviesView: MoviesView?
    let moviesSequence = PublishSubject<Displayable>()
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func attachView(_ attach: Bool, view: MoviesView?) {
        if attach {
            moviesView = nil
        } else {
            if let view = view { moviesView = view }
        }
    }
    
    func getMovies(page: Int) {
        APIService.shared.fetchMovies(page: page) { moviesRes in
            for movie in moviesRes.all{
                self.moviesSequence.onNext(movie)
            }
        }
    }
}
