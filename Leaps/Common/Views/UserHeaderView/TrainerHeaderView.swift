//
//  TrainerHeaderView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage
import Cosmos

class TrainerHeaderView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var userNamesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numberOfEventsLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var numberOfFollowingLabel: UILabel!
    @IBOutlet weak var maskImageView: UIImageView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var followButton: UIButton!
    private let scrollViewHeightToSuperviewHeightCoef: CGFloat = 0.6
    
    var viewModel: TrainerViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            userNamesLabel.text = viewModel.fullname
            usernameLabel.text = viewModel.username
            numberOfEventsLabel.text = viewModel.numberOfEventsHosting
            
            let profileImageFullURL = "\(Constants.baseURL)\(viewModel.trainerImageURLString)"
            URL(string: profileImageFullURL).flatMap {
                
                profileImageView.sd_setImage(with: $0, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
            }
            
            followButton.isSelected = viewModel.isUserFollowed()
            
            let rating = viewModel.user.value?.rating ?? 0
            let reviews = viewModel.user.value?.reviews ?? 0
            ratingView.setup(rating: rating, reviews: reviews, colors: .darkBlue)
            
            guard let images = viewModel.user.value?.images, images.count > 0 else {
                scrollView.backgroundColor = .leapsOnboardingBlue
                pageControl.numberOfPages = 0
                maskImageView.isHidden = false
                return
            }
            
            pageControl.isHidden = images.count <= 1
            pageControl.numberOfPages = images.count
            pageControl.currentPage = 0
            
            for (index, image) in images.enumerated() {
                
                let x = CGFloat(index) * scrollView.frame.width
                let y: CGFloat = 0
                let width = scrollView.frame.width
                //Workaround as the height is equal to the view's height and otherwise I need to use viewDidAppear in the superclass
                let height = self.frame.height*scrollViewHeightToSuperviewHeightCoef
                let frame = CGRect(x: x, y: y, width: width, height: height)
                let imageView = UIImageView(frame: frame
                )
                let fullURL = "\(Constants.baseURL)\(image.url)"
                guard let imageURL = URL(string: fullURL) else {
                    continue
                }
                
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "event-placeholder"), options: []) { (image, error, cacheType, url) in
                    if let _ = image {
                        self.maskImageView.isHidden = false
                    } else {
                        self.maskImageView.isHidden = true
                    }
                }
                
                scrollView.addSubview(imageView)
            }
            
            let scrollViewWidth = scrollView.frame.width * CGFloat(images.count)
            //Workaround as the height is equal to the view's height and otherwise I need to use viewDidAppear in the superclass
            let scrollViewHeight =  self.frame.height*scrollViewHeightToSuperviewHeightCoef
            scrollView.contentSize = CGSize(width: scrollViewWidth, height: scrollViewHeight)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .leapsPageControlLightBlue
    }
    
    func initialSetup() {
        scrollView.isPagingEnabled = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        pageControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }

    func sizeScrollView() {
        for (index, subview) in scrollView.subviews.enumerated() {
            
            let x = CGFloat(index) * scrollView.frame.width
            let y: CGFloat = 0
            let width = scrollView.frame.width
            let height = self.frame.height
            let frame = CGRect(x: x, y: y, width: width, height: height)
            subview.frame = frame
        }
    }
    
    func setupDelegation(scrollViewDelegate: UIScrollViewDelegate) {
        scrollView.delegate = scrollViewDelegate
    }
    
    func scrolled(scrollView: UIScrollView) {
        guard scrollView == self.scrollView else {
            return
        }
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func didSelectedFollow() {
        viewModel?.followAction(completion: nil)
    }
    
}
