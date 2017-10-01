//
//  AboutTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/27/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

enum TitleAndDescriptionTableViewCellType {
    case aboutTrainer
    case general
}

class TitleAndDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageAndLocationStackView: UIStackView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var unloggedImageView: UIImageView!
    
    //TODO: moregeneric names as this cell is resused on quite a few places. Also we need to refactor cell setup
    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }
    //for now general covers all case except the trainer one
    var type: TitleAndDescriptionTableViewCellType = .general {
        didSet {
            switch type {
            case .aboutTrainer:
                ageAndLocationStackView.isHidden = false
            default:
                ageAndLocationStackView.isHidden = true
            }
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var categoryImage: UIImage? {
        didSet {
            categoryImageView.image = categoryImage
        }
    }
    
    func showImage(shouldShowImage: Bool, image: UIImage? = nil) {
        unloggedImageView.isHidden = !shouldShowImage
        unloggedImageView.image = image
    }
}
