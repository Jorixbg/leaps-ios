//
//  TrainerImageAndNameTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/31/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class TrainerImageAndNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trainerProfileImageView: UIImageView!
    @IBOutlet weak var trainerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        trainerProfileImageView.layer.cornerRadius = trainerProfileImageView.frame.width / 2
    }
    
    func setup(imageRelativePath: String?, traierName: String) {
        trainerNameLabel.text = traierName
        
        guard let imageRelativePath = imageRelativePath else {
            trainerProfileImageView.image = #imageLiteral(resourceName: "profile-placeholder")
            return
        }
        
        let fullURL = "\(Constants.baseURL)\(imageRelativePath)"
        
        guard let url = URL(string: fullURL) else {
            return
        }
        
        trainerProfileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
    }
}
