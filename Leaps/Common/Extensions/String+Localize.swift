//
//  String+Localize.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

fileprivate func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

//Localization at the end of the project as a separate task
extension String {
    static let skip = NSLocalizedString("onboarding.skip")
    static let next = NSLocalizedString("onboarding.next")
    static let back = NSLocalizedString("onboarding.back")
    static let passion = NSLocalizedString("onboarding.apssion")
    static let passionMessage = NSLocalizedString("oboarding.passion.subtitle")
    static let drive = NSLocalizedString("onboarding.drive")
    static let driveMessage = NSLocalizedString("onboarding.drive.subtitle")
    static let power = NSLocalizedString("onboarding.power")
    static let powerMessage = NSLocalizedString("onboarding.power.subtitle")
    static let nameTitle = NSLocalizedString("registration.yourname.title")
    static let firstNamePlaceholder = NSLocalizedString("registration.first.name.placeholder")
    static let lastNamePlaceholder = NSLocalizedString("registration.last.name.placeholder")
    static let emailPlaceholder = NSLocalizedString("registration.email.placeholder")
    static let emailTitle = NSLocalizedString("registration.email.title")
    static let passwordTitle = NSLocalizedString("registration.password.title")
    static let passwordSubtitle = NSLocalizedString("registration.password.subtitle")
    static let passwordPlaceholder = NSLocalizedString("registration.password.placeholder")
    static let birthdayTitle = NSLocalizedString("registration.birthday.title")
    static let birthdaySubtitle = NSLocalizedString("registration.birthday.subtitle")
    static let birthdayPlaceholder = NSLocalizedString("registration.birthday.placeholder")
    static let cancel = NSLocalizedString("registration.cancel")
    static let trainerYearsOfTraining = NSLocalizedString("become.trainer.years.of.training.title")
    static let trainerYearsOfTrainingPlaceholder = NSLocalizedString("become.trainer.years.of.training.placeholder")
    static let trainerPricePerSession = NSLocalizedString("become.trainer.price.per.session.title")
    static let trainerPricePerSessionPlaceholder = NSLocalizedString("become.trainer.price.per.session.placeholder")
    static let trainerPhone = NSLocalizedString("become.trainer.phone.number.title")
    static let trainerPhoneSubtitle = NSLocalizedString("become.trainer.phone.number.subtitle")
    static let trainerPhonePlaceholder = NSLocalizedString("become.trainer.phone.number.placeholder")
    static let loginTitle = NSLocalizedString("login.title")
    static let usernameOrEmail = NSLocalizedString("login.username.or.email")
    static let password = NSLocalizedString("login.password")
    static let forgotPasswordTitle = NSLocalizedString("forgotten.password.title")
    static let forgotPasswordSubtitle = NSLocalizedString("forgotten.password.subtitle")
}
