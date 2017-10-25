//
//  HomeViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

protocol SearchTransitionDelegate: class {
    func willTransitionToViewControllerWithSearch()
    func finishedTransition()
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var searchView: SearchView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var activitiesConatinerView: UIView!
    @IBOutlet weak var trainersContainerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var createEventButton: UIButton!
    
    private var containedViewControllers: [UIViewController] = []
    fileprivate var viewModel: HomeViewModel = HomeViewModel(type: UserManager.shared.isTrainer ? .trainer : .user)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.removeBorder()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: .valueChanged)
        embedActivitiesViewController(in: activitiesConatinerView)
        embedTrainersViewController(in: trainersContainerView)
        
        viewModel.userType.bindAndFire { [weak self] (userProfile) in
            guard let strongSelf = self else {
                return
            }
            switch userProfile {
            case .trainer:
                strongSelf.createEventButton.isHidden = false
            case .user:
                strongSelf.createEventButton.isHidden = true
            }
        }
    }
    
    fileprivate var searchSnapshotView: UIView?
    
    private func embedActivitiesViewController(in containerView: UIView) {
        let storyboard = UIStoryboard(name: .home, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createActivitiesViewController() else {
            return
        }
        
        vc.transitionDelegate = self
        add(viewController: vc, with: containerView, to: self)
    }
    
    private func embedTrainersViewController(in containerView: UIView) {
        let storyboard = UIStoryboard(name: .home, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createTrainersViewController() else {
            return
        }
        
        add(viewController: vc, with: containerView, to: self)
    }
    
    private func add(viewController: UIViewController, with containerView: UIView, to parentViewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: parentViewController)
        containedViewControllers.append(viewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        createEventButton.isHidden = !UserManager.shared.isTrainer
        segmentControl.addUnderlineForSelectedSegment()
        searchView.setTextField(image: #imageLiteral(resourceName: "find"))
        searchView.didSelectSearch = { [weak self] in
            let storyboard = UIStoryboard(name: .common, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            
            guard let viewController = factory.createSearchViewController(onSearchPressed: { (searchEntry) in
                guard let selectedPosition = self?.segmentControl.selectedSegmentIndex,
                    let containedViewControllers = self?.containedViewControllers,
                            selectedPosition < containedViewControllers.count else {
                    return
                }
                self?.searchView.searchEntry = searchEntry
                let currentVC = containedViewControllers[selectedPosition]
                switch currentVC {
                case let activitiesVC as ActivitiesViewController:
                    activitiesVC.onSearchPressed?(searchEntry)
                case let trainersVC as TrainersViewController:
                    trainersVC.onSearchPressed?(searchEntry)
                default:
                    break
                }
            }) else {
                print("failed init search vc")
                return
            }
            
            self?.present(viewController, animated: false, completion: nil)
        }
        
        searchView.didSelectMap = { [weak self] in
            let storyboard = UIStoryboard(name: .home, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            let viewModel = (self?.containedViewControllers.first as? ActivitiesViewController)?.viewModel
            
            guard let vc = factory.createLocationsViewController(viewModel: viewModel) else {
                return
            }
            
            self?.present(vc, animated: true, completion: nil)
        }
        
        searchView.didSelectClear = { [weak self] in
            if let activitiesViewController = self?.containedViewControllers.first as? ActivitiesViewController {
                activitiesViewController.resetSearch()
            }
            if let trainersViewController = self?.containedViewControllers[1] as? TrainersViewController {
                trainersViewController.resetSearch()
            }
        }
    }
    
    @IBAction func didPressLogin(_ sender: Any) {
        presentLogin()
    }
    
    @IBAction func changedSegmentValue(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            activitiesConatinerView.isHidden = false
            trainersContainerView.isHidden = true
        case 1:
            activitiesConatinerView.isHidden = true
            trainersContainerView.isHidden = false
        default:
            break
        }
        
        segmentControl.changeUnderlinePosition()
    }
    
    @IBAction func didPressCreateEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: .onboarding, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createCreateEventFlow() else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension HomeViewController: LoginPresentable {}

extension HomeViewController: SearchTransitionDelegate {
    func finishedTransition() {
        searchSnapshotView?.removeFromSuperview()
        NotificationCenter.default.post(name: .keepSearchTransition, object: nil)
    }

    func willTransitionToViewControllerWithSearch() {
        guard let searchSnapshot = searchView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        
        searchSnapshotView = searchSnapshot
        searchSnapshotView?.frame = searchView.frame
        guard let searchSnapshotView = searchSnapshotView else {
            return
        }
        navigationController?.view.addSubview(searchSnapshotView)
    }
}
