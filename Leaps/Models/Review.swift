//
//  Review.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

struct Review {
    let id: Int
    let userID: Int
    let userName: String
    let userImage: String
    let rating: Int
    let comment: String
    let date: Date
    let image: String?
}

extension Review: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> Review? {
        guard   let reviewID = dictionary["comment_id"] as? Int,
                let userID = dictionary["user_id"] as? Int,
                let username = dictionary["event_owner_name"] as? String,
                let userImage = dictionary["event_owner_image"] as? String,
                let rating = dictionary["rating"] as? Int,
                let comment = dictionary["comment"] as? String,
                let dateTimestamp = dictionary["date_created"] as? Int64
            
            //this one is null
            else {
                print("review deserializing failed")
                return nil
        }
        
        
        let commentImage = dictionary["comment_image"] as? String
        
        return Review(id: reviewID,
                      userID: userID,
                      userName: username,
                      userImage: userImage,
                      rating: rating,
                      comment: comment,
                      date: Date(timeIntervalSince1970inMiliseconds: dateTimestamp),
                      image: commentImage)
    }
}
