//
//  TrainerViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import CoreLocation

enum TrainerDetailsRowType {
    case specialities([String])
    case about(String, String?)
    case events(TrainerViewModel)
    
    var titleForType: String {
        switch self {
        case .specialities:
            return "Specialities"
        case .about:
            return "About"
        case .events:
            return "Events"
        }
    }
}

struct TrainerDetailsSection {
    var items: [TrainerDetailsRowType]
}

class TrainerViewModel: BaseViewModel {
    
    var traienr: Dynamic<User>
    private var userManager: UserManager
    private let maxTags = 3
    private var items: Dynamic<[TrainerDetailsRowType]> = Dynamic([])
    var upcomingAttendingPerDate: Dynamic<[Date: [Event]]> = Dynamic([:])
    var pastAttendingPerDate: Dynamic<[Date: [Event]]> = Dynamic([:])
    var attendingPerDate: Dynamic<[Date: [Event]]> = Dynamic([:])
    var hostingPerDate: Dynamic<[Date: [Event]]> = Dynamic([:])
    var hostingPast: Dynamic<[Event]> = Dynamic([])
    var hostingUpcoming: Dynamic<[Event]> = Dynamic([])
    
    init(trainer: User, userManger: UserManager = UserManager.shared) {
        self.userManager = userManger
        self.traienr = Dynamic(trainer)
        var rows: [TrainerDetailsRowType] = []
        
        traienr.value.specialties.flatMap {
            let specialtiesRow = TrainerDetailsRowType.specialities($0)
            rows.append(specialtiesRow)
        }
        
        let aboutRow = TrainerDetailsRowType.about(String(traienr.value.age), traienr.value.description)
        rows.append(aboutRow)
        
        let eventsRow = TrainerDetailsRowType.events(self)
        rows.append(eventsRow)
        
        items.value = rows
        
        filterEvents(for: trainer)
    }
    
    func filterEvents(for user: User) {
        var upcoming: [Date: [Event]] = [:]
        var past: [Date: [Event]] = [:]
        var attending: [Date: [Event]] = [:]
        for event in user.attendingEvents {
            if event.date.compare(Date()) == .orderedAscending {
                add(event: event, toDict: &past)
            } else {
                add(event: event, toDict: &upcoming)
            }
            
            add(event: event, toDict: &attending)
        }
        
        var hosting: [Date: [Event]] = [:]
        var hostingPast: [Event] = []
        var hostingUpcoming: [Event] = []
        if let hostingEvents = user.hostingEvents {
            for event in hostingEvents {
                add(event: event, toDict: &hosting)
                if event.date.compare(Date()) == .orderedAscending {
                    hostingPast.append(event)
                } else {
                    hostingUpcoming.append(event)
                }
            }
        }
        
        self.hostingPast.value = hostingPast
        self.hostingUpcoming.value = hostingUpcoming
        self.upcomingAttendingPerDate.value = upcoming
        self.pastAttendingPerDate.value = past
        self.attendingPerDate.value = attending
    }
    
    var trainerFullName: String {
        return "\(traienr.value.firstName) \(traienr.value.lastName)"
    }
    
    var trainerUsername: String? {
        return traienr.value.username
    }
    
    var tags: String? {
        guard let tags = traienr.value.specialties else {
            return nil
        }
        var allTags: String = ""
        for (index, tag) in tags.enumerated() {
            guard index < maxTags else {
                break
            }
            
            allTags += "\(tag) "
            if index < maxTags - 1 {
               allTags += ", "
            }
        }
        
        return allTags
    }
    
    var trainerImageURLString: String {
        return traienr.value.imageURL ?? ""
    }
    
    var numberOfEventsHosting: String {
        let numberOfEvents = traienr.value.hostingEvents?.count ?? 0
        
        return String(numberOfEvents)
    }
    
    func rowType(for indexPath: IndexPath) -> TrainerDetailsRowType? {
        guard indexPath.row < items.value.count else {
            return nil
        }
        
        return items.value[indexPath.row]
    }
    
    func numberOfItems(for section: Int) -> Int {
        return items.value.count
    }
    
    func numberOfItemsForHostingUpcomingEvents(for section: Int) -> Int {
        return hostingUpcoming.value.count
    }
    
    func hostingUpcomingEvent(for indexPath: IndexPath) -> Event {
        return hostingUpcoming.value[indexPath.row]
    }
    
    func distance(from event: Event) -> String? {
        let latitude = event.latitude
        let longitude = event.longitude
        let eventLocaiton = CLLocation(latitude: latitude, longitude: longitude)
        
        guard let currentLocation = userManager.currentLocation else {
            return nil
        }
        
        let distance = currentLocation.distance(from: eventLocaiton)
        
        return "\(String(Int(distance/1000))) km"
    }
    
    func add(event: Event, toDict: inout [Date: [Event]]) {
        if toDict[event.date] == nil {
            toDict[event.date] = []
        }
        
        toDict[event.date]?.append(event)
    }
}
