//
//  FollowingViewModel.swift
//  Leaps
//
//  Created by Slav Sarafski on 12/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class FollowingViewModel: BaseViewModel {
    
    let userManager: UserManager
    
    var event: Dynamic<Event>? = nil
    private let eventService:EventsService
    
    var user: Dynamic<User>? = nil
    private let userService:UserService
    
    init(event: Event, userService:UserService, service: EventsService, userManager: UserManager = UserManager.shared) {
        self.event = Dynamic(event)
        self.eventService = service
        self.userManager = userManager
        self.userService = userService
    }
    
    init(user: User, userService:UserService, service: EventsService, userManager: UserManager = UserManager.shared) {
        self.user = Dynamic(user)
        self.eventService = service
        self.userManager = userManager
        self.userService = userService
    }
    
    func viewControllerTitle() -> String {
        if event != nil {
            return "Attendance".uppercased()
        }
        if user != nil {
            return "Followers".uppercased()
        }
        return ""
    }
    
    func followers() -> [Attendee] {
        if let attendees = event?.value.attending {
            return attendees
        }
        
        if let attendees = user?.value.followedBy {
            return attendees
        }
        
        return []
    }
    
    func update(completion: ((Error?) -> Void)? = nil) {
        if let event = self.event {
            eventService.fetchEvent(id: event.value.id, completion: { [weak self] (result) in
                    switch result {
                    case .success(let event):
                        self?.event?.value = event
                        
                        completion?(nil)
                    case .error(let error):
                        completion?(error)
                    }
                })
        }
        if let userID = self.user?.value.userID {
            userService.fetchUser(forUserWith: String(userID), completion: { [weak self] (result) in
                switch result {
                case .success(let user):
                    self?.user?.value = user
                    
                    completion?(nil)
                case .error(let error):
                    completion?(error)
                }
            })
        }
    }
    
    //MARK: - API calls
    func followUser(user:Attendee, completion: ((Error?) -> Void)? = nil) {
        if user.followed {
            userService.unfollow(userID: user.userID, completion: { [weak self] (result) in
                self?.update(completion: completion)
            })
        }
        else {
            userService.follow(userID: user.userID, completion: { [weak self] (result) in
                self?.update(completion: completion)
            })
        }
        
    }
}
