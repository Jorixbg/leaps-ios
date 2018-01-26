//
//  CreateEventViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import GoogleMaps

enum CreateEventStepType {
    case createAnEvent
    case location
    case priceAndSlots
    case timeAndDate
    
    func navTitleForType() -> String {
        switch self {
        case .createAnEvent:
            return "CREATE AN EVENT"
        case .location:
            return "LOCATION"
        case .priceAndSlots:
            return "PRICE AND SLOTS"
        case .timeAndDate:
            return"TIME AND DATE"
        }
    }
}

enum CreateEventRowType: Equatable {
    static func ==(lhs: CreateEventRowType, rhs: CreateEventRowType) -> Bool {
        switch (lhs, rhs) {
            case (.title, .title): return true
            case (.imageSelection, .imageSelection): return true
            case (.description, .description): return true
            case (.eventLocationMap, .eventLocationMap): return true
            case (.priceFrom, .priceFrom): return true
            case (.freeSlots, .freeSlots): return true
            case (.date, .date): return true
            case (.time, .time): return true
            case (.workoutType(_), .workoutType(_)): return true
            case (.repeat, .repeat): return true
            case (.start, .start): return true
            case (.end, .end): return true
        default: return false
        }
    }
    
    case imageSelection
    case title
    case description
    case workoutType([String])
    case eventLocationMap
    case priceFrom
    case freeSlots
    case date
    case time
    
    case `repeat`(Bool)
    case start(String, UIDatePickerMode)
    case end(String, UIDatePickerMode)
    case frequency(Frequency)
    case dayHeader(Day)
    case activity(Activity)
    
    func titleForRow() -> String {
        switch self {
        case .imageSelection:
            return "Event main picture and cover photos"
        case .title:
            return "Title"
        case .description:
            return "Description"
        case .workoutType:
            return "Workout Type"
        case .eventLocationMap:
            return "Event Location"
        case .priceFrom:
            return "Price from"
        case .freeSlots:
            return "Free slots"
        case .date:
            return "Date"
        case .time:
            return "Time"
            
        case .repeat:
            return "Repeat"
        case .start:
            return "Start"
        case .end:
            return "End"
        case .frequency(_):
            return "Frequency"
        default:
            return ""
        }
    }
    
    func placeholderForType() -> String? {
        switch self {
        case .title:
            return "Event Title"
        case .description:
            return "Type description"
        case .eventLocationMap:
            return "City, address"
        case .priceFrom:
            return "BGN 0"
        case .freeSlots:
            return "0"
        case .date:
            return "Date"
        case .time:
            return "Time"
        default:
            return nil
        }
    }
}

struct CreateEventSection {
    var items: [CreateEventRowType]
}

enum Frequency: String {
//    typealias RawValue = <#type#>
    
    case everyday = "Everyday"
    case weekly = "Weekly"
    case weekday = "Weekdays"
    case weekend = "Weekend"
    func days() -> [Day] {
        switch self {
        case .everyday:
            return [.everyday]
        case .weekly:
            return [.monday, .tuesday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        case .weekday:
            return [.monday, .tuesday, .tuesday, .wednesday, .thursday, .friday]
        case .weekend:
            return [.saturday, .sunday]
        }
    }
    func array() -> [Frequency] {
        return [.everyday, .weekly, .weekday, .weekend]
    }
}

enum Day: String {
    case everyday = "Everyday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

struct Activity: Comparable, Equatable {
    static func <(lhs: Activity, rhs: Activity) -> Bool {
        if lhs.day.hashValue == rhs.day.hashValue {
            if lhs.startHour != rhs.startHour {
                return lhs.startHour < rhs.startHour
            }
            return lhs.startMinutes < rhs.startMinutes
        }
        return lhs.day.hashValue < rhs.day.hashValue
    }
    
    static func ==(lhs: Activity, rhs: Activity) -> Bool {
        return lhs.day.hashValue == rhs.day.hashValue &&
               lhs.startHour == rhs.startHour &&
               lhs.startMinutes == rhs.startMinutes
    }
    
    var day: Day
    var startHour, startMinutes, endHour, endMinutes: String
    func title() -> String {
        return "\(startHour):\(startMinutes) - \(endHour):\(endMinutes)"
    }
    func jsonStartDate() -> String {
        return "\(startHour)\(startMinutes)"
    }
    func jsonEndDate() -> String {
        return "\(endHour)\(startHour)"
    }
}

class CreateEventStepViewModel: BaseViewModel {
    
    fileprivate var type: CreateEventStepType
    fileprivate let service: UtilsService
    var rows: Dynamic<[CreateEventRowType]>
    private var userManager: UserManager
    weak var delegate: EventEntryDelegate? = nil
    var title:  String {
        return type.navTitleForType()
    }
    
    var repeating = Dynamic<Bool>(false)
    var frequency = Dynamic<Frequency>(.everyday)
    
    var activities = Dynamic<[Activity]>([])
    
    init(type: CreateEventStepType, delegate: EventEntryDelegate?, userManager: UserManager = UserManager.shared) {
        self.type = type
        self.delegate = delegate
        self.userManager = userManager
        self.service = UtilsService()
        self.rows = Dynamic([])
        
        self.repeating.bindAndFire { (rep) in
            self.buildRows()
            self.delegate?.enterRepeating(repeating: self.repeating.value)
        }
        self.frequency.bind { (rep) in
            self.buildRows()
            self.delegate?.enterFrequency(frequency: self.frequency.value)
        }
        self.activities.bind { (rep) in
            self.buildRows()
            self.delegate?.enterDates(activities: self.activities.value)
        }
    }
    
    func buildRows() {
        var rows: [CreateEventRowType] = []
        switch type {
        case .createAnEvent:
            let imageSelectionRow = CreateEventRowType.imageSelection
            rows.append(imageSelectionRow)
            
            let titleRow = CreateEventRowType.title
            rows.append(titleRow)
            
            let descriptionRow = CreateEventRowType.description
            rows.append(descriptionRow)
            
            var tags: [String] = []
            if let predefinedTags = userManager.tags {
                tags.append(contentsOf: predefinedTags)
            }
            
            let workoutTypeRow = CreateEventRowType.workoutType(tags)
            rows.append(workoutTypeRow)
        case .location:
            let eventLocationMapRow = CreateEventRowType.eventLocationMap
            rows.append(eventLocationMapRow)
        case .priceAndSlots:
            let priceFromRow = CreateEventRowType.priceFrom
            rows.append(priceFromRow)
            
            let freeSlotsRow = CreateEventRowType.freeSlots
            rows.append(freeSlotsRow)
        case .timeAndDate:
            let repeatRow = CreateEventRowType.repeat(repeating.value)
            rows.append(repeatRow)
            
            var title = repeating.value ? "Start Date" : "Start"
            let mode: UIDatePickerMode = repeating.value ? .date : .dateAndTime
            let startRow = CreateEventRowType.start(title, mode)
            rows.append(startRow)
            
            title = repeating.value ? "End Date" : "End"
            let endRow = CreateEventRowType.end(title, mode)
            rows.append(endRow)
            
            if repeating.value {
                let frequencyRow = CreateEventRowType.frequency(frequency.value)
                rows.append(frequencyRow)
                
                let sortedActivities = activities.value.sorted()
                for day in frequency.value.days() {
                    let dayHeaderRow = CreateEventRowType.dayHeader(day)
                    rows.append(dayHeaderRow)
                    for activity in sortedActivities {
                        if activity.day == day {
                            let activityRow = CreateEventRowType.activity(activity)
                            rows.append(activityRow)
                        }
                    }
                }
            }
            
        }
        
        self.rows.value = rows
    }
    
    func rowType(forIndexPath indexPath: IndexPath) -> CreateEventRowType {
        return rows.value[indexPath.row]
    }
    
    func rowIndex(for type: CreateEventRowType) -> IndexPath? {
        guard let row = rows.value.index(of: type) else {
            return nil
        }
        return IndexPath(row: row, section: 0)
    }
    
    func addUploadImage(image: UplodableImage) {
        delegate?.addImage(image: image)
    }
    
    func removePicture(currentImageID: Int, image: UplodableImage) {
        delegate?.removeImage(image: image)
    }
    
    // API CALLS
    func fetchCoordinates(by address:String, completion: CoordinatesFetchingHandler?)
    {
        service.fetchCoordinates(by: address, completion: completion)
    }
    func fetchAdress(with coordinates: CLLocationCoordinate2D, completion: AddressFetchingHandler?)
    {
        service.fetchAdress(with: coordinates, completion: completion)
    }
}
