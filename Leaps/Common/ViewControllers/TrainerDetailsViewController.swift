//
//  TrainerDetailsViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TrainerDetailsViewController: UIViewController {
    typealias T = TrainerViewModel

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: TrainerHeaderView!
    private var header: TrainerHeaderView!
    private var hasLayoutScrollView = false
    
    //this could be done in a better way on view did appear get the frame height and it will make it dynamic
    fileprivate let tableViewHeaderHeight: CGFloat = 250
    
    var viewModel: TrainerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(SpecialitiesTableViewCell.self)
        tableView.register(TitleAndDescriptionTableViewCell.self)
        tableView.register(TableViewTableViewCell.self)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let tableViewHeader = tableView.tableHeaderView as? TrainerHeaderView,
            tableViewHeader.scrollView.bounds.width == UIScreen.main.bounds.width
            , hasLayoutScrollView == false else {
                return
        }
        
        setupTableViewHeader(tableView: tableView)
        hasLayoutScrollView = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupTableViewHeader(tableView: UITableView) {
        header = headerView
        header.viewModel = viewModel
        header.setupDelegation(scrollViewDelegate: self)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: .leastNonzeroMagnitude))
        tableView.addSubview(header)
        tableView.contentInset = UIEdgeInsetsMake(tableViewHeaderHeight, 0, 0, 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableViewHeaderHeight)
        updateHeader()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //uncomment for stretchy headers
        updateHeader()
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
        
        header.frame = headerRect
        header.sizeScrollView()
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension TrainerDetailsViewController: Injectable {
    func inject(_ viewModel: TrainerViewModel) {
        self.viewModel = viewModel
    }
}

extension TrainerDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItems(for: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowtype = viewModel?.rowType(for: indexPath) else {
            return UITableViewCell()
        }
        var cell: UITableViewCell
        switch rowtype {
        case.specialities(let specialities):
            cell = tableView.dequeueReusableCell(of: SpecialitiesTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.tags = specialities
            })
            
            return cell
        case .about(let age, let description):
            cell = tableView.dequeueReusableCell(of: TitleAndDescriptionTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.descriptionText = description
                cell.ageLabel.text = age
                //TODO: Need to change the image with the one without background
                cell.categoryImage = #imageLiteral(resourceName: "in-info")
                cell.type = .aboutTrainer
            })
            
            return cell
        case .events(let viewModel):
            cell = tableView.dequeueReusableCell(of: TableViewTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.viewModel = viewModel
                cell.onCellSelected = { [weak self] event in
             
                    let storyboard = UIStoryboard(name: .common, bundle: nil)
                    let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let vc = factory.createEventDetailsViewController(event: event) else {
                        return
                    }
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
                cell.onHeaderSelected = { [weak self] in
                    
                    guard let events = self?.viewModel?.hostingPast.value else {
                        return
                    }
                    
                    let storyboard = UIStoryboard(name: .common, bundle: nil)
                    let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let vc = factory.createPastHostingEventsViewController(events: events) else {
                        return
                    }
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            
            return cell
        }
    }
}

extension TrainerDetailsViewController: UITableViewDelegate {
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
