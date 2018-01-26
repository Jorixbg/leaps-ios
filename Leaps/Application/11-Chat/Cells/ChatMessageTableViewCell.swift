//
//  ChatMessageTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 2/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeBottomLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleLeftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 6
        bubbleView.layer.shadowColor = UIColor(red:0.69, green:0.85, blue:0.76, alpha:0.36).cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
    }

    func setup(message: ChatMessage, user: ChatUser) {
        if user.isCurrent {
            bubbleView.backgroundColor = .leapsOnboardingBlue
            messageLabel.textColor = .white
            timeLabel.textColor = .white
            timeBottomLabel.textColor = .white
            profileImageView.isHidden = true
            
            bubbleRightConstraint.priority = .defaultHigh
            bubbleLeftConstraint.priority = .defaultLow
        }
        else {
            bubbleView.backgroundColor = .leapsChatGrey
            messageLabel.textColor = .leapsOnboardingBlue
            timeLabel.textColor = .leapsOnboardingBlue
            timeBottomLabel.textColor = .leapsOnboardingBlue
            profileImageView.isHidden = false
            if let url = URL(string: "\(Constants.baseURL)\(user.image)") {
                profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
            }
            
            bubbleLeftConstraint.priority = UILayoutPriority.defaultHigh
            bubbleRightConstraint.priority = UILayoutPriority.defaultLow
        }
        
        timeLabel.text = DateManager.shared.timeFormatter.string(from: message.time)
        timeBottomLabel.text = DateManager.shared.timeFormatter.string(from: message.time)
        messageLabel.text = message.message
        messageLabel.sizeToFit()
        
        timeLabel.isHidden = messageLabel.frame.height > 20
        timeBottomLabel.isHidden = messageLabel.frame.height < 20
    }
}
