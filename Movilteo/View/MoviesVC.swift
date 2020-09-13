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
    func addGenres(genre: Genre)
    func addMovies(movie: Movie)
    func addSearchedMovies(movie: Movie)
    func setCurrentPage(to num: Int)
    func setMaxPages(to num: Int)
    func setEmpty()
    func reload()
}

final class MoviesVC: UIViewController{
    
    @IBOutlet var moviesCollectionView: UICollectionView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var pageNumLabel: UILabel!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let moviesPresenter = MoviesPresenter()
    private var moviesToShow: [Movie] = []
    private var genresToShow: [Genre] = []
    
    private var currentPageNum: Int = 1
    private var maxPagesNum: Int = 500
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResults: [Movie] = []
    private var searchText: String = ""
    private var isSearching: Bool = false
    
    let screenWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        genreCollectionView.delegate = self
        genreCollectionView.dataSource = self
        searchController.searchBar.delegate = self
        
        self.genreCollectionView.isPagingEnabled = true
        self.definesPresentationContext = true
        moviesPresenter.fetchGenres()
        setupSearchController()
        setupButtons()
        
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
    
    private func setupButtons(){
        backButtonOutlet.isEnabled = false
        backButtonOutlet.setTitleColor(.gray, for: .disabled)
        nextButtonOutlet.setTitleColor(.gray, for: .disabled)
    }
    
    /// Updates the buttons states (enabled/disabled) depends on the current page number.
    private func resetButtons(button: CustomButton){
        if button == CustomButton.back {
            
            if currentPageNum == 2{
                backButtonOutlet.isEnabled = false
            }
            
            if !nextButtonOutlet.isEnabled{
                nextButtonOutlet.isEnabled = true
            }
            
        } else {
            
            if currentPageNum == maxPagesNum - 1 {
                nextButtonOutlet.isEnabled = false
                backButtonOutlet.titleLabel?.textColor = .black
            }
            
            if !backButtonOutlet.isEnabled{
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
        if collectionView == self.moviesCollectionView{
            let vc = storyboard?.instantiateViewController(withIdentifier: "MovieDataVC") as? MovieDataVC
            vc?.movie = moviesToShow[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        } else{
            print("\(genresToShow[indexPath.row].name!)")
        }
    }
    
}

extension MoviesVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == moviesCollectionView{
            return searchResults.isEmpty ? moviesToShow.count : searchResults.count
        } else {
            return genresToShow.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == moviesCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieImageCell", for: indexPath as IndexPath) as! MovieCell
            
            let movie = searchResults.isEmpty ? moviesToShow[indexPath.row] : searchResults[indexPath.row]
            
            cell.movieImageView.image = ImagesService.shared.getSavedImage(withID: movie.id, posterURL: movie.posterURL)
            
            cell.movieImageView.layer.cornerRadius = 10
            
            // border
            cell.movieImageView.layer.borderWidth = 2
            cell.movieImageView.layer.borderColor = UIColor.random.cgColor
            
            activityIndicator.stopAnimating()
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreTitleCell", for: indexPath as IndexPath) as! GenreCell
            
            let genre = genresToShow[indexPath.row]
            
            cell.genreTitle.text = genre.name
            cell.titleBackground.layer.cornerRadius = 5
            
            return cell
        }
    }
}

extension MoviesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == moviesCollectionView{
            return CGSize(width: screenWidth/3, height: screenWidth/2)
        } else {
            return CGSize(width: screenWidth/3, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == moviesCollectionView{
            return UIEdgeInsets(top: 20, left: 15, bottom: 30, right: 15)
        } else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

// MARK: - UISearchBar method

extension MoviesVC: UISearchBarDelegate{
    
    private func setupSearchController(){
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
    }
    
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
        moviesCollectionView.setContentOffset(.zero, animated: true) // Scroll to top
    }
    
    func addGenres(genre: Genre){
        genresToShow.append(genre)
        reload()
    }
    
    func addSearchedMovies(movie: Movie){
        searchResults.append(movie)
        moviesCollectionView.setContentOffset(.zero, animated: true) // Scroll to top
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
        moviesCollectionView.reloadData()
        genreCollectionView.reloadData()
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
