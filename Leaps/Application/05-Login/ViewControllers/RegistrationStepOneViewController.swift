//
//  RegistrationStepOneViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

class RegistrationStepOneViewController: UIViewController {
    
    typealias T = RegistrationStepViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var midButton: UIButton!
    private let datePicker = UIDatePicker()
    private let formatter = DateManager.shared.registerBirthdayFormatter
    
    fileprivate var viewModel: RegistrationStepViewModel?
    fileprivate var didPressMidButton: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        setupDatePicker(picker: datePicker)
        viewModel?.type.bindAndFire() { [unowned self] type in
            self.titleLabel.text = type.titleForType()
            self.subtitleLabel.text = type.subtitileHiddenAndString().1
            self.subtitleLabel.isHidden = type.subtitileHiddenAndString().0
            self.topTextField.placeholder = type.topTextFieldPlaceholder()
            self.bottomTextField.isHidden = type.bottomTextFieldHiddenAndPlaceholder().0
            self.bottomTextField.placeholder = type.bottomTextFieldHiddenAndPlaceholder().1
            self.midButton.isHidden = type.isMidButtonHidden()
            switch type {
            case .firstLastName:
                self.topTextField.keyboardType = .default
                self.topTextField.returnKeyType = .next
                self.topTextField.tag = 1
                self.bottomTextField.returnKeyType = .next
                self.bottomTextField.tag = 2
            case .emailAddress:
                self.topTextField.keyboardType = .emailAddress
                self.topTextField.returnKeyType = .next
            case .password:
                self.topTextField.isSecureTextEntry = true
                self.topTextField.returnKeyType = .next
            case .birthday:
                self.topTextField.inputView = self.datePicker
            case .yearsOfTraining, .sessionPrice, .phoneNumber:
                self.topTextField.keyboardType = .phonePad
            case .login:
                self.topTextField.keyboardType = .default
                self.bottomTextField.keyboardType = .default
                self.bottomTextField.isSecureTextEntry = true
            case .forgottenPassword:
                self.topTextField.keyboardType = .emailAddress
            }
        }
        
        //prefill info when available and trigger events for delegate func
        viewModel?.userPrefilledData.bindAndFire({ [unowned self] (userData) in
            guard let type = self.viewModel?.type.value, let userData = userData else {
                return
            }
            
            var topTextFieldText: String? = nil
            var bottomTextFieldText: String? = nil
            
            switch type {
            case .firstLastName:
                topTextFieldText = userData.firstName
                bottomTextFieldText = userData.lastName
            case .emailAddress:
                topTextFieldText = userData.email
            default:
                break
            }
            
            self.topTextField.text = topTextFieldText
            self.bottomTextField.text = bottomTextFieldText
            
            topTextFieldText.flatMap {
                self.viewModel?.didEnterTextOnTopField(text: $0)
            }
            
            bottomTextFieldText.flatMap {
                self.viewModel?.didEnterTextOnBottomField(text: $0)
            }
        })
    }
    
    func setupDatePicker(picker: UIDatePicker) {
        let changeDateSelector = #selector(didChanteDate)
        datePicker.addTarget(self, action: changeDateSelector, for: .valueChanged)
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        datePicker.maximumDate = date
    }
    
    func didChanteDate() {
        topTextField.text = formatter.string(from: datePicker.date)
        viewModel?.didEnterBirthday(date: datePicker.date)
    }
    
    @IBAction func didPressMidButton(_ sender: Any) {
        viewModel?.onMidButtonPressed { error in
            if let error = error {
                print("didPressMidButton error = \(error)")
            } else {
                print("mid button action is successful")
            }
        }
    }
}

extension RegistrationStepOneViewController: Injectable {
    func inject(_ viewModel: RegistrationStepViewModel) {
        self.viewModel = viewModel
    }
}

extension RegistrationStepOneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        switch textField {
        case topTextField:
            viewModel?.didEnterTextOnTopField(text: "\(text)\(string)")
        case bottomTextField:
            viewModel?.didEnterTextOnBottomField(text: "\(text)\(string)")
        default:
            break
        }
        
        return true
    }
}
