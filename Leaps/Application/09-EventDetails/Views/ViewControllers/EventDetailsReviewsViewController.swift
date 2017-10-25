//
//  EventDetailsReviewsViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EventDetailsReviewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var viewModel: ReviewViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set navigation controller to default look
        setupDefaultNavigationController()
        
        UIApplication.shared.isStatusBarHidden = false

        //set title
        title = "Reviews".uppercased()

        tableView.register(ReviewTableViewCell.self)

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        viewModel?.reviews.bindAndFire({ (reviews) in
            self.tableView.reloadData()
        })
        viewModel?.fetchEventsReviews()
    }

    

}

extension EventDetailsReviewsViewController: Injectable {
    func inject(_ viewModel: ReviewViewModel) {
        self.viewModel = viewModel
    }
}

extension EventDetailsReviewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let review = viewModel?.reviews.value[indexPath.row] else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(of: ReviewTableViewCell.self, for: indexPath, configure: { (cell) in
            cell.review = review
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.reviews.value.count ?? 0
    }
}

extension EventDetailsReviewsViewController: UITableViewDelegate {
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
