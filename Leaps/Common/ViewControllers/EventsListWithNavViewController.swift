//
//  EventsListWithNavViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/25/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EventsListWithNavViewController: UIViewController {
    typealias T = ActivitiesViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var viewModel: ActivitiesViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.register(ActivityTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.Activities.bottomInset, right: 0)
        setup(navigationController: navigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //the below code should be extracted to a parent view controller if there is enough time. It is used in edit profile, create event etc.
        //show navbar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setup(navigationController: UINavigationController?) {
        
        //back button
        let buttonSelector = #selector(self.didPressCancel)
        let cancelNavButton = UIButton(type: .custom)
        cancelNavButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        cancelNavButton.addTarget(self, action: buttonSelector, for: .touchUpInside)
        cancelNavButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cancelNavButton.imageEdgeInsets = UIEdgeInsetsMake(0, -11, 0, 0)
        cancelNavButton.tintColor = .leapsOnboardingBlue
        cancelNavButton.contentHorizontalAlignment = .left
        cancelNavButton.contentVerticalAlignment = .center
        let barButton = UIBarButtonItem(customView: cancelNavButton)
        navigationItem.leftBarButtonItem  = barButton
        
        //remove bottom line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //set attributed title
        title = viewModel?.navigationTitle()
        guard let font = UIFont.leapsSFFont(size: 12) else {
            return
        }
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font,
                                                                   NSForegroundColorAttributeName: UIColor.leapsOnboardingBlue]
        
        //remove bottom line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func didPressCancel() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EventsListWithNavViewController: Injectable {
    func inject(_ viewModel: ActivitiesViewModel) {
        self.viewModel = viewModel
    }
}
extension EventsListWithNavViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.eventSearchResults.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfitems(for: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: ActivityTableViewCell.self, for: indexPath) { (cell) in
            guard let event = viewModel?.eventForIndexPath(indexPath: indexPath) else {
                print("failed for \(indexPath)")
                return
            }
            let distanceFromEvent = viewModel?.distance(from: event)
            let eventViewModel = ActivityViewModel(event: event, distanceFromCurrentLocation: distanceFromEvent)
            cell.viewModel = eventViewModel
        }
        
        return cell
    }
}

extension EventsListWithNavViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Activities.activityCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = viewModel?.eventForIndexPath(indexPath: indexPath) else {
            return
        }
        
        let storyboard = UIStoryboard(name: .common, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsViewController(event: event) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
