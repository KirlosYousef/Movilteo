//
//  MovieDataVC.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 13..
//

import UIKit

/// Controls the Movie details view.
class MovieDataVC: UIViewController {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var ratingBackground: UIView!
    @IBOutlet weak var movieGenresCollectionView: UICollectionView!
    
    var movie: Movie?
    var genres: [Genre]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieGenresCollectionView.delegate = self
        movieGenresCollectionView.dataSource = self
        
        if movie != nil {
            movieTitleLabel.text = movie!.titleLabelText
            ratingBackground.layer.cornerRadius = 20
            movieRatingLabel.text = "⭐️ " + String(movie!.voteAverage) + "/10"
            movieOverviewLabel.text = movie!.overview
            movieImage.image = ImagesService.shared.getSavedImage(withID: movie!.id, posterURL: movie!.posterURL)
        } else{
            movieTitleLabel.text = "An error occurred, please check your internet."
        }
    }
}

extension MovieDataVC: UICollectionViewDelegate{
    
}

extension MovieDataVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (movie?.genreIds == nil) ? 0 : (movie?.genreIds.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGenreCell", for: indexPath as IndexPath) as! GenreCell
        
        for genreInd in 0...genres!.count{
            if movie?.genreIds != nil{
                if movie?.genreIds[indexPath.row] == genres![genreInd].id{
                    cell.genreTitle.text = genres![genreInd].name
                    break
                }
            }
        }
        
        cell.titleBackground.layer.cornerRadius = 5
        
        return cell
    }
}

extension MovieDataVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: screenWidth/3, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
