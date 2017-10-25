//
//  ImageSelectionTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

enum ImageSelectionCellType {
    case editProfile
    case createEvent
}

//TODO: Needs to be extracted to common as it is used in the edit profile
class ImageSelectionTableViewCell: ErrorCreateEventTableViewCell {
    
    @IBOutlet weak var firstImageChooseView: ImageChooseView!
    @IBOutlet weak var secondChooseView: ImageChooseView!
    @IBOutlet weak var thirdChooseView: ImageChooseView!
    @IBOutlet weak var fourthChooseView: ImageChooseView!
    @IBOutlet weak var fifthChooseView: ImageChooseView!
    @IBOutlet weak var sixthChooseView: ImageChooseView!
    @IBOutlet var allImageViews: [ImageChooseView]!
    fileprivate var currentAdditionalImages: [Image] = []
    
    fileprivate var selectedImageIndex: Int?
    
    //edit profile required to avoid resetting pictures on tableview scroll
    fileprivate var hasDoneInitialSetting = false
    
    fileprivate var type: ImageSelectionCellType? {
        didSet {
            guard let type = type else {
                return
            }
            firstImageChooseView.isMainImage = true
            switch type {
            case .editProfile:
                firstImageChooseView.isTrainerImage = true
            default:
                break
            }
        }
    }
    
    func setup(type: ImageSelectionCellType) {
        self.type = type
    }
    
    //still only a string.
    func setup(type: ImageSelectionCellType, mainImage: String, images: [Image]?) {
        self.type = type
        if let images = images {
            self.currentAdditionalImages = images
        }
        //woaround. if there is enough time it will be fixed.
        if type == .editProfile && hasDoneInitialSetting {
            return
        }
        
        let fullURL = "\(Constants.baseURL)\(mainImage)"
        allImageViews.first?.setImage(imageURL: fullURL)
        guard let images = images else {
            return
        }
        for (index, image) in images.enumerated() {
            //as the first image is set separately
            guard index < allImageViews.count - 1 else {
                return
            }
            
            allImageViews[index+1].setImage(image: image)
        }
        
        hasDoneInitialSetting = true
    }
    
    var onImageSelected: (() -> Void)? {
        didSet {
            for view in allImageViews {
                view.onImagePressed = { [weak self] view in
                    self?.selectedImageIndex = self?.allImageViews.index(of: view)
                    self?.onImageSelected?()
                }
            }
        }
    }
    
    var onImageSet: ((UplodableImage) -> Void)?
    
    var onDelteImage: ((Int, UplodableImage) -> Void)? {
        didSet {
            _ = allImageViews.map {
                $0.onDeletePressed = { [weak self] view, image in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.selectedImageIndex = strongSelf.allImageViews.index(of: view)
                    guard let image = image,
                            let imageAsData = UIImageJPEGRepresentation(image, Constants.CreateEvent.uploadedPictureCompression),
                            let index = strongSelf.selectedImageIndex,
                            let type = strongSelf.type else {
                        return
                    }
                    
                    let imageType: UplodableImageType
                    switch  type {
                    case .editProfile:
                        imageType = index == 0 ? UplodableImageType.userMainImage : UplodableImageType.userAdditionalImage
                    case .createEvent:
                        imageType = index == 0 ? UplodableImageType.eventMainImage : UplodableImageType.eventAdditionalImage
                    }
                    
                    //image is used to remove from updating list. ID is used to know which ids should be removed.
                    let uploadableImage = UplodableImage(imageData: imageAsData, type: imageType)
                    
                    guard index < strongSelf.currentAdditionalImages.count else {
                        return
                    }
                    
                    let imageID = strongSelf.currentAdditionalImages[index - 1]
                    self?.onDelteImage?(imageID.id, uploadableImage)
                }
            }
        }
    }
}

extension ImageSelectionTableViewCell: ImageSettable {
    func unsetImage() {
        
    }

    func setImage(image: UIImage) {
        guard let index = selectedImageIndex else {
            return
        }
        
        errorLabel.isHidden = true
        allImageViews[index].setImage(image: image)
        
        guard let imageAsData = UIImageJPEGRepresentation(image, Constants.CreateEvent.uploadedPictureCompression) else {
            return
        }
        
        guard let type = type else {
            return
        }
        
        let imageType: UplodableImageType
        
        switch  type {
        case .editProfile:
            imageType = index == 0 ? UplodableImageType.userMainImage : UplodableImageType.userAdditionalImage
        case .createEvent:
            imageType = index == 0 ? UplodableImageType.eventMainImage : UplodableImageType.eventAdditionalImage
        }
        
        let image = UplodableImage(imageData: imageAsData, type: imageType)
        onImageSet?(image)
    }
}
