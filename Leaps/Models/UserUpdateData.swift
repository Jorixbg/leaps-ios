//
//  UserUpdateData.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/23/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

final class UserUpdateData {
    var id: Int? = nil
    var age: Int? = nil
    var username: String? = nil
    var email: String? = nil
    var gender: String? = nil
    var location: String? = nil
    var maxDistanceSetting: Int? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var birthday: Date? = nil
    var description: String? = nil
    var isTrainer: Bool? = nil
    
    //trainer specific
    var longDescription: String? = nil// this one has no entry spot
    var yearsOfTraining: Int? = nil
    var phoneNumber: String? = nil
    var pricePerSession: Int? = nil
    
    //upload data
//    var mainImage: Data? = nil
//    var trainerImages: [Date] = []
    var images: [UplodableImage] = []
    var toDeleteImageIDs: [Int] = []
    
    var mainImageURL: String? = nil
    
    init(user: User) {
        self.id = user.userID
        self.username = user.username
        self.age = user.age
        self.email = user.email
        self.gender = user.gender
        self.location = user.location
        self.maxDistanceSetting = user.maxDistanceSetting
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthday = user.birthday
        self.description = user.description
        self.longDescription = user.longDescription
        self.yearsOfTraining = user.yearsOfTraining
        self.phoneNumber = user.phone
        self.pricePerSession = user.sessionPrice
        self.isTrainer = user.isTrainer
        self.mainImageURL = user.imageURL
    }
    
    func listPropertiesWithValues(reflect: Mirror? = nil) {
        let mirror = reflect ?? Mirror(reflecting: self)
        if mirror.superclassMirror != nil {
            self.listPropertiesWithValues(reflect: mirror.superclassMirror)
        }
        
        for (index, attr) in mirror.children.enumerated() {
            if let property_name = attr.label as String! {
                print("\(mirror.description) \(index): \(property_name) = \(attr.value)")
            }
        }
    }
}

extension UserUpdateData: Serializable {
    func toJSON() -> [String : Any] {
        guard let userID = id else {
            print("failed serializing user")
            return [:]
        }
        var dict: [String: Any] = [:]
        dict["user_id"] = userID
        dict["username"] = username
        dict["description"] = description
        dict["long_description"] = longDescription ?? ""
        dict["email_address"] = email
        //added n/a for testing
        dict["gender"] = gender
        dict["location"] = location
        dict["max_distance_setting"] = maxDistanceSetting
        dict["first_name"] = firstName
        dict["last_name"] = lastName
        dict["birthday"] = birthday?.timeIntervalSince1970Miliseconds ?? 0

        yearsOfTraining.flatMap {
            dict["years_of_training"] = $0
        }
        
        pricePerSession.flatMap {
            dict["price_for_session"] = $0
        }
        
        phoneNumber.flatMap {
            dict["phone_number"] = $0
        }
        
        dict["is_trainer"] = isTrainer
        
        return dict
    }
}
