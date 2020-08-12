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
    func addMovies(movie: Displayable)
    func setMaxPages(to num: Int)
    func setEmpty()
}

final class MoviesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var pageNumLabel: UILabel!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    private let moviesPresenter = MoviesPresenter(apiService: APIService())
    private let reuseIdentifier = "MovieImageCell"
    private var moviesToShow: [Displayable] = []
    private var currentPageNum: Int = 1
    private var maxPagesNum: Int = 500
    
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
        
        backButtonOutlet.isEnabled = false
        
        moviesPresenter.attachView(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesToShow.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MovieCell
        
        let url = self.moviesToShow[indexPath.row].posterURL
        
        if let data = try? Data(contentsOf: url) as Data?{
            cell.movieImageView.image = UIImage(data: data)
        }
        
        return cell
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
    
    private func getMovies(){
        moviesPresenter.fetchMovies(page: currentPageNum)
        pageNumLabel.text = String(currentPageNum)
    }
}


extension MoviesVC: MoviesView{
    func addMovies(movie: Displayable){
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

private enum CustomButton{
    case next,
         back
}
