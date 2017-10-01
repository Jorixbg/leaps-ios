//
//  SearchEntry.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum SelectionPeriod {
    case today
    case inThreeDays
    case inFiveDays
    
    func titleForPeriod() -> String {
        switch self {
        case .today:
            return "Today"
        case .inThreeDays:
            return "Next 3 days"
        case .inFiveDays:
            return "Next 5 days"
        }
    }
    
    var timeStampInMilisecondsForPeriod: Int64 {
        let timestamp: Int64
        let dayInSeconds: Int64 = 86400
        switch self {
        case .today:
            timestamp = Date().timeIntervalSince1970Miliseconds
        case .inThreeDays:
            timestamp = Date().timeIntervalSince1970Miliseconds + 3*dayInSeconds
        case .inFiveDays:
            timestamp = Date().timeIntervalSince1970Miliseconds + 5*dayInSeconds
        }
        
        //1000 for miliseconds
        return timestamp*1000
    }
}

struct SearchEntry {
    
    static let `default` =  SearchEntry(searchTerm: "",
                                        searchDistance: 20,
                                        tags: [],
                                        selectionPeriod: .today,
                                        page: 1)
    
    var searchTerm: String
    var searchDistance: Int
    var tags: [String]
    var selectionPeriod: SelectionPeriod = .today
    var page: Int = 1
}

extension SearchEntry: Serializable {
    func toJSON() -> [String : Any] {
        var params: [String: Any] = [:]
        params["key_words"] = searchTerm
        params["distance"] = searchDistance
        params["tags"] = tags
        params["min_start_date"] = Date().timeIntervalSince1970Miliseconds
        params["max_start_date"] = selectionPeriod.timeStampInMilisecondsForPeriod
        params["limit"] = 20
        params["page"] = page
        
        if let (latitude, longitude) = UserManager.shared.currentCoordinates {
            params["my_lat"] = latitude
            params["my_lnt"] = longitude
        }
        
        return params
    }
}

extension SearchEntry: CustomStringConvertible {
    var description: String {
        return "searchTerm = \(searchTerm)\nsearchDistance = \(searchDistance)\ntags = \(tags)\nselectionPeriod = \(selectionPeriod)\nselectionPeriod miliseconds = \(selectionPeriod.timeStampInMilisecondsForPeriod)\npage = \(page)"
    }
}
