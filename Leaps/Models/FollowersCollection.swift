//
//  FollowersCollection.swift
//  Leaps
//
//  Created by Slav Sarafski on 26/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

struct FollowersCollection {
    var friends: [Attendee]
    var others:  [Attendee]
}

//extension FollowersCollection: Deserializable {
//    static func fromJSON(from dictionary: [String : Any]) -> FollowersCollection? {
//        guard
//            let followers = dictionary["followed_by"] as? [[String: Any]],
//            let friends =  followers["friends"] as? [[String: Any]],
//            let others = followers["others"] as? [[String: Any]]
//            
//            else {
//                return nil
//        }
//    
//        if let followersDictArray = dictionary["followed_by"] as? [[String: Any]] {
//            followers = Follower.buildArray(followersDictArray)
//        } else {
//            followers = nil
//        }
//        
//        return Follower(userID: userID,
//                        firstName: firstname,
//                        imageURL: imageURL)
//    }
//}

