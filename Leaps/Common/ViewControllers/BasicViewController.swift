//
//  BasicViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 18/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SnapKit

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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshBlock?()
    }
    
    func emptyLabel(to tableView:UITableView, count: Int, message: String) {
        if count > 0 {
            self.view.viewWithTag(111)?.removeFromSuperview()
        }
        else {
            if let empView = self.view.viewWithTag(111) as? EmptyTableViewLabelView {
                empView.messageLabel.text = message
                return
            }
            
            let emptyView = EmptyTableViewLabelView.instanceFromNib()
            emptyView.messageLabel.text = message
            emptyView.tag = 111
            self.view.addSubview(emptyView)
            emptyView.snp.makeConstraints { (make) in
                make.center.equalTo(tableView.snp.center)
                // Must be 250 or if have to be changed, first change it from EmptyTableViewLabelView Xib
                // or icon size will be broke
                make.width.equalTo(250)
            }
        }
    }
}

class HiddingNavigationBarViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override var title: String? {
        didSet {
            navigationBarTitleLabel.text = title?.uppercased()
        }
    }
    
    func showNavigationBar(for alpha:CGFloat) {
        navigationBarView.alpha = alpha
        backButton.tintColor = interpolateColor(begin: .white, end: .leapsOnboardingBlue, progress: alpha)
    }
    
    func interpolateColor(begin:UIColor, end:UIColor, progress:CGFloat) -> UIColor {
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        begin.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        var er: CGFloat = 0, eg: CGFloat = 0, eb: CGFloat = 0, ea: CGFloat = 0
        end.getRed(&er, green: &eg, blue: &eb, alpha: &ea)
        
        let newRed   = (1.0 - progress) * br + progress * er;
        let newGreen = (1.0 - progress) * bg + progress * eg;
        let newBlue  = (1.0 - progress) * bb + progress * eb;
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1)
    }
}
