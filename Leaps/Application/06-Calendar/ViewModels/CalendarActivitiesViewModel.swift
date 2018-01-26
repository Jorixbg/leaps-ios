//
//  CalendarActivitiesViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum UserProfileType {
    case user
    case trainer
}

class CalendarActivitiesViewModel: BaseViewModel {
    
    let service: UserService
    var userType: Dynamic<UserProfileType>
    
    var events: Dynamic<[(key: Date, value: [Event])]> = Dynamic([])
    fileprivate var nextPage = 1
    private let userManger: UserManager
    
    var hasFinishedFetching: Dynamic<Bool> = Dynamic(true)
    
    var isLoggedIn: Bool {
        return userManger.isLoggedIn
    }
    
    init(service: UserService, type: UserProfileType, userManger: UserManager = UserManager.shared) {
        self.service = service
        self.userType = Dynamic(type)
        self.userManger = userManger
    }
    
    private static func append(content: [Date: [Event]],to initialArray: Dynamic<[(key: Date, value: [Event])]>) -> Dynamic<[(key: Date, value: [Event])]> {
        //didn't work with > for some reaons so i did it < and reversed #notenoughtime
        let freshContent = content.sorted(by: { $0.key < $1.key }).reversed()
        var resultArray = initialArray.value
        for dateAndEvent in freshContent {
            if let index = resultArray.index(where: {
                Calendar.current.compare($0.0, to: dateAndEvent.key, toGranularity: .day) == .orderedSame
            }) {
                resultArray[index].value.append(contentsOf: dateAndEvent.value)
            } else {
                resultArray.append(dateAndEvent)
            }
        }
        
        return Dynamic(resultArray)
    }
    
    func loadMore(indexPath: IndexPath,
                  forEventType type: UserCalendarType,
                  andTimePeriodType timePeriodType: CalendarPeriodType,
                  completion: ((Error?) -> Void)? = nil) {
        guard hasFinishedFetching.value else {
            return
        }
        
        guard indexPath.section == events.value.count - 1 &&
            indexPath.row == events.value[indexPath.section].value.count - 1 else {
                return
        }
        
        fetchUserEvetns(page: nextPage,
                        userCalndarType: type,
                        periodType: timePeriodType,
                        completion: completion)
    }
    
    func fetchUserEvetns(page: Int,
                         userCalndarType: UserCalendarType,
                         periodType: CalendarPeriodType,
                         completion: ((Error?) -> Void)?) {
        guard hasFinishedFetching.value == true else {
            return
        }
        
        hasFinishedFetching.value = false
        
        guard let idString = userManger.userID,
                let userID = Int(idString) else {
            return
        }
        
        service.fetchEvents(userID: userID, userCalndarType: userCalndarType, periodType: periodType, page: page) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let fetchedEvents):
                print("fetchedEvents =\(fetchedEvents)")
                var newEventsPerDate: [Date: [Event]] = [:]
                
                //if first page it will probably be a new search. Remove current content.
                if page == 1 {
                    strongSelf.events.value.removeAll()
                }
                
                //last page reached when we get empty array
                guard fetchedEvents.count > 0 else {
                    break
                }
                
                for event in fetchedEvents {
                    strongSelf.add(event: event, toDict: &newEventsPerDate)
                }

                strongSelf.events.value = CalendarActivitiesViewModel.append(content: newEventsPerDate, to: strongSelf.events).value
                
                completion?(nil)
                strongSelf.nextPage = page + 1
                
            case .error(let error):
                
                completion?(error)
            }
            
            //this will trigger table view reload data
            strongSelf.hasFinishedFetching.value = true
        }
    }
    
    func add(event: Event, toDict: inout [Date: [Event]]) {
        if toDict[event.date] == nil {
            toDict[event.date] = []
        }
        
        toDict[event.date]?.append(event)
    }
    
    func numberOfSections(for type: CalendarPeriodType) -> Int {
        return events.value.count
    }
    
    func numberOfRows(for section: Int, and type: CalendarPeriodType) -> Int {
        return events.value[section].value.count
    }

    func titleForHeader(for section: Int, with type: CalendarPeriodType) -> String {
        let formatter = DateManager.shared.calendarEventHeaderFormatter
        return formatter.string(from: events.value[section].key)
    }
    
    func event(for indexPath: IndexPath, with type: CalendarPeriodType) -> Event {
        return events.value[indexPath.section].value[indexPath.row]
    }
}
