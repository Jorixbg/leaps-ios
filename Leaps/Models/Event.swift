//
//  Event.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

struct Event {
    let id: Int
    let title: String
    let description: String
    let date: Date
    let timeFrom: Date
    let timeTo: Date
    let ownerID: Int
    let ownerImageURL: String?
    let ownerName: String
    let specialties: [String]
    let latitude: Double
    let longitude: Double
    let priceFrom: Int
    let address: String
    let freeSlots: Int
    let rating:Double?
    let reviews:Int?
    let dateCreated: Date
    let eventImageURL: String?
    let images: [Image]
    let attending: [Attendee]
}

extension Event: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> Event? {
        guard let id = dictionary["event_id"] as? Int,
            let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let dateTimestamp = dictionary["date"] as? Int64,
            
            //not sure if these are as double or Int64
            let timeFromTimestamp = dictionary["time_from"] as? Int64,
            let timeToTimestamp = dictionary["time_to"] as? Int64,
            
            let ownerID = dictionary["owner_id"] as? Int,
            let ownerName = dictionary["owner_name"] as? String,
            let specialties = dictionary["specialities"] as? [String],
            let latitude = dictionary["coord_lat"] as? Double,
            let longitude = dictionary["coord_lnt"] as? Double,
            let priceFrom = dictionary["price_from"] as? Int,
            let address = dictionary["address"] as? String,
            let freeSlots = dictionary["free_slots"] as? Int,
            let dateCreatedTimestamp = dictionary["date_created"] as? Int64,
            let imagesArray = dictionary["images"] as? [[String: Any]],
            let attendingArray = dictionary["attending"] as? [String: [[String:Any]]]
            //this one is null
            else {
            print("event deserializing failed")
            return nil
        }
        
        let rating = dictionary["rating"] as? Double
        let reviews = dictionary["reviews"] as? Int
        let eventImageURL = dictionary["event_image_url"] as? String
        let ownerImageURL = dictionary["owner_image_url"] as? String
        let images = Image.buildArray(imagesArray)
        
        var attendees = [Attendee]()
        if attendingArray.contains(where: {$0.key == "followed"}),
           attendingArray.contains(where: {$0.key == "others"}) {
            let following = Attendee.buildArray(attendingArray["followed"]).map({$0.change(followed: true)})
            let notFollowing = Attendee.buildArray(attendingArray["others"])
            attendees = following + notFollowing
        }
        
        return Event(id: id,
                     title: title,
                     description: description,
                     date: Date(timeIntervalSince1970inMiliseconds: dateTimestamp),
                     timeFrom: Date(timeIntervalSince1970inMiliseconds: timeFromTimestamp),
                     timeTo: Date(timeIntervalSince1970inMiliseconds: timeToTimestamp),
                     ownerID: ownerID,
                     ownerImageURL: ownerImageURL,
                     ownerName: ownerName,
                     specialties: specialties,
                     latitude: latitude,
                     longitude: longitude,
                     priceFrom: priceFrom,
                     address: address,
                     freeSlots: freeSlots,
                     rating: rating,
                     reviews: reviews,
                     dateCreated: Date(timeIntervalSince1970inMiliseconds: dateCreatedTimestamp),
                     eventImageURL: eventImageURL,
                     images: images,
                     attending: attendees)
    }
}

extension Event:Equatable {
    static func ==(lhs:Event, rhs:Event) -> Bool {
        return lhs.id == rhs.id
    }
}
