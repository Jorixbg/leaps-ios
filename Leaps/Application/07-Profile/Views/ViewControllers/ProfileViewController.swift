//
//  ProfileViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/5/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    typealias T = ProfileViewModel
    
    @IBOutlet weak var headerView: UserHeaderView!
    @IBOutlet weak var tableView: UITableView!
    //should be extracted when init of maintabbar is moved to appdelegate/splash vc
    fileprivate var viewModel: ProfileViewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        viewModel.seetingsSections.bind { [weak self] (sections) in
            self?.tableView.reloadData()
            if let user = self?.viewModel.user.value {
                self?.headerView.viewModel = UserViewModel(user: user)
            }
        }
        let reloadDataSelector = #selector(reloadData)
        NotificationCenter.default.addObserver(self, selector: reloadDataSelector, name: .refreshOnImageUpload, object: nil)
        
        tableView.register(BecomeATrainerTableViewCell.self)
        tableView.register(StandardSettingsTableViewCell.self)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadData() {
        viewModel.fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchUser()
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func presentBecomeTrainer() {
        // need to extract it to common and rename it
        let storyboard = UIStoryboard(name: .onboarding, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        
        guard let vc = factory.createBecomeATrainerFlowViewController() else {
            return
        }
        
        present(vc, animated: true, completion: nil)
    }
}

extension ProfileViewController: Injectable {
    func inject(_ viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsSettings(for: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSettingsSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = viewModel.type(forIndexPath: indexPath)
        switch type {
        case .becomeTrainer(let buttonTitle, let infoLabelText):
            return tableView.dequeueReusableCell(of: BecomeATrainerTableViewCell.self, for: indexPath) {
                $0.configure(buttonTitle: buttonTitle, infoLabelText: infoLabelText) { [weak self] in
                    self?.presentBecomeTrainer()
                }
            }
        case .aboutMe(let description):
            return tableView.dequeueReusableCell(of: StandardSettingsTableViewCell.self, for: indexPath) {
                $0.type = type
                $0.titleLabel.text = description
            }
        default:
            return tableView.dequeueReusableCell(of: StandardSettingsTableViewCell.self, for: indexPath) {
                print(type)
                $0.type = type
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let type = viewModel.type(forIndexPath: indexPath)
        
        switch type {
        case .edit:
            guard let user = viewModel.user.value else {
                return
            }
            let storyboard = UIStoryboard(name: .profile, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            let profileViewModel = ProfileViewModel(user: user)
            guard let viewController = factory.createEditProvfileViewController(viewModel: profileViewModel) else {
                return
            }
            
            self.navigationController?.pushViewController(viewController, animated: true)
        case .settings:
            let storyboard = UIStoryboard(name: .profile, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            guard let vc = factory.createMaxDistanceSettingsViewController(viewModel: viewModel) else {
                return
            }
            
            navigationController?.pushViewController(vc, animated: true)
        case .inviteFriends:
            break
        case .giveFeedback:
            break
        case .viewHelpTutorial:
            presentOnboarding()
        case .logout:
            viewModel.logout()
            presentLogin(completion: {
                NotificationCenter.default.post(name: .loggedOut, object: nil)
            })
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileViewController: OnboardingPresentable { }
extension ProfileViewController: LoginPresentable { }
