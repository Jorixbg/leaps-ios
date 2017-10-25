//
//  EventDetailsThanksViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Social

class EventDetailsThanksViewController: UIViewController {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var attendButton: UIButton!
    
    fileprivate var viewModel: EventViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let event = viewModel?.event.value else {
            dismiss(animated: false, completion: nil)
            return
        }
        let fullURL = "\(Constants.baseURL)\(event.eventImageURL ?? "")"
        if  let url = URL(string: fullURL) {
            eventImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "event-placeholder"))
        }
        titleLabel.text = event.title
        
        var dateString = ""
        let formatterDate = DateManager.shared.thanksPopupFormatter
        let formatterTime = DateManager.shared.timeFormatter
        dateString = "\(formatterDate.string(from: event.date)),\n\(formatterTime.string(from: event.timeFrom))"
        dateLabel.text = dateString
        
        attendButton.layer.cornerRadius = Constants.General.standradCornerRadius
    }

    @IBAction func didSelectClose(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func didSelectAttend(_ sender: Any) {
        guard let event = viewModel?.event.value,
              let navController = presentingViewController as? UINavigationController else {
            return
        }
        
        dismiss(animated: false) {
            let storyboard = UIStoryboard(name: .common, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            guard let vc = factory.createEventDetailsViewController(event: event) else {
                return
            }
            
            navController.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func shareOther(_ sender: Any) {
        guard let title = viewModel?.event.value.title,
              let image = eventImageView.image else {
            return
        }
        
        // set up activity view controller
        let imageToShare = [title, image] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func shareTwitter(_ sender: Any) {
        share(by: SLServiceTypeTwitter)
    }
    
    @IBAction func shareFacebook(_ sender: Any) {
        share(by: SLServiceTypeFacebook)
    }
    
    func share(by type:String){
        if let vc = SLComposeViewController(forServiceType:type) {
            vc.add(self.eventImageView.image)
            //vc.add(URL(string: viewModel?.event.value.url))
            vc.setInitialText(self.viewModel?.event.value.title)
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension EventDetailsThanksViewController: Injectable {
    func inject(_ viewModel: EventViewModel) {
        self.viewModel = viewModel
    }
}
