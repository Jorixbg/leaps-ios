//
//  Follower.swift
//  Leaps
//
//  Created by Slav Sarafski on 15/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

struct Follower {
    var userID: Int?
    let firstName: String
    let imageURL: String?
}

extension Follower: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> Follower? {
        guard
            let userID = dictionary["user_id"] as? Int,
            let firstname = dictionary["user_first_name"] as? String
            
            else {
                return nil
        }
        
        let imageURL = dictionary["profile_image_url"] as? String
        
        return Follower(userID: userID,
                        firstName: firstname,
                        imageURL: imageURL)
    }
}

extension Follower {
    static func == (lhs: Follower, rhs: Follower) -> Bool {
        return lhs.userID == rhs.userID
    }
}
