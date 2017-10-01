//
//  TagLabel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/19/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TagLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 4.0
    @IBInspectable var rightInset: CGFloat = 4.0
    @IBInspectable var borderColor: UIColor = .white
    @IBInspectable var borderWidth: CGFloat = 1.0
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var shouldEnableTap: Bool = false {
        didSet {
            isUserInteractionEnabled = shouldEnableTap
        }
    }
    @IBInspectable var selectedTextColor: UIColor = .leapsOnboardingBlue
    
    var isSelected = false {
        didSet {
            backgroundColor = isSelected ? borderColor : .clear
            textColor = isSelected ? selectedTextColor : borderColor
        }
    }
    var didSelectTag: ((String, Bool) -> Void)?
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset,
                                  left: leftInset,
                                  bottom: bottomInset,
                                  right: rightInset)
        
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        textAlignment = .center
        clipsToBounds = true
        layer.borderWidth = 1
        layer.cornerRadius = 2
        layer.borderColor = borderColor.cgColor
    }
    
    //Adding this as I don't want to do it all over again with a button
    override func awakeFromNib() {
        super.awakeFromNib()
        let selector = #selector(didSelectLabel)
        let tap = UITapGestureRecognizer(target: self, action: selector)
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    func didSelectLabel() {
        guard let text = text, shouldEnableTap else {
            return
        }
        isSelected = !isSelected
        didSelectTag?(text, isSelected)
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}



