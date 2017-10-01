//
//  UserSignUpStepsData.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/5/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

final class UserSignUpStepsData {
    var facebookID: String?
    var googleID: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var date: Int64?
    var password: String?
    
    //blank user for registration purposes
    convenience init() {
        self.init(facebookID: nil, googleID: nil, firstName: nil, lastName: nil, email: nil, dateAsString: nil, password: nil)
    }
    
    init(facebookID: String?, googleID: String?, firstName: String?, lastName: String?, email: String?, dateAsString: Int64?, password: String?) {
        self.facebookID = facebookID
        self.googleID = googleID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.date = dateAsString
        self.password = password
    }
}

extension UserSignUpStepsData: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> UserSignUpStepsData? {
            let name = dictionary["name"] as? String
            let email = dictionary["email"] as? String
            let names = name?.components(separatedBy: " ")
            let firstName = names?.first
            let lastName = names?.last
        
        return UserSignUpStepsData(facebookID: nil,
                                   googleID: nil,
                                   firstName: firstName,
                                   lastName: lastName,
                                   email: email,
                                   dateAsString: nil,
                                   password:  nil)
    }
}

extension UserSignUpStepsData: Serializable {
    func toJSON() -> [String : Any] {
        var dictionary: [String: Any] = [:]
        guard let email = email else {
            print("failed serializing UserSignUpStepsData")
            return [:]
        }
        dictionary["username"] = email
        dictionary["email_address"] = email
        dictionary["first_name"] = firstName
        dictionary["last_name"] = lastName
        dictionary["birthday"] = date
        dictionary["password"] = password ?? ""
        facebookID.flatMap {
            dictionary["fb_id"] = $0
        }
        
        googleID.flatMap {
            dictionary["google_id"] = $0
        }
        
        return dictionary
    }
}
