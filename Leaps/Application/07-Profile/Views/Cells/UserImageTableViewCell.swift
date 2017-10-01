//
//  UserImageTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/23/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class UserImageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    var onPictureChangePressed: (() -> Void)?
    //once picture is set from library we need to keep it showing in the imageview
    fileprivate var hasSetInitialProfilePicture = false

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    //it is a simple string for now
    func setup(imageURLString: String/*image: Image*/, onPictureChangePressed: (() -> Void)? = nil) {
        self.onPictureChangePressed = onPictureChangePressed
        let fullURL = "\(Constants.baseURL)\(imageURLString)"
        guard let iamgeURL = URL(string: fullURL), !hasSetInitialProfilePicture else {
            return
        }

        profileImageView.sd_setImage(with: iamgeURL, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"), options: []) { [weak self] (image, erro, chache, url) in
            self?.hasSetInitialProfilePicture = true
        }
    }
    
    @IBAction func didPressChangePicture(_ sender: Any) {
        onPictureChangePressed?()
    }
    
    var onImageSet: ((UplodableImage) -> Void)?
    
    var onDelteImage: ((UplodableImage) -> Void)?
}

extension UserImageTableViewCell: ImageSettable {
    func setImage(image: UIImage) {
        profileImageView.image = image
        
        
        guard let imageAsData = UIImageJPEGRepresentation(image, Constants.CreateEvent.uploadedPictureCompression) else {
            return
        }
        
        let imageType = UplodableImageType.userMainImage
        
        let image = UplodableImage(imageData: imageAsData, type: imageType)
        onImageSet?(image)
    }
    
    func unsetImage() {
        guard let image = profileImageView.image else {
            return
        }
        
        guard let imageAsData = UIImageJPEGRepresentation(image, Constants.CreateEvent.uploadedPictureCompression) else {
            return
        }

        profileImageView.image = #imageLiteral(resourceName: "profile-placeholder")
        
        let imageType = UplodableImageType.userMainImage
        
        let uplodableImage = UplodableImage(imageData: imageAsData, type: imageType)
        onDelteImage?(uplodableImage)
    }
}
