//
//  Attendee.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/25/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

struct Attendee {
    let userID: Int
    let userName: String
    let userImageURL: String?
    var followed: Bool
    
    func change(followed:Bool) -> Attendee {
        return Attendee(userID: self.userID, userName: self.userName, userImageURL: self.userImageURL, followed: followed)
    }
    
    static func ==(lhv:Attendee, rhv:Attendee) -> Bool {
        return lhv.userID == rhv.userID
    }
}

extension Attendee: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> Attendee? {
        guard let id = dictionary["user_id"] as? Int,
            let username = dictionary["user_name"] as? String else {
                return nil
        }
        
        let userImageURL = dictionary["user_image_url"] as? String
        return Attendee(userID: id, userName: username, userImageURL: userImageURL, followed: false)
    }
}
