//
//  UserDetailsViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/25/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
    typealias T = UserViewModel
    
    @IBOutlet weak var headerView: UserHeaderView!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var viewModel: UserViewModel?
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(StandardSettingsTableViewCell.self)
        tableView.register(UserProfileTableViewTableViewCell.self)
        tableView.register(FollowersTableViewCell.self)
        UIApplication.shared.statusBarStyle = .default
        
        viewModel?.user.bindAndFire({ [weak self] (user) in
            self?.tableView.reloadData()
            self?.headerView.viewModel = self?.viewModel
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSettings(_ sender: Any) {
        guard let user = viewModel?.user.value else {
            return
        }
        let storyboard = UIStoryboard(name: .profile, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let profileViewModel = ProfileViewModel(user: user)
        guard let viewController = factory.createEditProvfileViewController(viewModel: profileViewModel) else {
            return
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension UserDetailsViewController: Injectable {
    func inject(_ viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
}

extension UserDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItems(for: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = viewModel?.rowType(for: indexPath) else {
            return UITableViewCell()
        }
        
        switch type {
        case .description(let description):
            return tableView.dequeueReusableCell(of: StandardSettingsTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setupWithText(text: description)
            })
        case .events(let viewModel):
            return tableView.dequeueReusableCell(of: UserProfileTableViewTableViewCell.self, for: indexPath, configure: { (cell) in
                
                cell.viewModel = viewModel
                cell.onCellSelected = { [weak self] event in
                    
                    let storyboard = UIStoryboard(name: .eventDetails, bundle: nil)
                    let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let vc = factory.createEventDetailsViewController(event: event) else {
                        return
                    }
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
                cell.onHeaderSelected = { [weak self] in
                    
                    guard let events = self?.viewModel?.pastAttendingEvents else {
                        return
                    }
                
                    let storyboard = UIStoryboard(name: .common, bundle: nil)
                    let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let vc = factory.createPastAttendingEventsViewController(events: events) else {
                        return
                    }
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
        case .followers(let followers):
            return tableView.dequeueReusableCell(of: FollowersTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.followers = followers
            })
        }
    }
}

extension UserDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowtype = viewModel?.rowType(for: indexPath) else {
            return
        }
        switch rowtype {
        case .followers(_):
            let storyboard = UIStoryboard(name: .common, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            guard let user = viewModel?.user.value,
                let vc = factory.createFollowersViewController(user:user) else {
                    return
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
}
