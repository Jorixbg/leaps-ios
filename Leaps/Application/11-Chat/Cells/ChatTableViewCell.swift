//
//  ChatTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 28/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
    }

    func setup(chat: Chat) {
        nameLabel.text = chat.other.name
        lastMessageLabel.text = chat.lastMessage?.message
        timeLabel.text = DateManager.shared.relativeDateStringForDate(date: chat.lastMessage?.time)
        if let url = URL(string: "\(Constants.baseURL)\(chat.other.image)") {
            profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
        }
    }
}
