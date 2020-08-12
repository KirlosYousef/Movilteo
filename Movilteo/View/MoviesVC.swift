//
//  MoviesCollectionVC.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import UIKit
import RxSwift

protocol MoviesView: class {
    func onMoviesRetrieval(movies: Movies)
    func setEmpty()
}

final class MoviesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet var collectionView: UICollectionView!
    private let moviesPresenter = MoviesPresenter(apiService: APIService())
    private let reuseIdentifier = "MovieCell"
    private let bag = DisposeBag()
    private var items: [Displayable] = []
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        screenWidth = UIScreen.main.bounds.width
        screenHeight = UIScreen.main.bounds.height
        
        // For the cell constrains
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)
        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        
        collectionView!.collectionViewLayout = layout
        
        
        moviesPresenter.attachView(true, view: self)
        
        let _ = moviesPresenter.moviesSequence.subscribe(onNext: {
            self.items.append($0)
            self.collectionView.reloadData()
        }).disposed(by: bag)
        
        moviesPresenter.getMovies(page: 1)  // TO DO
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDataCell", for: indexPath as IndexPath) as! MovieCell
        
        let url = self.items[indexPath.row].posterURL
        let data = try? Data(contentsOf: url)
        
        cell.movieImageView.image = UIImage(data: data!)
        
        return cell
    }
    
}

// TO DO
extension MoviesVC: MoviesView{
    func onMoviesRetrieval(movies: Movies) {
        self.items = movies.all
        for movie in movies.all{
            print(movie.titleLabelText)
        }
    }
    
    func setEmpty(){
        self.items.removeAll()
    }
}
