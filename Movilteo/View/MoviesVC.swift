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
    func addMovies(movie: Movie)
    func setMaxPages(to num: Int)
    func setEmpty()
}

final class MoviesVC: UIViewController{
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var pageNumLabel: UILabel!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    private let moviesPresenter = MoviesPresenter(apiService: APIService())
    private var moviesToShow: [Movie] = []
    
    private var currentPageNum: Int = 1
    private var maxPagesNum: Int = 500
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResults: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let screenWidth = UIScreen.main.bounds.width
        
        // For the cell constrains
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 30, right: 15)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        collectionView!.collectionViewLayout = layout
        
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
        
        // Don't hide the navigation bar because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = false
        
        backButtonOutlet.isEnabled = false
        
        moviesPresenter.attachView(self)
    }
    
    // MARK: - Movies data
    
    /// Request the movies of the new page from the presenter and updates page number label text.
    private func getMovies(){
        moviesPresenter.fetchMovies(page: currentPageNum)
        pageNumLabel.text = String(currentPageNum)
    }
    
    // MARK: - Buttons methods
    
    /// Updates the buttons states (enabled/disabled) depends on the current page number.
    private func resetButtons(button: CustomButton){
        if button == CustomButton.back {
            if currentPageNum == 2{
                backButtonOutlet.isEnabled = false
            }
            if nextButtonOutlet.isEnabled == false{
                nextButtonOutlet.isEnabled = true
            }
        } else {
            if currentPageNum == maxPagesNum {
                nextButtonOutlet.isEnabled = false
            }
            if backButtonOutlet.isEnabled == false{
                backButtonOutlet.isEnabled = true
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        resetButtons(button: CustomButton.back)
        currentPageNum -= 1
        getMovies()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        resetButtons(button: CustomButton.next)
        currentPageNum += 1
        getMovies()
    }
}


extension MoviesVC: MoviesView{
    
    func addMovies(movie: Movie){
        self.moviesToShow.append(movie)
        self.collectionView.reloadData()
        self.collectionView.setContentOffset(.zero, animated: true) // Scroll to top
    }
    
    func setMaxPages(to num: Int){
        self.maxPagesNum = num
    }
    
    func setEmpty(){
        self.moviesToShow.removeAll()
    }
}

extension MoviesVC: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MovieDataVC") as? MovieDataVC
        vc?.movieTitle = moviesToShow[indexPath.row].titleLabelText
        vc?.movieRating = String(moviesToShow[indexPath.row].voteAverage)
        vc?.movieOverview = moviesToShow[indexPath.row].overview
        vc?.movieImageUrl = moviesToShow[indexPath.row].posterURL
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

extension MoviesVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchController.isActive ? searchResults.count : moviesToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieImageCell", for: indexPath as IndexPath) as! MovieCell
        
        let movie = searchController.isActive ?
            searchResults[indexPath.row] : moviesToShow[indexPath.row]
        
        let url = movie.posterURL
        if let data = try? Data(contentsOf: url) as Data?{
            cell.movieImageView.image = UIImage(data: data)
        }
        
        return cell
    }
}

extension MoviesVC: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        // If the search bar contains text, filter our data with the string
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            // Reload the table view with the search result data.
            collectionView.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        // Update the searchResults array with matches
        // in our movies based on the title value.
        searchResults = moviesToShow.filter({ movie -> Bool in
            let match = movie.titleLabelText.range(of: searchText, options: .caseInsensitive)
            // Return the results if the range contains a match.
            return match != nil
        })
    }
}

private enum CustomButton{
    case next,
         back
}
