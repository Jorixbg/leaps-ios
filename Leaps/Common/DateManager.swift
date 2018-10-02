//
//  DateManager.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class DateManager {
    
    static let shared: DateManager = DateManager()
    
    let searchDateFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "yyyy-MM-dd")
    }()
    
    let longDateFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "yyyy-MM-dd hh:mm")
    }()
    
    let activityCellDateFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "E d MMM, HH:mm")
    }()
    
    let dateAndTimeDateFormatToTime: DateFormatter = {
        return DateManager.createFormatter(format: "E, d MMM yyyy")
    }()
    
    let dateAndTimeTimeFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "HH:mm")
    }()

    let calendarEventHeaderFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "MMMM dd")
    }()
    
    let calendarEventCellFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "E, HH:mm")
    }()
    
    private static func createFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
//        formatter.locale = Locale.current
        return formatter
    }
    
    let createEventStandardCellDateFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "dd.MM.yyyy")
    }()
    
    let createEventStandardCellTimeFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "hh:mm a")
    }()

    let registerBirthdayFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "dd-MM-yyyy")
    }()
    
    let thanksPopupFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "EEE dd MMMM")
    }()
    
    let timeFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "HH:mm")
    }()
    
    let weekdayFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "EEEE")
    }()
    
    let previewFormatter: DateFormatter = {
        return DateManager.createFormatter(format: "dd MMM yyyy, HH:mm")
    }()
    
    func relativeDateStringForDate(date: Date?) -> String? {
        guard let date = date else {
            return nil
        }
        let todayDate = Date()
        let components = Calendar.current.dateComponents([.day, .weekday], from: date, to: todayDate)
        let dateFormatter = DateManager.shared.createEventStandardCellDateFormatter
        let timeFormatter = DateManager.shared.timeFormatter
        let weekdayFormatter = DateManager.shared.weekdayFormatter
        
        if components.day! > 7 {
            return dateFormatter.string(from:date)
        } else if (components.day! > 0) {
            if components.day! > 1 {
                return weekdayFormatter.string(from: date)
            } else {
                return "Yesterday";
            }
        } else {
            return timeFormatter.string(from:date)
        }
    }
    
    private init() {}
}
