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
    case followers([Attendee])
    case events(UserViewModel)
}

//won't be needed for now as we have 1 section
struct UserDetailsSection {
    var items: [UserDetailsRowType]
}

class UserViewModel: BaseViewModel {
    
    var user: Dynamic<User?>
    private let service: UserService = UserService()
    
    var pastAttendingEvents: [Event] = []
    var futureAttendingEvents: [Event] = []
    private let userManager: UserManager
    
    var rows: Dynamic<[UserDetailsRowType]> = Dynamic([])
    var userFullName: String {
        if let user = user.value {
            return "\(user.firstName) \(user.lastName)"
        }
        return ""
    }
    
    var username: String {
        if let user = user.value {
            return user.username
        }
        return ""
    }
    
    init(simpleUser:Attendee, userManager: UserManager = UserManager.shared) {
        self.user = Dynamic(nil)
        self.userManager = userManager
        self.fetchUser(id: simpleUser.userID)
    }
    
    init(user: User, userManager: UserManager = UserManager.shared) {
        self.user = Dynamic(user)
        self.userManager = userManager
        self.setupRows(user: user)
    }
    
    func setupRows(user:User) {
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
        
        if let description = user.description {
            let descriptionRow = UserDetailsRowType.description(description)
            rows.append(descriptionRow)
        }
        
        if  let followers = user.followedBy,
            followers.count > 0 {
            let followers = UserDetailsRowType.followers(followers)
            rows.append(followers)
        }
        
        let eventsRow = UserDetailsRowType.events(self)
        rows.append(eventsRow)
        
        self.rows = Dynamic(rows)
    }
    
    func fetchUser(id:Int, completion: ((Error?) -> Void)? = nil) {
       service.fetchUser(forUserWith: String(id)) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.setupRows(user: user)
                self?.user.value = user
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func followAction(completion: ((Error?) -> Void)? = nil) {
        guard let userID = user.value?.userID else {
                return
        }
        if isUserFollowed(){
            unfollowUser(id: userID)
        }
        else {
            followUser(id: userID)
        }
    }
    
    func followUser(id:Int, completion: ((Error?) -> Void)? = nil) {
        service.follow(userID: id) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.setupRows(user: user)
                self?.user.value = user
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func unfollowUser(id:Int, completion: ((Error?) -> Void)? = nil) {
        service.unfollow(userID: id) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.setupRows(user: user)
                self?.user.value = user
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func isUserFollowed() -> Bool {
        guard let userID = userManager.userID else {
            return false
        }
        return user.value?.followedBy?.contains(where: {String($0.userID) == userID}) ?? false
    }
    
    func isLoggedUser() -> Bool {
        guard   let userID = userManager.userID,
                let selfUserID = user.value?.userID else {
            return false
        }
        return userID == String(selfUserID)
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
