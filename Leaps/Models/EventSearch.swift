//
//  EventSearch.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

struct Search {
    let address: String
    let latitude: Double?
    let longitude: Double?
    let distance: Int
    let minPrice: Int
    let maxPrice: Int
    let tags: [String]
    let minStartDate: Date
    let maxStartDate: Date
}

extension Search: Serializable {
    func toJSON() -> [String : Any] {
        var dict: [String: Any] = [:]
        dict["address"] = address
        longitude.flatMap {
            dict["my_lnt"] = $0
        }
        latitude.flatMap {
            dict["my_lat"] = $0
        }
    
        dict["distance"] = distance
        dict["min_price"] = minPrice
        dict["max_price"] = maxPrice
        dict["tags"] = tags
        
        let formatter = DateManager.shared.searchDateFormatter
        let minDate = formatter.string(from: minStartDate)
        let maxDate = formatter.string(from: maxStartDate)
        dict["min_start_date"] = minDate
        dict["max_start_date"] = maxDate
        
        return dict
    }
}
