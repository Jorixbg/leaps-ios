//
//  ActivitiesHeaderTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/19/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ActivitiesHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var nextImageView: UIImageView!
    var selectedHedader: ((EventType) -> Void)?
    
    private var result: EventResult? {
        didSet {
            let totalCountString: String?
            if let count = result?.totalCount {
                totalCountString = String(count)
            } else {
                totalCountString = nil
            }
            
            leftLabel.text = result?.type.sectionHeaderTitle(text: totalCountString)
            rightLabel.text = result?.type.actionLabelText()
            guard let type = result?.type else {
                return
            }
            
            nextImageView.image = type != .search ? #imageLiteral(resourceName: "next") : #imageLiteral(resourceName: "clear-filter")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selector = #selector(didSelectHeader)
        let tap = UITapGestureRecognizer(target: self, action: selector)
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    func didSelectHeader() {
        guard let type = result?.type else { return }
        selectedHedader?(type)
    }
    
    var type: EventType? {
        return result?.type
    }
 
    func setup(result: EventResult, selectedHedader: ((EventType) -> Void)? = nil) {
        self.result = result
        self.selectedHedader = selectedHedader
    
        rightLabel.isHidden = selectedHedader == nil
        nextImageView.isHidden = selectedHedader == nil
    }
}
