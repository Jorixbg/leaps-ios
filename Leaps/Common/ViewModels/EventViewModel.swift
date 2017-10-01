//
//  EventViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/24/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation


enum EventDetailsRowType {
    case trainerImageAndName(String?, String)
    case timeAndDate(String)
    case specialities([String])
    case about(String)
    case location(String)
    case attendees([Attendee])
    
    var titleForType: String {
        switch self {
        case .trainerImageAndName:
            return ""
        case .timeAndDate:
            return "Time and date"
        case .specialities:
            return "Specialities"
        case .about:
            return "About"
        case .location:
            return "Location"
        case .attendees:
            return "Attendees"
        }
    }
}

struct EventDetailsSection {
    var items: [EventDetailsRowType]
}

class EventViewModel: BaseViewModel {
    
    let event: Dynamic<Event>
    var items: Dynamic<[EventDetailsRowType]> = Dynamic([])
    private let service: EventsService
    private let userManager: UserManager
    
    init(event: Event, service: EventsService, userManager: UserManager = UserManager.shared) {
        self.event = Dynamic(event)
        self.service = service
        self.userManager = userManager
        prepareRows(for: event)
    }
    
    func prepareRows(for event: Event) {
        var rows: [EventDetailsRowType] = []
        
        //setup image and name row
        let imageRelativePath = event.ownerImageURL
        let name = event.ownerName
        let trainerImageAndNameRow = EventDetailsRowType.trainerImageAndName(imageRelativePath, name)
        rows.append(trainerImageAndNameRow)
        
        //setup date and time row
        let dateFormatter = DateManager.shared.dateAndTimeDateFormatToTime
        let dateString = dateFormatter.string(from: event.date)
        let timeFormatter = DateManager.shared.dateAndTimeTimeFormatter
        let timeFromString = timeFormatter.string(from: event.timeFrom)
        let timeToString = timeFormatter.string(from: event.timeTo)
        let rowText = "\(dateString), \(timeFromString) - \(timeToString)"
        let dateAndTimeRow = EventDetailsRowType.timeAndDate(rowText)
        
        rows.append(dateAndTimeRow)
        
        //setup specialities row
        let specialitiesRow = EventDetailsRowType.specialities(event.specialties)
        rows.append(specialitiesRow)
        
        //setup about row
        let aboutRow = EventDetailsRowType.about(event.description)
        rows.append(aboutRow)
        
        //location row
        let locationRow = EventDetailsRowType.location(event.address)
        rows.append(locationRow)
        
        //attendance row
        let attendees = EventDetailsRowType.attendees(event.attending)
        rows.append(attendees)
        
        items.value = rows
    }
    
    func rowType(for indexPath: IndexPath) -> EventDetailsRowType? {
        guard indexPath.row < items.value.count else {
            return nil
        }
        
        return items.value[indexPath.row]
    }
    
    var attendees: [Attendee] {
        return event.value.attending
    }
    
    var freeSlots: String {
        return String(event.value.freeSlots)
    }
    
    var attendeesCount: String {
        return String(event.value.attending.count)
    }
    
    var loggedIn: Bool {
        return userManager.isLoggedIn
    }
    
    var ownerImageURLString: String? {
        return event.value.ownerImageURL
    }
    
    var isUserAttendee: Bool {
        guard let userIDString = userManager.userID,
            let userID = Int(userIDString)else {
            return false
        }
        
        if let _ = event.value.attending.first(where: { $0.userID == userID }) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - API calls
    func attendEvent(completion: ((Error?) -> Void)? = nil) {
        service.attendEvent(eventID: event.value.id, completion: completion)
    }
    
    func unattendEvent(completion: ((Error?) -> Void)? = nil) {
        service.unattendEvent(eventID: event.value.id, completion: completion)
    }
    
    func fetchEvents(completion: ((Error?) -> Void)? = nil) {
        let id = event.value.id
        service.fetchEvent(id: id) { [weak self] (result) in
            switch result {
            case .success(let event):
                self?.event.value = event
                self?.prepareRows(for: event)
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
}
