//
//  FollowersViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 26/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController {

    fileprivate var viewModel: FollowingViewModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FollowerTableViewCell.self)
        tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup(navigationController: navigationController)
    }
    
    private func setup(navigationController: UINavigationController?) {
        
        //Set navigation controller to default look
        setupDefaultNavigationController()
        
        //set attributed title
        title = viewModel?.viewControllerTitle()
        
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    func followingAction(follower:Attendee) {
        viewModel?.followUser(user: follower, completion: { (error) in
            self.tableView.reloadData()
        })
    }
}

extension FollowersViewController: Injectable {
    func inject(_ viewModel: FollowingViewModel) {
        self.viewModel = viewModel
    }
}

extension FollowersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.followers().count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(of: FollowerTableViewCell.self, for: indexPath) {cell in
            if let user = viewModel?.followers()[indexPath.row] {
                cell.configure(user: user)
                cell.followAction = {
                    self.followingAction(follower: user)
                }
            }
        }
    }
}

extension FollowersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: .common, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let user = viewModel?.followers()[indexPath.row],
            let vc = factory.createUserProfileViewController(user: user) else {
                return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
