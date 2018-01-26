//
//  TextFieldWithImage.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//
import UIKit
class TextFieldWithImage: UITextField {
    
    private let imageFromBottomPadding: CGFloat = 4
    @IBInspectable var shouldDisableCursor: Bool = true
    
    var leftPadding: CGFloat = 0
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        
        return textRect
    }
    
    var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var placehodlerColor: UIColor = .black {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = .always
            let width = bounds.height
            let height = bounds.height - imageFromBottomPadding
            let imageFrame = CGRect(x: 0, y: 0, width: width, height: height)
            let imageView = UIImageView(frame: imageFrame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            leftView = imageView
        } else {
            leftViewMode = .never
            leftView = nil
        }
        
        self.clearButtonMode = .always
        if let clearButton = self.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(#imageLiteral(resourceName: "clear-btn"), for: .normal)
            clearButton.setImage(#imageLiteral(resourceName: "clear-btn"), for: .highlighted)
        }
        
        let placeHolderText = placeholder ?? ""
        let attributes: [NSAttributedStringKey : Any] = [.foregroundColor: placehodlerColor]
        
        attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: attributes)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        if shouldDisableCursor {
            return .zero
        } else {
            return super.caretRect(for: position)
        }
    }
    
    override var placeholder: String? {
        didSet {
            updateView()
        }
    }
    
    func set(leftPadding: CGFloat = 5, leftImage: UIImage?, enabled: Bool) {
        self.leftImage = leftImage
        self.leftPadding = leftPadding
        isEnabled = enabled
    }
    
    func set(rightImage: UIImage?, enabled: Bool) {
        self.rightImage = rightImage
        isEnabled = enabled
    }
}
