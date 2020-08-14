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
    
    var movieImageUrl = URL(string: "")
    var movieTitle = ""
    var movieRating = ""
    var movieOverview = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTitleLabel.text = movieTitle
        movieRatingLabel.text = movieRating
        movieOverviewLabel.text = movieOverview
        
        
        if let data = try? Data(contentsOf: movieImageUrl!) as Data?{
            movieImage.image = UIImage(data: data)
        }
    }
    
}
