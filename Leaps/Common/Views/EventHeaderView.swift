//
//  EventHeaderView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/24/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import SDWebImage
import Foundation
import UIKit

class EventHeaderView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var maskImageView: UIImageView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var followButton: UIButton!
    
    var viewModel: EventViewModel? {
        didSet {
            nameLabel.text = viewModel?.event.value.title.uppercased()
            pageControl.numberOfPages = viewModel?.event.value.images.count ?? 0
            guard var images = viewModel?.event.value.images else {
                return
            }
            guard let eventImageUrl = viewModel?.event.value.eventImageURL else {
                return
            }
            images.insert(Image(id: 0, url: eventImageUrl), at: 0)
            if images.count < 1 {
                scrollView.backgroundColor = .leapsOnboardingBlue
            }
            
            followButton.isSelected = viewModel?.isUserFollow ?? false

            pageControl.isHidden = images.count <= 1
            pageControl.numberOfPages = images.count
            pageControl.currentPage = 0
            for (index, image) in images.enumerated() {
                
                let x = CGFloat(index) * scrollView.frame.width
                let y: CGFloat = 0
                let width = scrollView.frame.width
                //Workaround as the height is equal to the view's height and otherwise I need to use viewDidAppear in the superclass
                let height = self.frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                let imageView = UIImageView(frame: frame)
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
            
            ratingView.isHidden = !(viewModel?.isInPast ?? false)
            if  let rating = viewModel?.event.value.rating,
                let reviews = viewModel?.event.value.reviews {
                //ratingView.isHidden = false
                ratingView.setup(rating: rating, reviews: reviews, colors: .blue)
            }
            else {
                ratingView.setup(rating: 3.8, reviews: 111, colors: .blue)
                //ratingView.isHidden = true
            }
            //ratingView.onTouchBlock = showRateViewController
            ratingView.onTouchBlock = showReviewsViewController
            
            let scrollViewWidth = scrollView.frame.width * CGFloat(images.count)
            //Workaround as the height is equal to the view's height and otherwise I need to use viewDidAppear in the superclass
            let scrollViewHeight = self.frame.height
            scrollView.contentSize = CGSize(width: scrollViewWidth, height: scrollViewHeight)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .leapsPageControlLightBlue
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        initalSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        initalSetup()
    }
    
    private func initalSetup() {
        scrollView.isPagingEnabled = true
        pageControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
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
    
    func showRateViewController() {
        guard let event = self.viewModel?.event.value else {
            return
        }
        
        let storyboard = UIStoryboard(name: .common, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsRateViewController(event: event) else {
            return
        }
        
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didSelectShare() {
        guard let event = viewModel?.event.value else {
            return
        }
        let image = (scrollView.subviews.first as? UIImageView)?.image ?? nil
        let share = StoryboardViewControllerFactory.createShareViewController(event: event, image: image)
        self.parentViewController?.present(share, animated: true, completion: nil)
        
    }
    @IBAction func didSelectFollow() {
        if UserManager.shared.isLoggedIn {
            viewModel?.followEvent(completion: { [weak self] (error) in
                self?.followButton.isSelected = self?.viewModel?.isUserFollow ?? false
            })
        }
        else {
            if let parent = self.parentViewController as? EventDetailsViewController {
                parent.presentLogin()
            }
        }
    }
    
    func showReviewsViewController() {
        guard let event = self.viewModel?.event.value else {
            return
        }
        
        let storyboard = UIStoryboard(name: .eventDetails, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsReviewsViewController(event: event) else {
            return
        }
        
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
