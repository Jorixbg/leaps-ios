//
//  AllActivitiesViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/28/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

//TODO: extract this to Home and Activities VC to avoid code repeaiting. 
class AllActivitiesViewController: UIViewController {
    typealias T = ActivitiesViewModel
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: SearchView!
    
    fileprivate var viewModel: ActivitiesViewModel?
    
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
        
        searchView.backButton.isHidden = isMovingToParentViewController
        searchView.didSelectBack = { [weak self] in
            self?.searchView.collapse() { finished in
                guard finished else {
                    return
                }
                
                let snapshot = self?.searchView.snapshotView(afterScreenUpdates: false)
                guard let snapshotView = snapshot, let frame =  self?.searchView.frame else {
                    return
                }
                
                snapshotView.frame = frame
                self?.navigationController?.view.addSubview(snapshotView)
                self?.navigationController?.popViewController(animated: true, completion: { 
                    snapshotView.removeFromSuperview()
                })
            }
        }
        
        searchView.didSelectSearch = { [weak self] in
            let storyboard = UIStoryboard(name: .common, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            guard let viewController = factory.createSearchViewController(onSearchPressed: { [weak self] (searchEntry) in
                self?.searchView.searchEntry = searchEntry
                self?.viewModel?.search(searchEntry: searchEntry, isNewSearch: true) { error in
                    guard let _ = error else {
                        return
                    }
                    
                }
            }) else {
                print("failed init search vc")
                return
            }
            
            self?.present(viewController, animated: false, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(expandSearch), name: .keepSearchTransition, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchView.setTextField(image: #imageLiteral(resourceName: "find"))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func expandSearch() {
        searchView.expand()
    }
}

extension AllActivitiesViewController: Injectable {
    func inject(_ viewModel: ActivitiesViewModel) {
        self.viewModel = viewModel
    }
}

extension AllActivitiesViewController: UITableViewDataSource {
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
            
            let distance = viewModel?.distance(from: event)
            let eventViewModel = ActivityViewModel(event: event, distanceFromCurrentLocation: distance)
            cell.viewModel = eventViewModel
        }
        
        //pagination
        viewModel?.loadMore(currentActivity: indexPath, completion: nil)
        
        return cell
    }
}

extension AllActivitiesViewController: UITableViewDelegate {
    
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
        
        let action: ((EventType) -> Void)? = eventResult.type == .search ? handleHeaderWithResults : nil
        headerCell.setup(result: eventResult, selectedHedader: action)
        return headerCell
    }
    
    fileprivate func handleHeaderWithResults(of type: EventType) {
        switch type {
        case .search:
            viewModel?.fetchEvents()
            NotificationCenter.default.post(name: .resetSearch, object: nil)
            print("clear results")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = viewModel?.eventForIndexPath(indexPath: indexPath) else {
            return
        }
        
        let storyboard = UIStoryboard(name: .eventDetails, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsViewController(event: event) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

