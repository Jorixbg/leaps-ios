//
//  Date+TimeFromMIliseconds.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/17/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

extension Date {
    var timeIntervalSince1970Miliseconds: Int64 {
        return Int64(timeIntervalSince1970)*1000
    }
    
    init(timeIntervalSince1970inMiliseconds: Int64) {
        let timeInSeconds = timeIntervalSince1970inMiliseconds / 1000
        self.init(timeIntervalSince1970: TimeInterval(timeInSeconds))
    }
    
    static func add(days: Int = 0, hours: Int = 0) -> Date {
        var date = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        date = Calendar.current.date(byAdding: .hour, value: hours, to: date) ?? Date()
        return date
    }
}
