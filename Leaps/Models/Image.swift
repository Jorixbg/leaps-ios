//
//  Image.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

struct Image {
    let id: Int
    let url: String
}

extension Image: Deserializable {
    static func fromJSON(from dictionary: [String : Any]) -> Image? {
        guard let id = dictionary["image_id"] as? Int,
            let url = dictionary["image_url"] as? String else {
                return nil
        }
        
        return Image(id: id, url: url)
    }
}

extension Image: Serializable {
    func toJSON() -> [String : Any] {
        return ["image_id": id,
                "image_url": url]
    }
}
