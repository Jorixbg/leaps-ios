//
//  EventCreateData.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/17/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

final class EventCreateData {
    var title: String?
    var description: String?
    var date: Date?
    var timeFrom: Date?
    var timeTo: Date?
    var ownerID: Int?
    var coordLatitude: Double?
    var coordLongitude: Double?
    var priceFrom: Int?
    var address: String?
    var freeSlots: Int?
    var dateCreated: Date?
    var tags: [String] = []
    
    var imagesToUpload: [UplodableImage] = []
    
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

extension EventCreateData: Serializable {
    func toJSON() -> [String : Any] {
        guard let title = title,
                let description = description,
                let date = date,
                let timeFrom = timeFrom,
                let timeTo = timeTo,
                let ownerID = ownerID,
                let coordLatitude = coordLatitude,
                let coordLongitude = coordLongitude,
                let priceFrom = priceFrom,
                let address = address,
                let freeSlots = freeSlots,
                let dateCreated = dateCreated else {
                print("failed event create data to json")
                return [:]
        }
        
        //timeFrom is only hours so we need to take the rest of the data from date of the event
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let timeComponents = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: timeFrom)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        guard let timeFromDate = gregorian.date(from: components) else {
            print("failed genereting time from date")
            return [:]
        }
        print("time from date = \(timeFromDate)")
        
        return ["title": title,
                "description": description,
                "date": date.timeIntervalSince1970Miliseconds,
                "time_from": timeFromDate.timeIntervalSince1970Miliseconds,
                "time_to": timeTo.timeIntervalSince1970Miliseconds,
                "owner_id": ownerID,
                "coord_lat": coordLatitude,
                "coord_lnt": coordLongitude,
                "price_from": priceFrom,
                "address": address,
                "free_slots": freeSlots,
                "date_created": dateCreated.timeIntervalSince1970Miliseconds,
                "tags": tags]
    }
}
