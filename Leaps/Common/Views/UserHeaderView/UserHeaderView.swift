//
//  UserHeaderView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/25/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class UserHeaderView: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numberEventsLabel: UILabel!
    @IBOutlet weak var numberEventsView: UIView!
    @IBOutlet weak var numberFollowersLabel: UILabel!
    @IBOutlet weak var numberFollowersView: UIView!
    @IBOutlet weak var numberFollowingLabel: UILabel!
    @IBOutlet weak var numberFollowingView: UIView!
    @IBOutlet weak var followButtonView: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    var viewModel: UserViewModel? {
        didSet {
            guard let viewModel = viewModel,
                  let user = viewModel.user.value else {
                return
            }
            
            nameLabel.text = viewModel.userFullName
            usernameLabel.text = "@\(viewModel.username)"
            
            numberEventsLabel.text = String(user.attendedEvents)
            numberEventsView.alpha = user.attendedEvents > 0 ? 1: 0.5
            numberFollowersLabel.text = String(user.followersCount)
            numberFollowersView.alpha = user.followersCount > 0 ? 1 : 0.5
            numberFollowingLabel.text = String(user.followingCount)
            numberFollowingView.alpha = user.followingCount > 0 ? 1 : 0.5
            
            followButton.isSelected = viewModel.isUserFollowed()
            followButtonView.isHidden = viewModel.isLoggedUser()
            
            guard let imageURLString = user.imageURL,
                  let url = URL(string: "\(Constants.baseURL)\(imageURLString)") else {
                return
            }
            
            profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
        }
    }
    
    @IBAction func followAction() {
        viewModel?.followAction()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        initialSetup()
    }
    
    func initialSetup() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
}
