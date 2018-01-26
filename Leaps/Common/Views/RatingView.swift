//
//  RatingView.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Cosmos

class RatingView: UIView {

    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!

    var onTouchBlock:()->Void = {}
    
    enum StarColors {
        case white
        case blue
        case darkBlue
    }
    
    func setup(rating:Double, reviews:Int, colors:StarColors = .white) {
        cosmosView.rating = rating
        ratingLabel.text = String(format: "%.1f", rating)
        ratingLabel.layer.cornerRadius = 2
        ratingLabel.layer.masksToBounds = true
        reviewsLabel.text = "(\(reviews) reviews)"
        
        switch colors {
        case .white:
            cosmosView.settings.filledColor = .white
            cosmosView.settings.emptyColor = UIColor(red:0.33, green:0.30, blue:0.28, alpha:1.0)
            break
        case .blue:
            cosmosView.settings.filledColor = UIColor(red:0.16, green:0.7, blue:0.91, alpha:1)
            cosmosView.settings.emptyColor = UIColor(red:0.17, green:0.42, blue:0.51, alpha:1)
            break
        case .darkBlue:
            cosmosView.settings.filledColor = .leapsOnboardingBlue
            cosmosView.settings.emptyColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchBlock()
    }
    
    
}


