//
//  RegistrationStepViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum RegistrationStepType {
    case firstLastName
    case emailAddress
    case password
    case birthday
    case yearsOfTraining
    case sessionPrice
    case phoneNumber
    case login
    case forgottenPassword
    
    func titleForType() -> String {
        switch self {
        case .firstLastName:
            return .nameTitle
        case .emailAddress:
            return .emailTitle
        case .password:
            return .passwordTitle
        case .birthday:
            return .birthdayTitle
        case .yearsOfTraining:
            return .trainerYearsOfTraining
        case .sessionPrice:
            return .trainerPricePerSession
        case .phoneNumber:
            return .trainerPhone
        case .login:
            return .loginTitle
        case .forgottenPassword:
            return .forgotPasswordTitle
        }
    }
    
    func subtitileHiddenAndString() -> (Bool, String?) {
        switch self {
        case .firstLastName:
            return (true, nil)
        case .emailAddress:
            return (true, nil)
        case .password:
            return (false, .passwordSubtitle)
        case .birthday:
            return (false, .birthdaySubtitle)
        case .yearsOfTraining:
            return (false, nil)
        case .sessionPrice:
            return (false, nil)
        case .phoneNumber:
            return (false, .trainerPhoneSubtitle)
        case .login:
            return (false, nil)
        case .forgottenPassword:
            return (false, .forgotPasswordSubtitle)
        }
    }
    
    func topTextFieldPlaceholder() -> String {
        switch self {
        case .firstLastName:
            return .firstNamePlaceholder
        case .emailAddress:
            return .emailPlaceholder
        case .password:
            return .passwordPlaceholder
        case .birthday:
            return .birthdayPlaceholder
        case .yearsOfTraining:
            return .trainerYearsOfTrainingPlaceholder
        case .sessionPrice:
            return .trainerPricePerSessionPlaceholder
        case .phoneNumber:
            return .trainerPhonePlaceholder
        case .login:
            return .usernameOrEmail
        case .forgottenPassword:
            return .emailPlaceholder
        }
    }
    
    func bottomTextFieldHiddenAndPlaceholder() -> (Bool, String?) {
        switch self {
        case .firstLastName:
            return (false, .lastNamePlaceholder)
        case .login:
            return (false, .password)
        default:
            return (true, nil)
        }
    }
    
    func isMidButtonHidden() -> Bool {
        switch  self {
        case .forgottenPassword:
            return false
        default:
            return true
        }
    }
}

class RegistrationStepViewModel: BaseViewModel {
    
    let type: Dynamic<RegistrationStepType>
    let userPrefilledData: Dynamic<UserSignUpStepsData?>
    
    weak var delegate: UserEntryDelegate? = nil
    fileprivate var service: UserService
    
    init(type: Dynamic<RegistrationStepType>, userPrefilledData: Dynamic<UserSignUpStepsData?>, service: UserService = UserService()) {
        self.type = type
        self.userPrefilledData = userPrefilledData
        self.service = service
    }
    
    func onMidButtonPressed(completion: ((Error?) -> Void)?) {
        delegate?.forgottenPasswordPressed(completion: completion)
    }
    
    func didEnterTextOnTopField(text: String) {
        switch type.value {
        case .firstLastName:
            delegate?.enterFirstName(firstName: text)
            break
        case .emailAddress:
            delegate?.enterEimal(email: text)
            break
        case .password:
            delegate?.enterPassword(password: text)
            break
        case .yearsOfTraining:
            delegate?.enterYearsOfTraining(yearsOfTraining: text)
            break
        case .sessionPrice:
            delegate?.enterPricePerSession(pricePerSession: text)
            break
        case .phoneNumber:
            delegate?.enterPhoneNumber(phoneNumber: text)
            break
        case .login:
            delegate?.enterLoginUsernameOrEmail(usenrameOrPass: text)
            break
        case .forgottenPassword:
            delegate?.enterForgottenPassEmail(email: text)
            break
        case .birthday:
            break
        }
    }
    
    func didEnterBirthday(date: Date) {
        delegate?.enterBirthday(birthday: date)
    }
    
    func actionOnMidButtonPressed(completion: ((Error?) -> Void)?) {
        switch type.value {
        case .forgottenPassword:
           delegate?.forgottenPasswordPressed(completion: completion)
        default:
            break
        }
    }
    
    func didEnterTextOnBottomField(text: String) {
        switch type.value {
        case .firstLastName:
            delegate?.enterLastName(lastName: text)
        case .login:
            delegate?.enterLoginPassword(password: text)
        default:
            break
        }
    }
}
