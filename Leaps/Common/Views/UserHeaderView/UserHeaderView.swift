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
    
    var viewModel: UserViewModel? {
        didSet {
            nameLabel.text = viewModel?.userFullName
            usernameLabel.text = viewModel?.user.value.username
            guard let viewModel = viewModel else {
                return
            }
            numberEventsLabel.text = String(viewModel.user.value.attendedEvents)
            let imageURLString = viewModel.user.value.imageURL ?? ""
            guard let url = URL(string: imageURLString) else {
                return
            }
            
            profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
        }
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
