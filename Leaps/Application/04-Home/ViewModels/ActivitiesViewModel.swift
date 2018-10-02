//
//  ActivitiesViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/14/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import CoreLocation

class ActivitiesViewModel: NSObject, BaseViewModel {
    
    typealias Coordinates = (Double, Double)
    fileprivate let service: EventsService
    fileprivate let userService: UserService
    fileprivate var eventsType: EventType
    fileprivate var initialEventSearchType: EventType
    fileprivate var seeAllCurrentPage: Int = 1
    fileprivate let locationManager = CLLocationManager()
    fileprivate let userManager: UserManager
    fileprivate let eventManager: EventManager
    
    var hasCurrentLocation: Dynamic<Bool> = Dynamic(false)
    var eventSearchResults: Dynamic<[EventResult]> = Dynamic([])
    
    fileprivate var searchEntry: SearchEntry?
    fileprivate var isRequestRunning: Bool = false
    fileprivate var requestingLocationForEventsFetching = false
    
    var refreshCompletionBlock: ((Error?) -> Void)? = nil
    
    init(service: EventsService,
         userService: UserService,
         eventSearchType: EventType,
         userManager: UserManager = UserManager.shared) {
        self.service = service
        self.userService = userService
        self.eventsType = eventSearchType
        
        // needed for when clear filter is pressed
        self.initialEventSearchType = eventSearchType
        self.userManager = userManager
        self.eventManager = EventManager.shared
        super.init()
        
        userManager.hasCurrentLocation.bind { [weak self] (hasCurrentLocation) in
            self?.hasCurrentLocation.value = hasCurrentLocation
        }
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted, .denied:
                AlertManager.shared.showWarningMessage(message: "Location Services Disabled! Please enable Location Services in Settings")
                break
            case .authorizedAlways, .authorizedWhenInUse:
                //locationManager.requestLocation()
                locationManager.startUpdatingLocation()
                print("Access")
            }
        } else {
            AlertManager.shared.showWarningMessage(message: "Location Services is turned off! Please turn on Location Services and try again")
        }
    }
    
    //used for prfile preview "Show past"
    convenience init(service: EventsService,
                     userService: UserService,
                     prefetchedEvents: EventResult,
                     userManager: UserManager = UserManager.shared) {
        self.init(service: service, userService: userService, eventSearchType: prefetchedEvents.type)
        
        eventSearchResults.value = [prefetchedEvents]
    }
    
    func navigationTitle() -> String {
        return eventsType.navigationTitle()
    }
    
    fileprivate func requestFeedEvents(with latitude: Double?, and longitude: Double?, completion: ((Error?) -> Void)? = nil) {
        service.fetchFeedEvents(latitude: latitude, longitude: longitude) { [weak self] result in
            self?.isRequestRunning = false
            switch result {
            case .success(let eventResults):
                self?.eventSearchResults.value = eventResults
                completion?(nil)
            case .error(let error):
                completion?(error)
                break
            }
        }
    }
    
    func refreshEvents(completion: ((Error?) -> Void)? = nil) {
        switch eventsType {
        case .search:
            guard let searchEntry = searchEntry else {
                completion?(nil)
                return
            }
            search(searchEntry: searchEntry, isNewSearch: false, completion: completion)
            break
        default:
            fetchEvents(completion: completion)
            break
        }
    }
    
    func fetchEvents(completion: ((Error?) -> Void)? = nil) {
        //called reset filtered events
        if eventsType == .search {
            seeAllCurrentPage = 1
            eventsType = initialEventSearchType
        }
        
        isRequestRunning = true
        switch eventsType {
        case .all:
            print("started location")
            //this will need improvement when there is a decision on when the events should be updated.
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    requestFeedEvents(with: nil, and: nil, completion: completion)
                case .authorizedAlways, .authorizedWhenInUse:
                    guard !requestingLocationForEventsFetching else {
                        completion?(nil)
                        return
                    }
                    refreshCompletionBlock = completion
                    requestingLocationForEventsFetching = true
                    //locationManager.requestLocation()
                    locationManager.startUpdatingLocation()
                }
            } else {
                requestFeedEvents(with: nil, and: nil, completion: completion)
                print("Location services are not enabled")
            }
            
        case .nearby, .popular, .suited:
            //workaround after pagination was introduced
            let latitude = userManager.currentCoordinates?.0
            let longitude = userManager.currentCoordinates?.1
            service.fetchAllEvents(of: eventsType, page: seeAllCurrentPage, latitude: latitude, longitude: longitude) { [weak self] result in
                guard let strongSelf = self else {
                    completion?(nil)
                    return
                }
                strongSelf.isRequestRunning = false
                switch result {
                case .success(let eventResults):
                    guard let newEvents = eventResults.first?.events, !newEvents.isEmpty
                        else {
                            completion?(nil)
                            return
                    }
                    let eventResult = EventResult(type: strongSelf.eventsType, events: newEvents)
                    if strongSelf.seeAllCurrentPage == 1 {
                        strongSelf.eventSearchResults.value = [eventResult]
                    } else {
                        guard var existing = strongSelf.eventSearchResults.value.first else {
                            return
                        }
                        
                        existing.events.append(contentsOf: eventResult.events)
                        strongSelf.eventSearchResults.value = [existing]
                    }
                    
                    strongSelf.seeAllCurrentPage += 1
                    completion?(nil)
                case .error(let error):
                    print(error)
                    completion?(error)
                    break
                }
            }
            
        //use search(searchEntry: SearchEntry)
        case .search:
            isRequestRunning = false
        //currently using the vents fetched from the user
        case .attendingPast, .hostingPast:
            isRequestRunning = false
        }
    }
    
    func fetchLikedEvents(completion:UserEventsResultHandler?) {
        service.fetchedLikedEvents(periodType: .upcoming, completion: completion)
    }
    
    var numberOfSections: Int {
        return eventSearchResults.value.count
    }
    
    func numberOfitems(for section: Int) -> Int {
        guard section < eventSearchResults.value.count else {
            return 0
        }
        
        return eventSearchResults.value[section].events.count
    }
    
    func eventResultForSection(section: Int) -> EventResult? {
        guard section < eventSearchResults.value.count else {
            return nil
        }
        
        return eventSearchResults.value[section]
    }
    
    func eventForIndexPath(indexPath: IndexPath, bySection section:Bool = false) -> Event? {
        guard indexPath.section < eventSearchResults.value.count
            && indexPath.row < eventSearchResults.value[indexPath.section].events.count else {
            return nil
        }
        
        return eventSearchResults.value[indexPath.section].events[indexPath.row]
    }
    
    func allEvents(filtered: Bool = false) -> [Event] {
        var allEvents = [Event]()
        for eventResult in eventSearchResults.value {
            if filtered {
                for event in eventResult.events {
                    if !allEvents.contains(event) {
                        allEvents.append(event)
                    }
                }
            }
            else {
                allEvents = allEvents + eventResult.events
            }
        }
        return allEvents
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
    
    func loadMore(currentActivity: IndexPath, completion: ((Error?) -> Void)?) {
        
        switch eventsType {
            //all has no pagination. Attening and hosting past don't make requests, but rather used the events feteched with the user.
        case .all, .attendingPast, .hostingPast:
            break
        case .nearby, .popular, .suited:
            let isLastActivity = currentActivity.row == eventSearchResults.value[currentActivity.section].events.count - 1
            guard isLastActivity && !isRequestRunning else {
                return
            }
            fetchEvents()
        case .search:
            var hasReachedTotalResults = false
            if currentActivity.section >= eventSearchResults.value.count {
                hasReachedTotalResults = eventSearchResults.value[currentActivity.section].events.count < eventSearchResults.value[currentActivity.section].totalCount
            }
            guard let searchEntry = searchEntry,
                !isRequestRunning
                    && hasReachedTotalResults
                else {
                    return
            }
            
            search(searchEntry: searchEntry, isNewSearch: false, completion: completion)
        }
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
}
    
extension ActivitiesViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let location = locations.first else {
            refreshCompletionBlock?(nil)
            refreshCompletionBlock = nil
            return
        }
        
        userManager.currentLocation = location
        
        guard requestingLocationForEventsFetching else {
            refreshCompletionBlock?(nil)
            refreshCompletionBlock = nil
            return
        }
        print("got location")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        requestFeedEvents(with: latitude, and: longitude, completion: refreshCompletionBlock)
        requestingLocationForEventsFetching = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed updating location for activity")
    }
}
    
//search + pagination
extension ActivitiesViewModel {
    func search(searchEntry: SearchEntry, isNewSearch: Bool, completion: ((Error?) -> Void)?) {
        //make sure request is not Running
        guard isRequestRunning == false else {
            completion?(nil)
            return
        }
        eventsType = .search
        //if it is the firsh search result
        if isNewSearch {
            self.searchEntry = searchEntry
        //for pagination
        } else {
            self.searchEntry?.page += 1
        }
        
        isRequestRunning = true
        service.filterEvents(eventSearch: searchEntry) { [weak self] (result) in
            self?.isRequestRunning = false
            switch result {
            case .success(let eventResults):
                if isNewSearch {
                    self?.eventSearchResults.value = eventResults
                } else {
                    guard let newEvents = eventResults.first?.events,
                        var existing = self?.eventSearchResults.value.first else {
                        completion?(nil)
                        return
                    }
                    //append the freshly returned events
                    existing.addEvents(events: newEvents)
                    self?.eventSearchResults.value = [existing]
                }
                completion?(nil)
            case .error(let error):
                //remove the added page if the the request failed
                self?.searchEntry?.page -= 1
                completion?(error)
                print("ActivitiesViewModel search error = \(error)")
            }
        }
    }
}
