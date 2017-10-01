//
//  EventsService.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/21/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

typealias FetchEventResult = Result<Event>
typealias FetchEventResultHandler = (FetchEventResult) -> Void
typealias EventsSearchResult = Result<[EventResult]>
typealias EventsSearchResultHandler = (EventsSearchResult) -> Void
typealias TagsFetchResult = Result<[String]>
typealias TagsFetchResultHandler = (TagsFetchResult) -> Void

class EventsService {
    let networkManager: NetworkManager
    let userManager: UserManager
    
    init(networkManager: NetworkManager = NetworkManager(), userManager: UserManager = UserManager.shared) {
        self.networkManager = networkManager
        self.userManager = userManager
    }
    
    //MARK: - FEED
    func fetchFeedEvents(latitude: Double?, longitude: Double?, completion: EventsSearchResultHandler?) {
        let latitudeAsString: String
        let longitudeAsString: String
        
        if let latitude = latitude {
            latitudeAsString = String(latitude)
        } else {
            latitudeAsString = "na.na"
        }
        
        if let longitude = longitude {
            longitudeAsString = String(longitude)
        } else {
            longitudeAsString = "na.na"
        }
        
        let endPoint = "event/feed/\(latitudeAsString)/\(longitudeAsString)"
//        let endPoint = "event/feed/dummy"
        let headers = ["Content-Type": "application/json"]
//            ,"Authorization": "1111177777"]
        
        networkManager.get(path: endPoint, headers: headers) { (result) in
            var searchResults: [EventResult] = []
            switch result{
            case .success(let data):
                guard let data = data as? [String: Any] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                if let popularEevents = data["\(EventType.popular)"] as? [[String: Any]], !popularEevents.isEmpty {
                    let events = Event.buildArray(popularEevents)
                    let popularEventsResult = EventResult(type: .popular, events: events)
                    searchResults.append(popularEventsResult)
                }
                
                if let nearby = data["\(EventType.nearby)"] as? [[String: Any]], !nearby.isEmpty {
                    let events = Event.buildArray(nearby)
                    let nearbyEventsResult = EventResult(type: .nearby, events: events)
                    searchResults.append(nearbyEventsResult)
                }
                
                if let suited = data["\(EventType.suited)"] as? [[String: Any]], !suited.isEmpty {
                    let events = Event.buildArray(suited)
                    let suitedEventsResult = EventResult(type: .suited, events: events)
                    searchResults.append(suitedEventsResult)
                }
                
                completion?(Result.success(searchResults))
            case .error(let error):
                print("error fetching events = \(error)")
                completion?(Result.error(error))
            }
        }
    }
    
    //MARK: - BY TYPE
    func fetchAllEvents(of type: EventType, page: Int, latitude: Double?, longitude: Double?, completion: EventsSearchResultHandler?) {
        let endPoint: String
        
        switch type {
        case .popular, .suited:
            endPoint = "event/\(type.rawValue)/\(page)"
        case .nearby:
            let latitudeAsString: String
            let longitudeAsString: String
            
            if let latitude = latitude {
                latitudeAsString = String(latitude)
            } else {
                latitudeAsString = "na.na"
            }
            
            if let longitude = longitude {
                longitudeAsString = String(longitude)
            } else {
                longitudeAsString = "na.na"
            }
            endPoint = "event/\(type.rawValue)/\(page)/\(latitudeAsString)/\(longitudeAsString)"
        default:
            return
        }
        
//        let endPoint = "/event/\(type.rawValue)/\(page)/dummy"
        let headers = ["Content-Type": "application/json"]
        
        networkManager.get(path: endPoint, params: nil, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let data = data as? [[String: Any]] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                var searchResults: [EventResult] = []
                let events = Event.buildArray(data)
                let allEventsOfType = EventResult(type: type, events: events)
                searchResults.append(allEventsOfType)
                
                completion?(Result.success(searchResults))
            case .error(let error):
                print("error  fetching events of type \(type) with error \(error)")
            }
        }
    }
    
    //MARK: - ATTEND AND UNATTEND
    func attendEvent(eventID: Int, completion: ((Error?) -> Void)?) {
        guard let userIDString = userManager.userID,
                let userID = Int(userIDString),
                let token = userManager.authToken else {
                return
        }
        let endPoint = "event/attend"
        let headers = ["Content-Type": "application/json",
//                       "Authorization": "1111177777"]
                        "Authorization": token]
        let params = ["user_id" : userID,
                      "event_id" : eventID]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let data):
                completion?(nil)
                print("successfully signed up for an event")
            case .error(let error):
                completion?(error)
                print("error signing up to evnet \(error)")
            }
        }
    }
    
    func unattendEvent(eventID: Int, completion: ((Error?) -> Void)?) {
        let endPoint = "event/unattend"
        guard let userIDString = userManager.userID,
            let userID = Int(userIDString),
            let token = userManager.authToken else {
                return
        }
        let headers = ["Content-Type": "application/json",
//                       "Authorization": "1111177777"]
                        "Authorization": token]
        let params = ["user_id" : userID,
                      "event_id" : eventID]
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let data):
                completion?(nil)
                print("successfully signed up for an event")
            case .error(let error):
                completion?(error)
                print("error signing up to evnet \(error)")
            }
        }
    }
    
    func filterEvents(eventSearch: SearchEntry, completion: EventsSearchResultHandler?) {
        let endPoint = "event/filter"
//        let endPoint = "event/filter/dummy"
        let headers = ["Content-Type": "application/json"]
        let params = eventSearch.toJSON()
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let data = data as? [String: Any],
                    let numberOfEvents = data["total_results"] as? Int,
                    let eventsArray = data["events"] as? [[String: Any]] else {
                        //Could be returned if there are no results
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                let events = Event.buildArray(eventsArray)
                let eventResult = EventResult(type: .search, totalCount: numberOfEvents, events: events)
                completion?(Result.success([eventResult]))
            case .error(let error):
                print("filterEvents erro = \(error)")
            }
        }
    }
    
    func fetchTags(completion: TagsFetchResultHandler?) {
        let endPoint = "event/tags"
        let headers = ["Content-Type": "application/json"]
        networkManager.get(path: endPoint, headers: headers) { (result) in
            switch result {
            case .success(let tagsData):
                guard let tags = tagsData as? [String] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                completion?(Result.success(tags))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    func fetchEvent(id: Int, completion: FetchEventResultHandler?) {
        let endPoint = "event/\(id)"
        let headers = ["Content-Type": "application/json"]
        networkManager.get(path: endPoint, headers: headers) { (result) in
            switch result {
            case .success(let eventDataArray):
                guard let data = eventDataArray as? [[String: Any]],
                        let eventDaata = data.first,
                        let event = Event.fromJSON(from: eventDaata) else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                completion?(Result.success(event))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
}
