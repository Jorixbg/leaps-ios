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
typealias FetchEventReviewsResult = Result<[Review]>
typealias FetchEventReviewsResultHandler = (FetchEventReviewsResult) -> Void

class EventsService {
    let networkManager: NetworkManager
    let userManager: UserManager
    
    init(networkManager: NetworkManager = NetworkManager(), userManager: UserManager = UserManager.shared) {
        self.networkManager = networkManager
        self.userManager = userManager
    }
    
    //MARK: - FEED
    func fetchFeedEvents(latitude: Double?, longitude: Double?, completion: EventsSearchResultHandler?) {
        let token = userManager.authToken ?? ""
        
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
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        
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
        guard let token = userManager.authToken else {
            return
        }
        
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
        
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        
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
                        "Authorization": token]
        let params = ["user_id" : userID,
                      "event_id" : eventID]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(_):
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
                        "Authorization": token]
        let params = ["user_id" : userID,
                      "event_id" : eventID]
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(_):
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
        let token = userManager.authToken ?? ""
        let endPoint = "event/\(id)"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
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
    
    func followEvent(id: Int, completion: FetchEventResultHandler?) {
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let endPoint = "event/follow"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        let params = ["event_id" : id]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let eventDataArray):
                guard let eventData = eventDataArray as? [String: Any],
                      let event = Event.fromJSON(from: eventData) else {
                        completion?(Result.error(LeapsError.deserializing))
                        return
                }
                
                completion?(Result.success(event))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    func unfollowEvent(id: Int, completion: ((Error?)->Void)?) {
        guard let token = userManager.authToken else {
            completion?(LeapsError.missingToken)
            return
        }
        
        let endPoint = "event/unfollow"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        let params = ["event_id" : id]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success( _):
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    //MARK: - FETCH LIKED EVENTS
    func fetchedLikedEvents(periodType: CalendarPeriodType, completion: UserEventsResultHandler?){
        
        let endPoint = "event/following/\(periodType == .past ? "past" : "future")"
        
        //TODO: uncomment for live
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        
        
        networkManager.get(path: endPoint, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let eventsData = data as? [[String: Any]] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                let events = Event.buildArray(eventsData)
                EventManager.shared.setLikedEvents(periodType: periodType, events: events)
                
                completion?(Result.success(events))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    //MARK: - FETCH COMMENTS EVENT
    func fetchedEventReviews(id:Int, page:Int, completion: FetchEventReviewsResultHandler?){
        
        let endPoint = "/event/comments/\(id)/\(page)/10"
        
        //TODO: uncomment for live
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        
        
        networkManager.get(path: endPoint, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let reviewsData = data as? [[String: Any]] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                let reviews = Review.buildArray(reviewsData)
                
                completion?(Result.success(reviews))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    func rateEvent(id: Int, rating:Int, comment:String, image:UplodableImage?, completion: ((Result<Int>) -> Void)?) {
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let endPoint = "event/rate"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        let dateCreated = Date().timeIntervalSince1970
        let params = ["event_id" : id, "rating" : rating, "comment" : comment, "date_created" : dateCreated] as [String : Any]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
                case .success(let rateResult):
                    if  let dictionary = rateResult as? [String: Int],
                        let rateID = dictionary["rate_id"],
                        let image = image {
                        completion?(Result.success(rateID))
                        self.upload(imageData: image, rateID: rateID)
                        return
                    }
                    completion?(Result.success(-1))
                case .error(let error):
                    completion?(Result.error(error))
            }
        }
    }
    
    //MARK: - UPLOAD RATE PICTURE
    func upload(imageData: UplodableImage, rateID: Int) {
        guard let token = userManager.authToken else {
            return
        }
        
        let endPoint: String = "pic/rate"
        let params: [String: String] = ["rate_id": "\(rateID)"]
        
        let headers = ["Authorization": token]
        
        networkManager.upload(imageData: imageData.imageData,
                              toUrl: endPoint,
                              usingMethod: .post,
                              withParams: params,
                              withHeaders: headers)
    }
}
