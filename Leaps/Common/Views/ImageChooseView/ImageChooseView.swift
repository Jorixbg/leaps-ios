//
//  ImageChooseView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/19/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class ImageChooseView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainImageButton: UIButton!
    @IBOutlet weak var mainImageImageView: UIImageView!
    
    var isMainImage = false 
    var isTrainerImage = false
    
    var onDeletePressed: ((ImageChooseView, UIImage?) -> Void)?
    var onImagePressed: ((ImageChooseView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        imageView.layer.cornerRadius = Constants.General.standradCornerRadius
        imageButton.layer.cornerRadius = Constants.General.standradCornerRadius
//        mainImageImageView.layer.cornerRadius = Constants.General.standradCornerRadius
        layoutIfNeeded()
        mainImageImageView.layer.cornerRadius = mainImageImageView.frame.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        imageView.layer.cornerRadius = Constants.General.standradCornerRadius
        imageButton.layer.cornerRadius = Constants.General.standradCornerRadius
//        mainImageImageView.layer.cornerRadius = Constants.General.standradCornerRadius
        layoutIfNeeded()
        mainImageImageView.layer.cornerRadius = mainImageImageView.frame.height / 2
    }
    
    @IBAction func didPressImageButton(_ sender: Any) {
        onImagePressed?(self)
        print("didPressImageButton")
    }
    
    @IBAction func didPressDeleteButton(_ sender: Any) {
        let image = imageView.image
        onDeletePressed?(self, image)
        removeImage()
        print("didPressDeleteButton")
    }
    
    private func setImageSetup() {
        imageButton.isHidden = true
        if !isMainImage {
            deleteButton.isHidden = false
            imageView.isHidden = false
        } else {
            mainImageButton.isHidden = false
            mainImageImageView.isHidden = false
        }
    }
    
    func setImage(image: UIImage) {
        if isMainImage {
            if !isTrainerImage {
                layoutIfNeeded()
                mainImageImageView.layer.cornerRadius = Constants.General.standradCornerRadius
            }
            mainImageImageView.image = image
        } else {
            imageView.image = image
        }
        self.setImageSetup()
    }
    
    func setImage(imageURL: String) {
        guard let imageURL = URL(string: imageURL) else {
            return
        }
        
        if isMainImage {
            if !isTrainerImage {
                layoutIfNeeded()
                mainImageImageView.layer.cornerRadius = Constants.General.standradCornerRadius
            }
            mainImageImageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"), options: [], completed:{ [weak self] (image, error, cache, url) in
                self?.setImageSetup()
            })
        } else {
            imageView.sd_setImage(with: imageURL) { [weak self] (image, error, cache, url) in
                self?.setImageSetup()
            }
        }
    }
    
    func setImage(image: Image) {
        let fullURL = "\(Constants.baseURL)\(image.url)"
        setImage(imageURL: fullURL)
    }
    
    func removeImage() {
        guard !isMainImage else {
            return
        }
        deleteButton.isHidden = true
        imageButton.isHidden = false
        imageView.image = nil
        imageView.isHidden = true
    }
}
