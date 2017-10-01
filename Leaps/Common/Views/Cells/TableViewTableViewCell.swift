//
//  TableViewTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/13/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

    
class TableViewTableViewCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var onCellSelected: ((Event) -> Void)?
    var onHeaderSelected: (() -> Void)?
    
    var viewModel: TrainerViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                tableViewHeightConstraint.constant = 0
                return
            }
            
            if viewModel.hostingUpcoming.value.count < 3 {
                tableViewHeightConstraint.constant = Constants.Activities.activityCellHeight + Constants.Activities.headerHeight
                tableView.bounces = false
            } else {
                //2.5 cells to be visible for better ux
                tableViewHeightConstraint.constant = 5*Constants.Activities.activityCellHeight/2 + Constants.Activities.headerHeight
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(ActivityTableViewCell.self)
        tableView.register(TrainerEventsHeaderTableViewCell.self)
        viewModel?.hostingUpcoming.bindAndFire({ (event) in
            self.tableView.reloadData()
        })
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension TableViewTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: ActivityTableViewCell.self, for: indexPath) { (cell) in
            guard let event = viewModel?.hostingUpcomingEvent(for: indexPath) else {
                return
            }
            
            let distanceFromEvent = viewModel?.distance(from: event)
            let eventViewModel = ActivityViewModel(event: event, distanceFromCurrentLocation: distanceFromEvent)
            cell.viewModel = eventViewModel
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsForHostingUpcomingEvents(for: section) ?? 0
    }
}

extension TableViewTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Activities.activityCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = viewModel?.hostingUpcomingEvent(for: indexPath) else {
            return
        }
        onCellSelected?(event)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.Activities.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "\(TrainerEventsHeaderTableViewCell.self)") as? TrainerEventsHeaderTableViewCell else {
            return nil
        }
        
        headerCell.selectedHedader = onHeaderSelected
        
        return headerCell
    }
}
