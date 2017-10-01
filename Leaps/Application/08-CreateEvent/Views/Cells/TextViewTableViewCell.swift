//
//  TextViewTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/20/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var onTextEnter: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        backgroundImageView.layer.cornerRadius = Constants.General.standradCornerRadius
        textView.layer.cornerRadius = Constants.General.standradCornerRadius
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let existingText = textView.text else {
            return true
        }
        
        let fullText = "\(existingText)\(text)"
        onTextEnter?(fullText)
        
        return true
    }
}
