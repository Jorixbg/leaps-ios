//
//  EventDetailsViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/24/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EventDetailsViewController: HiddingNavigationBarViewController {
    typealias T = EventViewModel
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: EventHeaderView!
    @IBOutlet weak var registerView: EventAttendanceView!
    private var header: EventHeaderView!
    
    fileprivate let tableViewHeaderHeight: CGFloat = 200
    fileprivate let lastRowAboveRegisterViewMargin: CGFloat = 20
    private var hasLayoutScrollView = false
    fileprivate var viewModel: EventViewModel?
    fileprivate let service: UserService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.register(SpecialitiesTableViewCell.self)
        tableView.register(TitleAndDescriptionTableViewCell.self)
        tableView.register(LocationAndMapTableViewCell.self)
        tableView.register(AttendanceTableViewCell.self)
        tableView.register(TrainerImageAndNameTableViewCell.self)
        
        viewModel?.items.bindAndFire({ [weak self] (eventRows) in
            self?.setup(attendanceView: self?.registerView, with: self?.viewModel)
            self?.tableView.reloadData()
        })
        print("Open event details with id: \(viewModel?.event.value.id ?? -1)")
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = viewModel?.event.value.title
        UIApplication.shared.statusBarStyle = .default
        let selector = #selector(relaodData)
        NotificationCenter.default.addObserver(self, selector: selector, name: .refreshData, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func relaodData() {
        viewModel?.fetchEvents()
    }
    
    private func setup(attendanceView: EventAttendanceView?, with viewModel: EventViewModel?) {
        attendanceView?.viewModel = viewModel
        
        if viewModel?.loggedIn == true {
            if viewModel?.isUserAttendee == false {
                attendanceView?.onButtonPressed = { [weak self] in
                    self?.viewModel?.attendEvent() { error in
                        guard error == nil else {
                            return
                        }
                        NotificationCenter.default.post(name: .refreshData, object: nil)
                    }
                }
            } else {
                attendanceView?.onButtonPressed = { [weak self] in
                    self?.viewModel?.unattendEvent() { error in
                        guard error == nil else {
                            return
                        }
                        NotificationCenter.default.post(name: .refreshData, object: nil)
                    }
                }
            }
        } else {
            attendanceView?.onButtonPressed = { [weak self] in
                self?.presentLogin()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let tableViewHeader = tableView.tableHeaderView as? EventHeaderView,
            tableViewHeader.scrollView.bounds.width == UIScreen.main.bounds.width
            , hasLayoutScrollView == false else {
            return
        }
        
        setupTableViewHeader(tableView: tableView)
        hasLayoutScrollView = true
    }
    
    private func setupTableViewHeader(tableView: UITableView) {
        header = headerView
        header.viewModel = viewModel
        header.setupDelegation(scrollViewDelegate: self)
        let bottomInset = registerView.frame.height + lastRowAboveRegisterViewMargin
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: .leastNonzeroMagnitude))
        tableView.addSubview(header)
        tableView.contentInset = UIEdgeInsetsMake(tableViewHeaderHeight, 0, bottomInset, 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableViewHeaderHeight)
        updateHeader()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //uncomment for stretchy headers
        updateHeader()
        
        if UIDevice.IS_IPHONE_X {
            showNavigationBar(for: 0)
        }
        else {
            updateNavigationBar(offset: scrollView.contentOffset.y)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == header.scrollView {
            header.scrolled(scrollView: scrollView)
        }
    }
    
    func updateHeader() {
        var headerRect = CGRect(x: 0, y: -tableViewHeaderHeight, width: tableView.frame.width, height: tableViewHeaderHeight)
        if tableView.contentOffset.y < -tableViewHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        if header == nil {
            return
        }
        
        header.frame = headerRect
        header.sizeScrollView()
    }
    
    func updateNavigationBar(offset: CGFloat) {
        let height = headerView.frame.height
        let alpha = (height + offset)/(height - 30)
        showNavigationBar(for: alpha)
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension EventDetailsViewController: Injectable {
    func inject(_ viewModel: EventViewModel) {
        self.viewModel = viewModel
    }
}

extension EventDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowtype = viewModel?.rowType(for: indexPath) else {
            return UITableViewCell()
        }
        var cell: UITableViewCell
        switch rowtype {
        case .trainerImageAndName(let imageRelativePath, let name):
            cell = tableView.dequeueReusableCell(of: TrainerImageAndNameTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setup(imageRelativePath: imageRelativePath, traierName: name)
            })
        case .timeAndDate(let timeAndDateString):
            cell = tableView.dequeueReusableCell(of: TitleAndDescriptionTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.descriptionText = timeAndDateString
                cell.title = rowtype.titleForType
                cell.categoryImage = #imageLiteral(resourceName: "cal-in")
                cell.showImage(shouldShowImage: false)
            })
            
        case .specialities(let specialities):
            cell = tableView.dequeueReusableCell(of: SpecialitiesTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.tags = specialities
            })
        case .about(let description):
            cell = tableView.dequeueReusableCell(of: TitleAndDescriptionTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.descriptionText = description
                
                //TODO: Need to change the image with the one without background
                cell.categoryImage = #imageLiteral(resourceName: "in-info")
                cell.showImage(shouldShowImage: false)
            })
        case .location(let address):
            cell = tableView.dequeueReusableCell(of: LocationAndMapTableViewCell.self, for: indexPath) {
                cell in
                cell.descriptionText = address
                cell.title = rowtype.titleForType
                cell.categoryImage = #imageLiteral(resourceName: "in-location")
                cell.viewModel = viewModel
                if viewModel?.loggedIn == false {
                    let image = #imageLiteral(resourceName: "map-unlogged")
                    cell.showImage(shouldShowImage: true, image: image)
                } else {
                    cell.showImage(shouldShowImage: false)
                }
            }
        case .attendees:
            cell = tableView.dequeueReusableCell(of: AttendanceTableViewCell.self, for: indexPath) {
                cell in
                cell.viewModel = viewModel
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.value.count ?? 0
    }
}

extension EventDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let rowtype = viewModel?.rowType(for: indexPath),
              let owenrID = self.viewModel?.event.value.ownerID else {
            return
        }
        
        switch rowtype {
        case .trainerImageAndName( _, _):
            service.fetchUser(forUserWith: "\(owenrID)", completion: { [weak self] (result) in
                switch result {
                case .success(let user):
                    //should check if this and the current user are ==
                    let storyboard = UIStoryboard(name: .common, bundle: nil)
                    let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let vc = factory.createTrainerProfileViewController(trainer: user) else {
                        return
                    }
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                case .error(let error):
                    print(error)
                    break
                }
            })
            break
        case .attendees(_):
            let storyboard = UIStoryboard(name: .common, bundle: nil)
            let factory = StoryboardViewControllerFactory(storyboard: storyboard)
            guard let event = viewModel?.event.value,
                  let vc = factory.createFollowersViewController(event:event) else {
                return
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension EventDetailsViewController: LoginPresentable { }
