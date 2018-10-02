//
//  Constants.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

struct Constants {

    struct General {
        static let standradCornerRadius: CGFloat = 6
    }
    
    struct CreateEvent {
        static let uploadedPictureCompression: CGFloat = 1
    }

    #if DEBUG
    //static let baseURL = "http://91.238.251.125:8888/"
    static let baseURL = "http://91.238.251.154:8888/"
    #else
    static let baseURL = "http://91.238.251.154:8888/"
    #endif
    struct Activities {
        static let activityCellHeight: CGFloat = 145
        static let headerHeight: CGFloat = 30
        static let activityCalendarCellHeight: CGFloat = 106
        static let activityCalendarHeaderHeight: CGFloat = 25
        static let bottomInset: CGFloat = 20
    }
    
    struct Calendar {
        static let trainerTopViewHeight: CGFloat = 70
    }
    
    struct Requests {
        static let pageSize = 20
    }
}
