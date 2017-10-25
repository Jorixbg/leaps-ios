//
//  CreateEventViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

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
//        case .eventLocation:
//            return "Event Location"
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
        }
    }
    
    func placeholderForType() -> String? {
        switch self {
        case .imageSelection, .workoutType:
            return nil
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
        }
    }
}

struct CreateEventSection {
    var items: [CreateEventRowType]
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
    
    init(type: CreateEventStepType, delegate: EventEntryDelegate?, userManager: UserManager = UserManager.shared) {
        self.type = type
        self.delegate = delegate
        self.userManager = userManager
        self.service = UtilsService()
        
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
            let dateRow = CreateEventRowType.date
            rows.append(dateRow)
            
            let timeRow = CreateEventRowType.time
            rows.append(timeRow)
        }
        
        self.rows = Dynamic(rows)
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
    func fetchCoordinates(by address:String, completion: CoordinatesFetchingHandler?) {
        service.fetchCoordinates(by: address, completion: completion)
    }
}
