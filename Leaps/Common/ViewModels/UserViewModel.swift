//
//  UserViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/25/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import CoreLocation

enum UserDetailsRowType {
    case description(String)
    case events(UserViewModel)
}

//won't be needed for now as we have 1 section
struct UserDetailsSection {
    var items: [UserDetailsRowType]
}

class UserViewModel: BaseViewModel {
    
    var user: Dynamic<User>
    
    var pastAttendingEvents: [Event] = []
    var futureAttendingEvents: [Event] = []
    private let userManager: UserManager
    
    var rows: Dynamic<[UserDetailsRowType]> = Dynamic([])
    var userFullName: String {
        return "\(user.value.firstName) \(user.value.lastName)"
    }
    
    init(user: User, userManager: UserManager = UserManager.shared) {
        self.user = Dynamic(user)
        self.userManager = userManager
        var past: [Event] = []
        var upcoming: [Event] = []
        for event in user.attendingEvents {
            if event.date.compare(Date()) == .orderedAscending {
                past.append(event)
            } else {
                upcoming.append(event)
            }
        }
        
        pastAttendingEvents = past
        futureAttendingEvents = upcoming
        
        var rows: [UserDetailsRowType] = []
        
        let descriptionRow = UserDetailsRowType.description(user.description ?? "")
        rows.append(descriptionRow)
        
        let eventsRow = UserDetailsRowType.events(self)
        rows.append(eventsRow)
        
        self.rows = Dynamic(rows)
    }
    
    func rowType(for indexPath: IndexPath) -> UserDetailsRowType? {
        guard indexPath.row < rows.value.count else {
            return nil
        }
        
        return rows.value[indexPath.row]
    }
    
    func numberOfItems(for section: Int) -> Int {
        return rows.value.count
    }
    
    func numberOfItemsForAttendingUpcomingEvents(for section: Int) -> Int {
        return futureAttendingEvents.count
    }
    
    func attendingUpcomingEvent(for indexPath: IndexPath) -> Event {
        return futureAttendingEvents[indexPath.row]
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
}
