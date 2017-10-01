//
//  ActivityViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/20/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class ActivityViewModel: BaseViewModel {
    
    let event: Event
    let distanceFromCurrentLocation: String?
    
    init(event: Event, distanceFromCurrentLocation: String?) {
        self.event = event
        self.distanceFromCurrentLocation = distanceFromCurrentLocation
    }
    
    var eventTime: String {
        let formatter = DateManager.shared.calendarEventCellFormatter
        let dateAsString = formatter.string(from: event.timeFrom)
        
        return dateAsString
    }
}
