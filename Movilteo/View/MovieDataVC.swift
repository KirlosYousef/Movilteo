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
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
