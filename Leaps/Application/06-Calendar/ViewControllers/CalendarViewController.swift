//
//  CalendarViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

enum UserCalendarType {
    case hosting
    case attending
}

enum CalendarPeriodType {
    case upcoming
    case past
}

class CalendarViewController: BasicViewController {
    typealias T = CalendarActivitiesViewModel

    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var createEventButton: UIButton!
    fileprivate var type: UserCalendarType = .attending
    fileprivate var periodType: CalendarPeriodType = .upcoming
    @IBOutlet weak var trainerAdditionalSegmentedControl: UISegmentedControl!
    
    //will abstract the maintabbar controller init in splash vc if there is enought time
    fileprivate var viewModel: CalendarActivitiesViewModel = CalendarActivitiesViewModel(service: UserService(), type: UserManager.shared.isTrainer
        ? .trainer
        : .user)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //trigger fetching
        trainerAdditionalSegmentedControl.sendActions(for: .valueChanged)
        viewModel.events.bindAndFire { [weak self]  (events) in
            self?.tableView.reloadData()
        }

        segmentedControl.removeBorder()
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)
        tableView.register(ActivityCalendarTableViewCell.self)
        tableView.register(TrainersHeaderTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.Activities.bottomInset, right: 0)
        let selector = #selector(fetchEvents)
        NotificationCenter.default.addObserver(self, selector: selector, name: .refreshData, object: nil)
        
        addRefreshControl(tableView: tableView) {
            self.fetchEvents()
        }
    }
    
    func fetchEvents() {
        viewModel.fetchUserEvetns(page: 1,
                                  userCalndarType: type,
                                  periodType: periodType,
                                  completion: { (error) in
                                    print("error fetchEvents = \(String(describing: error))")
                                    self.hideRefreshControll()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        //fix for not switching layout
        viewModel.userType.value = UserManager.shared.isTrainer ? .trainer : .user
        viewModel.userType.bindAndFire { [weak self] (userProfile) in
            guard let strongSelf = self else {
                return
            }
            switch userProfile {
            case .trainer:
                strongSelf.topViewHeightConstraint.constant = Constants.Calendar.trainerTopViewHeight
                strongSelf.topView.isHidden = false
                strongSelf.createEventButton.isHidden = false
                UIApplication.shared.statusBarStyle = .lightContent
            case .user:
                strongSelf.topViewHeightConstraint.constant = UIApplication.shared.statusBarFrame.height
                strongSelf.createEventButton.isHidden = true
                strongSelf.topView.isHidden = true
                UIApplication.shared.statusBarStyle = .default
            }
        }
        
        segmentedControl.addUnderlineForSelectedSegment()
        //createEventButton.isHidden = type == .attending
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
    
    @IBAction func didPressCreateEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: .onboarding, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createCreateEventFlow() else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func DidSelectAttendingHostingSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            type = .hosting
            //createEventButton.isHidden = false
        case 1:
            type = .attending
            //createEventButton.isHidden = true
        default:
            break
        }
        
        segmentedControl.sendActions(for: .valueChanged)
    }
}

extension CalendarViewController: Injectable {
    func inject(_ viewModel: CalendarActivitiesViewModel) {
        self.viewModel = viewModel
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: ActivityCalendarTableViewCell.self, for: indexPath) { (cell) in
            let event = self.viewModel.event(for: indexPath, with: periodType)
            let viewModel = ActivityViewModel(event: event, distanceFromCurrentLocation: nil)
            
            cell.viewModel = viewModel
        }
        
        viewModel.loadMore(indexPath: indexPath,
                           forEventType: type,
                           andTimePeriodType: periodType)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: section, and: periodType)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections(for: periodType)
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Activities.activityCalendarCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.Activities.activityCalendarHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "\(TrainersHeaderTableViewCell.self)") as? TrainersHeaderTableViewCell else {
            return nil
        }
        
        headerCell.titleLabel.text = viewModel.titleForHeader(for: section, with: periodType)
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = viewModel.event(for: indexPath, with: periodType)
        
        let storyboard = UIStoryboard(name: .common, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsViewController(event: event) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

//TODO: Needs to take closure for actions on successful login
extension CalendarViewController: LoginPresentable { }
