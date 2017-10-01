//
//  NotificationName.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let resetSearch = Notification.Name("reset-search")
    static let refreshData = Notification.Name("refresh-data")
    static let refreshOnImageUpload = Notification.Name("regresh-on-image-upload")
    static let keepSearchTransition = Notification.Name("transition")
    static let loggedOut = Notification.Name("logged-out")
}
