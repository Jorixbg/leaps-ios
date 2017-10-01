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

enum CreateEventRowType {
    case imageSelection
    case title
    case description
    case workoutType([String])
    case eventLocation
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
        case .eventLocation:
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
        case .eventLocation:
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
    var rows: Dynamic<[CreateEventRowType]>
    private var picturesData: [UplodableImage] = []
    private var userManager: UserManager
    weak var delegate: EventEntryDelegate? = nil
    var title:  String {
        return type.navTitleForType()
    }
    
    init(type: CreateEventStepType, delegate: EventEntryDelegate?, userManager: UserManager = UserManager.shared) {
        self.type = type
        self.delegate = delegate
        self.userManager = userManager
        
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
            let eventLocationRow = CreateEventRowType.eventLocation
            rows.append(eventLocationRow)
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
    
    func addUploadImage(image: UplodableImage) {
        delegate?.addImage(image: image)
    }
    
    func removePicture(currentImageID: Int, image: UplodableImage) {
        delegate?.removeImage(image: image)
    }
}
