//
//  ImageAndNameTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class ImageAndNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNamesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var onEditProfilePressed: (() -> Void)?
    
    func configure(imageURLString: String, userNames: String, username: String, onEditProfilePressed: (() -> Void)? = nil) {
        self.onEditProfilePressed = onEditProfilePressed
        userNamesLabel.text = userNames
        usernameLabel.text = username
        let imageFullURL = "\(Constants.baseURL)\(imageURLString)"
        guard let imageURL = URL(string: imageFullURL) else {
            return
        }
        
        profileImageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    @IBAction func didPressedEditProfile(_ sender: Any) {
        onEditProfilePressed?()
    }
}
