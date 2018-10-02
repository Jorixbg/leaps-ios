//
//  EventCreateData.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/17/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum EventCreateStep: Int {
    case info = 0
    case map = 1
    case priceAndSlots = 2
    case timeAndDate = 3
}


enum EventCreateError: String {
    case title = "Please enter title"
}

final class EventCreateData {
    var title: String?
    var description: String?
    var timeFrom: Date?
    var timeTo: Date?
    var ownerID: Int?
    var coordLatitude: Double?
    var coordLongitude: Double?
    var priceFrom: Int = 0
    var address: String?
    var freeSlots: Int?
    var dateCreated: Date?
    var repeating: Bool = false
    var frequency: Frequency? = .everyday
    var tags: [String] = []
    var activities: [Activity] = []
    
    var imagesToUpload: [UplodableImage] = []
    
    func listPropertiesWithValues(reflect: Mirror? = nil) {
        let mirror = reflect ?? Mirror(reflecting: self)
        if mirror.superclassMirror != nil {
            self.listPropertiesWithValues(reflect: mirror.superclassMirror)
        }
        
        for (index, attr) in mirror.children.enumerated() {
            if let property_name = attr.label as String? {
                print("\(mirror.description) \(index): \(property_name) = \(attr.value)")
            }
        }
    }
    
    func validate(step:Int) -> Validation<ValidationType> {
        switch step {
        case EventCreateStep.info.rawValue:
            if imagesToUpload.count == 0 { return .error(.createEvent(.imageSelection)) }
            if title == nil || title == ""{ return .error(.createEvent(.title)) }
            if description == nil || description == "" { return .error(.createEvent(.description)) }
            if tags.count == 0 { return .error(.createEvent(.workoutType([]))) }
            return Validation.success()
        case EventCreateStep.map.rawValue:
            if address == nil || address == ""{ return .error(.createEvent(.eventLocationMap)) }
            return Validation.success()
        case EventCreateStep.priceAndSlots.rawValue:
            if freeSlots == nil || freeSlots == 0 { return .error(.createEvent(.freeSlots)) }
            return Validation.success()
        case EventCreateStep.timeAndDate.rawValue:
            //if date == nil { return .error(.createEvent(.date)) }
            //if timeFrom == nil { return .error(.createEvent(.time)) }
            return Validation.success()
        default:
            return Validation.success()
        }
    }
}

extension EventCreateData: Serializable {
    func toJSON() -> [String : Any] {
        guard let title = title,
                let description = description,
                let ownerID = ownerID,
                let coordLatitude = coordLatitude,
                let coordLongitude = coordLongitude,
                let address = address,
                let freeSlots = freeSlots,
                let dateCreated = dateCreated else {
                print("failed event create data to json")
                return [:]
        }
        
        let start = timeFrom ?? Date.add(days: 0, hours: 1)
        let end = timeTo ?? Date.add(days: 0, hours: 2)
        var frequency = ""
        var dates:[[String : Any]] = []
        if let fr = self.frequency {
            frequency = fr.rawValue.lowercased()
            
            for activity in activities {
                if fr.days().contains(activity.day) {
                    let period = activity.day.rawValue.lowercased()
                    let timeFrom = activity.jsonStartDate()
                    let timeTo = activity.jsonEndDate()
                    dates.append(["period": period, "start": timeFrom, "end": timeTo])
                }
            }
        }
        
        var json = ["title": title,
                    "description": description,
                    "owner_id": ownerID,
                    "coord_lat": coordLatitude,
                    "coord_lnt": coordLongitude,
                    "price_from": priceFrom,
                    "address": address,
                    "free_slots": freeSlots,
                    "date_created": dateCreated.timeIntervalSince1970Miliseconds,
                    "tags": tags] as [String : Any]
        
        if repeating {
            json["repeat"] = repeating
            json["frequency"] = frequency
            json["dates"] = dates
            json["start"] = start.timeIntervalSince1970Miliseconds
            json["end"] = end.timeIntervalSince1970Miliseconds
        }
        else {
            json["date"] = start.timeIntervalSince1970Miliseconds
            json["time_from"] = start.timeIntervalSince1970Miliseconds
            json["time_to"] = end.timeIntervalSince1970Miliseconds
        }
        
        return json
    }
}
