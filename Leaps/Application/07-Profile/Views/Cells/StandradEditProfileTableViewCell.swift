//
//  StandradEditProfileTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/23/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class StandradEditProfileTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var editProfilePropertyLabel: UILabel!
    @IBOutlet weak var editProfilePropertyEntryTextField: UITextField!
    //just realised that because the data is dynamic it will always reset to the initially set value. However the function will always update
    fileprivate var hasSetInitialProfilePicture = false
    fileprivate let genderPickerData = ["Male", "Female"]
    
    var onTextEntered: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selector = #selector(textFieldDidChange)
        editProfilePropertyEntryTextField.addTarget(self, action: selector, for: .editingChanged)
    }
    
    var type: EditProfileRowType? {
        didSet {
            guard !hasSetInitialProfilePicture else {
                return
            }
            editProfilePropertyLabel.text = type?.titleForRow()
            editProfilePropertyEntryTextField.text = type?.textForType()
            hasSetInitialProfilePicture = true
            
            guard let type = type else {
                return
            }
            
            switch type {
            case .aboutMe:
                editProfilePropertyEntryTextField.returnKeyType = .done
                break
            default:
                editProfilePropertyEntryTextField.returnKeyType = .next
                break
            }
         
            switch type {
            case .firstName, .lastName:
                editProfilePropertyEntryTextField.autocapitalizationType = .words
                break
            case .username, .location:
                break
            case .aboutMe:
                editProfilePropertyEntryTextField.autocapitalizationType = .sentences
                break
            case .gender:
                let pickerView = UIPickerView()
                pickerView.backgroundColor = .white
                pickerView.delegate = self
                editProfilePropertyEntryTextField.inputView = pickerView
            case .birthday:
                let datePicker = UIDatePicker()
                let changeDateSelector = #selector(didChangeDate)
                datePicker.addTarget(self, action: changeDateSelector, for: .valueChanged)
                datePicker.datePickerMode = .date
                datePicker.backgroundColor = .white
                editProfilePropertyEntryTextField.inputView = datePicker
                
            default:
                break
            }
        }
    }
    
    func didChangeDate(datePicker: UIDatePicker) {
        let dateFormatter = DateManager.shared.createEventStandardCellDateFormatter
        editProfilePropertyEntryTextField.text = dateFormatter.string(from: datePicker.date)
        guard let text = editProfilePropertyEntryTextField.text else {
            return
        }
        
        onTextEntered?(text)
    }
    
    func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        onTextEntered?(text)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //editProfilePropertyEntryTextField.becomeFirstResponder()
    }
}

extension StandradEditProfileTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerData.count
    }
}

extension StandradEditProfileTableViewCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let genederString = genderPickerData[row]
        editProfilePropertyEntryTextField.text = genederString
        onTextEntered?(genederString)
    }
}
