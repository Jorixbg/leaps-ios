//
//  UserEntryDelegate.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/4/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

protocol UserEntryDelegate: class {
    func enterFirstName(firstName: String)
    func enterLastName(lastName: String)
    func enterPassword(password: String)
    func enterBirthday(birthday: Date)
    func enterEimal(email: String)
    func enterYearsOfTraining(yearsOfTraining: String)
    func enterPricePerSession(pricePerSession: String)
    func enterPhoneNumber(phoneNumber: String)
    func enterLoginUsernameOrEmail(usenrameOrPass: String)
    func enterLoginPassword(password: String)
    func enterForgottenPassEmail(email: String)
    func forgottenPasswordPressed(completion: ((Error?) -> Void)?)
}
