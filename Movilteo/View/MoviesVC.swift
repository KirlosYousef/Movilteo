//
//  MoviesCollectionVC.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 09..
//

import Foundation
import UIKit

protocol MoviesView: class {
    func getMovies()
    func addMovies(movie: Movie)
    func addSearchedMovies(movie: Movie)
    func setCurrentPage(to num: Int)
    func setMaxPages(to num: Int)
    func setEmpty()
    func reload()
}

final class MoviesVC: UIViewController{
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var pageNumLabel: UILabel!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let moviesPresenter = MoviesPresenter()
    private var moviesToShow: [Movie] = []
    
    private var currentPageNum: Int = 1
    private var maxPagesNum: Int = 500
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResults: [Movie] = []
    private var searchText: String = ""
    private var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchController.searchBar.delegate = self
        let screenWidth = UIScreen.main.bounds.width
        
        /// Cell Constrains
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 30, right: 15)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        collectionView!.collectionViewLayout = layout
        
        self.definesPresentationContext = true
        
        /// Search Controller
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
        
        // Don't hide the navigation bar or view because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        for subView in searchController.searchBar.subviews {
            
            for subViewOne in subView.subviews {
                
                if let textField = subViewOne as? UITextField {
                    
                    subViewOne.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                    
                    //use the code below if you want to change the color of placeholder
                    let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                    textFieldInsideUISearchBarLabel?.textColor = .black
                }
            }
        }
        
        /// Buttons
        backButtonOutlet.isEnabled = false
        backButtonOutlet.setTitleColor(.gray, for: .disabled)
        nextButtonOutlet.setTitleColor(.gray, for: .disabled)
        
        moviesPresenter.attachView(self)
    }
    
    // MARK: - Getting movies methods
    
    /// Request the movies of the new page from the presenter and updates page number label text.
    func getMovies(){
        moviesPresenter.fetchMovies(page: currentPageNum)
    }
    
    /// Request the movies of the new page from the presenter and updates page number label text.
    private func searchMovies(for keyword: String){
        moviesPresenter.searchForMovies(withKeyword: keyword, page: currentPageNum)
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
            if currentPageNum == maxPagesNum - 1 {
                nextButtonOutlet.isEnabled = false
                backButtonOutlet.titleLabel?.textColor = .black
            }
            if backButtonOutlet.isEnabled == false{
                backButtonOutlet.isEnabled = true
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        resetButtons(button: CustomButton.back)
        currentPageNum -= 1
        isSearching ? searchMovies(for: searchText) : getMovies()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        resetButtons(button: CustomButton.next)
        currentPageNum += 1
        isSearching ? searchMovies(for: searchText) : getMovies()
    }
}

// MARK: - UICollectionView methods

extension MoviesVC: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MovieDataVC") as? MovieDataVC
        vc?.movie = moviesToShow[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

extension MoviesVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return searchResults.isEmpty ? moviesToShow.count : searchResults.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieImageCell", for: indexPath as IndexPath) as! MovieCell
        
        let movie = searchResults.isEmpty ? moviesToShow[indexPath.row] : searchResults[indexPath.row]
        
        cell.movieImageView.image = ImagesService.shared.getSavedImage(withID: movie.id, posterURL: movie.posterURL)
        
        // corner radius
        cell.movieImageView.layer.cornerRadius = 10
        
        // border
        cell.movieImageView.layer.borderWidth = 2
        cell.movieImageView.layer.borderColor = UIColor.random.cgColor
        
        activityIndicator.stopAnimating()
        
        return cell
    }
}

// MARK: - UISearchBar method

extension MoviesVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // If the search bar contains text, filter our data with the string
        
        if let searchText = searchController.searchBar.text {
            self.searchText = searchText
            currentPageNum = 1
            isSearching = true
            backButtonOutlet.isEnabled = false
            searchMovies(for: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        currentPageNum = 1
        getMovies()
    }
    
}

// MARK: - Custom

extension MoviesVC: MoviesView{
    
    func addMovies(movie: Movie){
        moviesToShow.append(movie)
        collectionView.setContentOffset(.zero, animated: true) // Scroll to top
    }
    
    func addSearchedMovies(movie: Movie){
        searchResults.append(movie)
        collectionView.setContentOffset(.zero, animated: true) // Scroll to top
    }
    
    func setCurrentPage(to num: Int){
        currentPageNum = num
        pageNumLabel.text = String(currentPageNum)
    }
    
    func setMaxPages(to num: Int){
        maxPagesNum = num
    }
    
    func setEmpty(){
        moviesToShow.removeAll()
        searchResults.removeAll()
        activityIndicator.startAnimating()
        reload()
    }
    
    func reload(){
        collectionView.reloadData()
    }
}

private enum CustomButton{
    case next,
         back
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 0.3)
    }
}
