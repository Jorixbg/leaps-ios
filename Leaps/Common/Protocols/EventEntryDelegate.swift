//
//  EventEntryDelegate.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/19/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

protocol EventEntryDelegate: class {
    func enterTitle(title: String)
    func enterDescription(description: String)
    func addTag(tag: String)
    func removeTag(tag: String)
    func enterLocation(location: String)
    func enterCoordinates(lat:Double, lon:Double)
    func enterPrice(price: String)
    func enterFreeSlots(slots: String)
    func enterTimeFrom(time: Date)
    func enterTimeTo(time: Date)
    func enterRepeating(repeating: Bool)
    func enterFrequency(frequency: Frequency)
    func enterDates(activities: [Activity])
    func addImage(image: UplodableImage)
    func removeImage(image: UplodableImage)
}
