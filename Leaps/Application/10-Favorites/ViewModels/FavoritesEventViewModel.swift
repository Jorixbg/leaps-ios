//
//  FavoritesEventViewModel.swift
//  Leaps
//
//  Created by Slav Sarafski on 13/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class FavoritesEventViewModel: BaseViewModel {
    
    let service: EventsService
    
    private let userManger: UserManager
    private let eventManager: EventManager
    
    var isLoggedIn: Bool {
        return userManger.isLoggedIn
    }
    
    init(service: EventsService, userManger: UserManager = UserManager.shared, eventManager: EventManager = EventManager.shared) {
        self.service = service
        self.userManger = userManger
        self.eventManager = eventManager
    }
    
    func fetchLikedEvetns(periodType: CalendarPeriodType, completion: UserEventsResultHandler?) {
        service.fetchedLikedEvents(periodType: periodType, completion: completion)
    }
    
    func followEvent(event: Event, completion: ((Error?) -> Void)? = nil) {
        let id = event.id
        if EventManager.shared.isUserFollow(event: event) {
            service.unfollowEvent(id: id, completion: { [weak self] (error) in
                if let error = error {
                    completion?(error)
                    return
                }
                _ = self?.eventManager.remove(id: id)
                completion?(nil)
            })
        }
        else {
            service.followEvent(id: id, completion: { [weak self] (result) in
                switch result {
                case .success(let event):
                    _ = self?.eventManager.add(event: event)
                    completion?(nil)
                case .error(let error):
                    completion?(error)
                }
            })
        }
    }
    
    func numberOfSections(for type: CalendarPeriodType) -> Int {
        return 1
    }
    
    func numberOfRows(for section: Int, and type: CalendarPeriodType) -> Int {
        return eventManager.likedEvents(periodType: type).count
    }
    
    func event(for indexPath: IndexPath, with type: CalendarPeriodType) -> Event {
        return eventManager.likedEvents(periodType: type)[indexPath.row]
    }
    
    func emptyMessage(period: CalendarPeriodType) -> String {
        switch period {
        case .past:
            return "You don't have any favorite past events"
        case .upcoming:
            return "You don't have any favorite upcoming events"
        }
    }
}
