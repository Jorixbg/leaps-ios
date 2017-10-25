//
//  FollowersTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 15/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class FollowersTableViewCell: UITableViewCell {

    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    private let overlappingStep = 15
    private var lastAddedImageIndex: Int = 0
    private var followersNamesText: String = ""
    
    var followers: [Attendee] = [] {
        didSet {
            lastAddedImageIndex = 0
            
            imageContainerView.subviews.forEach({ $0.removeFromSuperview() })
            
            let maxShows = followers.count > 4 ? 4: followers.count
            let firstFour = followers[0..<maxShows]
            followersNamesText = "Followed by \(firstFour.map({$0.userName}).joined(separator: ", "))"
            if followers.count > 4 {
                followersNamesText = "\(followersNamesText) + \(followers.count-4) other people."
            }
            followersLabel.text = followersNamesText
            
            for follower in followers {

                guard let imageURLAsString = follower.userImageURL,
                    let imageURL = URL(string: "\(Constants.baseURL)\(imageURLAsString)") else {
                        continue
                }
                if lastAddedImageIndex > 3 {
                    break
                }
                
                let nextX = CGFloat(lastAddedImageIndex)*imageContainerView.frame.height - CGFloat(lastAddedImageIndex*overlappingStep)
                lastAddedImageIndex += 1
                let rect = CGRect(x: nextX,
                                  y: 0,
                                  width: imageContainerView.frame.height,
                                  height: imageContainerView.frame.height)
                
                let imageView = UIImageView(frame: rect)
                imageView.backgroundColor = .clear
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.contentMode = .scaleAspectFill
                imageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
                
                imageContainerView.addSubview(imageView)
            }
        }
    }
}
