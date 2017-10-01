//
//  EventAttendanceView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/30/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EventAttendanceView: UIView {
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var button: UIButton!

    var viewModel: EventViewModel? {
        didSet {
            if viewModel?.loggedIn == true {
                viewModel.flatMap {
                    if !$0.isUserAttendee {
                        text.text = "FROM \($0.event.value.priceFrom)!"
                        button.setTitle("GO TRAIN!", for: .normal)
                    } else {
                        text.text = "ALREADY SIGNED UP"
                        button.setTitle("UNATTEND", for: .normal)
                    }
                }
            } else {
                text.text = "TRY IT FOR FREE!"
                button.setTitle("Sign up", for: .normal)
            }
        }
    }
    
    @IBAction func didPressButton(_ sender: Any) {
        onButtonPressed?()
    }
    
    var onButtonPressed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
    }
}
