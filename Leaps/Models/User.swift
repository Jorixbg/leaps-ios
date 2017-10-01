//
//  User.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/17/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

struct User {
    var userID: Int?
    let username: String
    let attendedEvents: Int
    let attendingEvents: [Event]
    let email: String
    let age: Int
    let gender: String?
    let location: String?
    let maxDistanceSetting: Int
    let firstName: String
    let lastName: String
    let birthday: Date
    let description: String?
    let imageURL: String?
    let isTrainer: Bool
    
    //trainer specific
    let hostingEvents: [Event]?
    let images: [Image]?
    let specialties: [String]?
    let longDescription: String?
    let sessionPrice: Int?
    let yearsOfTraining: Int?
    let phone: String?
}

extension User {
    func imageByUrl(url:String?) -> Image? {
        print(images?.count)
        if let image = images?.first(where: {$0.url == url}) {
            return image
        }
        return nil
    }
}

extension User: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> User? {
        guard
            let userID = dictionary["user_id"] as? Int,
            let username = dictionary["username"] as? String,
            let attendedEvents = dictionary["attended_events"] as? Int,
            let eventsDict = dictionary["attending_events"] as? [[String: Any]],
            let email = dictionary["email_address"] as? String,
            let age = dictionary["age"] as? Int,
            let maxDistanceSetting = dictionary["max_distance_setting"] as? Int,
            let firstName = dictionary["first_name"] as? String,
            let lastName = dictionary["last_name"] as? String,
            let birthdayString = dictionary["birthday"] as? Int,
            let isTrainer = dictionary["is_trainer"] as? Bool
        
        else {
            return nil
        }
        
        let description = dictionary["description"] as? String
        let gender = dictionary["gender"] as? String
        let location = dictionary["location"] as? String
        let imageURL = dictionary["profile_image_url"] as? String
        let longDescription = dictionary["long_description"] as? String
        
        let attendingEvents = Event.buildArray(eventsDict)
        
        var images: [Image]? = nil
        if let imageArray = dictionary["images"] as? [[String: Any]] {
            images = Image.buildArray(imageArray)
        }
        
        let birthday = Date(timeIntervalSince1970: Double(birthdayString) / 1000)
        
        //trainer specific
        var hostingEvents: [Event]?
        if let hostingEventsDictArray = dictionary["hosting_events"] as? [[String: Any]] {
            hostingEvents = Event.buildArray(hostingEventsDictArray)
        } else {
            hostingEvents = nil
        }
        
        let yearsOfTraining = dictionary["years_of_training"] as? Int
        let sessionPrice = dictionary["session_price"] as? Int
        let phone = dictionary["phone_number"] as? String
        let specialties = dictionary["specialties"] as? [String]
        
        return User(userID: userID,
                    username: username,
                    attendedEvents: attendedEvents,
                    attendingEvents: attendingEvents,
                    email: email,
                    age: age,
                    gender: gender,
                    location: location,
                    maxDistanceSetting: maxDistanceSetting,
                    firstName: firstName,
                    lastName: lastName,
                    birthday: birthday,
                    description: description,
                    imageURL: imageURL,
                    isTrainer: isTrainer,
                    hostingEvents: hostingEvents,
                    images: images,
                    specialties: specialties,
                    longDescription: longDescription,
                    sessionPrice: sessionPrice,
                    yearsOfTraining: yearsOfTraining,
                    phone: phone)
    }
}

extension User: Serializable {
    func toJSON() -> [String : Any] {
        guard let userID = userID else {
            print("failed serializing user")
            return [:]
        }
        var dict: [String: Any] = [:]
        dict["user_id"] = userID
        dict["username"] = username
//        password??
        dict["description"] = description
        dict["long_description"] = longDescription
        dict["email_address"] = email
        dict["age"] = age
        dict["gender"] = gender
        dict["location"] = location
        dict["max_distance_setting"] = maxDistanceSetting
        dict["first_name"] = firstName
        dict["last_name"] = lastName
        
        let dateAsTimestamp = birthday.timeIntervalSince1970Miliseconds
        dict["birthday"] = dateAsTimestamp
        
        dict["profile_image_url"] = imageURL
        
        yearsOfTraining.flatMap {
            dict["years_of_training"] = $0
        }
        sessionPrice.flatMap {
            dict["session_price"] = $0
        }
        phone.flatMap {
            dict["phone_number"] = $0
        }
        //not required
//        specialties.flatMap {
//            dict["specialties"] = $0
//        }
        
        return dict
    }
}

