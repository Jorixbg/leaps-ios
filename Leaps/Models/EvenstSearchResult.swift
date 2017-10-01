//
//  EventSearchResult.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum EventType: String {
    case popular
    case nearby
    case suited
    case all
    case search
    case hostingPast
    case attendingPast
    
    func sectionHeaderTitle(text: String? = nil) -> String {
        switch self {
        case .popular:
            return "POPULAR EVENTS"
        case .nearby:
            return "EVENTS NEARBY"
        case .suited:
            return "SELECTED EVENTS FOR YOU"
        case .all:
            return ""
        case .search:
            guard let text = text else {
                return "FILTERED EVENTS"
            }
            
            return "\(text) FILTERED EVENTS"
        default:
            return ""
        }
    }
    
    func actionLabelText() -> String {
        switch self {
        case .search:
            return "CLEAR FILTER"
        default:
            return "SEE ALL"
        }
    }
    
    func navigationTitle() -> String {
        switch self {
        case .attendingPast, .hostingPast:
            return "PAST EVENTS"
        default:
            return ""
        }
    }
}

struct EventResult {
    let type: EventType
    let totalCount: Int
    var events: [Event]
    
    init(type: EventType, totalCount: Int? = nil, events: [Event]) {
        self.type = type
        switch type {
            //because of the pagination
        case .search:
            self.totalCount = totalCount ?? events.count
        default:
            self.totalCount = events.count
        }
        
        self.events = events
    }
    
    mutating func addEvents(events: [Event]){
        self.events.append(contentsOf: events)
    }
}

