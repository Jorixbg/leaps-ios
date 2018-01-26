//
//  StandardCreateEventTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/19/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ErrorCreateEventTableViewCell:UITableViewCell {
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.errorLabel.isHidden = true
    }
    
    func showErrorLabel(with error:String?) {
        if let error = error {
            errorLabel.text = error
        }
        errorLabel.isHidden = false
    }
}

class StandardCreateEventTableViewCell: ErrorCreateEventTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    fileprivate let datePickerView: UIDatePicker = UIDatePicker()
    
    var onTextEnter: ((String) -> Void)?
    fileprivate var type: CreateEventRowType?
    
    func setup(type: CreateEventRowType) {
        titleLabel.text = type.titleForRow()
        self.type = type
        switch type {
        case .priceFrom, .freeSlots:
            textField.keyboardType = .numberPad
            break
        default:
            break
        }
        
        switch type {
        case .title, .description:
            textField.autocapitalizationType = .sentences
            break
        case .eventLocationMap:
            textField.autocapitalizationType = .words
            break
        default:
            break
        }
        
        self.textField.layer.cornerRadius = Constants.General.standradCornerRadius
        
        let paddingForFirst = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        self.textField.leftView = paddingForFirst
        self.textField.leftViewMode = .always
        
        if let placeholder = type.placeholderForType() {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor : UIColor.leapsOnboardingBluePlaceholder])
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
}

extension StandardCreateEventTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let fullText = "\(text)\(string)"
        onTextEnter?(fullText)
        errorLabel.isHidden = true
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let type = type else {
            return true
        }
        
        switch type {
        case .date:
            datePickerView.datePickerMode = .date
            datePickerView.backgroundColor = .white
            textField.inputView = datePickerView
            datePickerView.minimumDate = Date()
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        case .time:
            let datePickerView = UIDatePicker()
            datePickerView.backgroundColor = .white
            datePickerView.datePickerMode = .time
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

        default:
            break
        }
        
        return true
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        switch sender.datePickerMode {
        case .date:
            let dateFormatter = DateManager.shared.createEventStandardCellDateFormatter
            textField.text = dateFormatter.string(from: sender.date)
        case .time:
            let dateFormatter = DateManager.shared.createEventStandardCellTimeFormatter
            textField.text = dateFormatter.string(from: sender.date)
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //handle date date and time cases
        guard let type = type,
            let text = textField.text else {
            return
        }
        switch type {
        case .date, .time:
            onTextEnter?(text)
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
