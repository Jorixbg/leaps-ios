//
//  EventManager.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/8/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class EventManager {
    static var tags: [String] = []
    
    static let shared: EventManager = EventManager()
    
    private var likedFutureEvents:[Event] = []
    private var likedPastEvents:[Event] = []
    
    func setLikedEvents(periodType: CalendarPeriodType ,events:[Event]) {
        switch periodType {
        case .past:
            self.likedPastEvents = events
        default:
            self.likedFutureEvents = events
        }
    }
    
    func add(event:Event) -> CalendarPeriodType {
        if event.date > Date() {
            if !likedFutureEvents.contains(event) {
                print("future event was liked")
                likedFutureEvents.append(event)
                
            }
            return .upcoming
        }
        else {
            if !likedPastEvents.contains(event) {
                print("past event was liked")
                likedPastEvents.append(event)
            }
            return .past
        }
    }
    func remove(id:Int) -> CalendarPeriodType? {
        if let index = likedFutureEvents.index(where: {$0.id == id}) {
            likedFutureEvents.remove(at: index)
            print("future event was unliked")
            return .upcoming
        }
        else if let index = likedPastEvents.index(where: {$0.id == id}) {
            likedPastEvents.remove(at: index)
            print("past event was unliked")
            return .past
        }
        return nil
    }
    func remove(event:Event) -> CalendarPeriodType? {
        return remove(id: event.id)
    }
    
    func isUserFollow(event:Event) -> Bool {
        return likedFutureEvents.contains(event) || likedPastEvents.contains(event)
    }
    
    func likedEvents(periodType: CalendarPeriodType) -> [Event] {
        switch periodType {
        case .past:
            return likedPastEvents
        case .upcoming:
            return likedFutureEvents
        }
    }
}
