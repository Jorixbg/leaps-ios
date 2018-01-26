//
//  FavoritesViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit


class FavoritesViewController: BasicViewController {
    typealias T = FavoritesEventViewModel
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    fileprivate var periodType: CalendarPeriodType = .upcoming
    
    //will abstract the maintabbar controller init in splash vc if there is enought time
    fileprivate var viewModel: FavoritesEventViewModel = FavoritesEventViewModel(service: EventsService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.removeBorder()
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)
        tableView.register(ActivityTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.Activities.bottomInset, right: 0)
        let selector = #selector(fetchEvents)
        NotificationCenter.default.addObserver(self, selector: selector, name: .refreshData, object: nil)
        
        addRefreshControl(tableView: tableView) { [weak self] in
            self?.fetchEvents()
        }
    }
    
    @objc func fetchEvents() {
        viewModel.fetchLikedEvetns(periodType: periodType) { (result) in
            self.tableView.reloadData()
            self.hideRefreshControll()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        
        segmentedControl.addUnderlineForSelectedSegment()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //for the upcoming/past segmented
    @IBAction func changedSegmentValue(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            periodType = .upcoming
        case 1:
            periodType = .past
        default:
            break
            
        }
        
        sender.changeUnderlinePosition()
        //commented for test mode
        guard viewModel.isLoggedIn else {
            return
        }
        
        fetchEvents()
    }
}

extension FavoritesViewController: Injectable {
    func inject(_ viewModel: FavoritesEventViewModel) {
        self.viewModel = viewModel
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: ActivityTableViewCell.self, for: indexPath) { (cell) in
            let event = self.viewModel.event(for: indexPath, with: periodType)
            let viewModel = ActivityViewModel(event: event, distanceFromCurrentLocation: nil)
            
            cell.viewModel = viewModel
            cell.followAction = { [weak self] event in
                self?.viewModel.followEvent(event: event, completion: { (error) in
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                })
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: section, and: periodType)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections(for: periodType)
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Activities.activityCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = viewModel.event(for: indexPath, with: periodType)
        
        let storyboard = UIStoryboard(name: .eventDetails, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsViewController(event: event) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

//TODO: Needs to take closure for actions on successful login
extension FavoritesViewController: LoginPresentable { }

