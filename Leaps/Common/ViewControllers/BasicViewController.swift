//
//  BasicViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 18/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class BasicViewController: UIViewController {

    var refreshControl: UIRefreshControl = UIRefreshControl()
    var refreshBlock:(()->Void)?
    
    func addRefreshControl(tableView:UITableView, refresh:(()->Void)?) {
        refreshBlock = refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }

    func hideRefreshControll() {
        refreshControl.endRefreshing()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshBlock?()
    }
}
