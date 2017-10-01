//
//  ActivitiesViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ActivitiesViewController: UIViewController {
    
    typealias T = ActivitiesViewModel
    
    @IBOutlet weak var tableView: UITableView!

    var viewModel: ActivitiesViewModel?
    var onSearchPressed: ((SearchEntry) -> Void)?
    
    weak var transitionDelegate: SearchTransitionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.register(ActivityTableViewCell.self)
        tableView.register(ActivitiesHeaderTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.Activities.bottomInset, right: 0)
        viewModel?.fetchEvents()
        viewModel?.eventSearchResults.bind({ [weak self] (eventsResult) in
            self?.tableView.reloadData()
        })
        
        viewModel?.hasCurrentLocation.bind({ [weak self] (hasCurrentLocation) in
            guard hasCurrentLocation else {
                return
            }
            self?.tableView.reloadData()
        })
        
        onSearchPressed = { [weak self] searchEntry in
            self?.viewModel?.search(searchEntry: searchEntry, isNewSearch: true) { error in
                guard let _ = error else {
                    return
                }
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
}

extension ActivitiesViewController: Injectable {
    func inject(_ viewModel: ActivitiesViewModel) {
        self.viewModel = viewModel
    }
}

extension ActivitiesViewController: UITableViewDataSource {
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
        
        viewModel?.loadMore(currentActivity: indexPath, completion: nil)
        
        return cell
    }
}

extension ActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Activities.activityCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.Activities.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "\(ActivitiesHeaderTableViewCell.self)") as? ActivitiesHeaderTableViewCell,
            let eventResult = viewModel?.eventResultForSection(section: section) else {
            return nil
        }

        headerCell.setup(result: eventResult, selectedHedader: handleHeaderWithResults(of:))
    
        return headerCell
    }
    
    fileprivate func handleHeaderWithResults(of type: EventType) {
        switch type {
        case .search:
            viewModel?.fetchEvents()
            NotificationCenter.default.post(name: .resetSearch, object: nil)
        default:
            let storyboard = UIStoryboard(name: .home, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            guard let vc = factory.createAllActivitiesViewController(type: type) else {
                return
            }
            
            transitionDelegate?.willTransitionToViewControllerWithSearch()
            navigationController?.pushViewController(viewController: vc, animated: true, completion: { [weak self] in
                self?.transitionDelegate?.finishedTransition()
            })
        }
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


