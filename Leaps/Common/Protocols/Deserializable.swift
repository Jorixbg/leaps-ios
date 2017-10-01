//
//  Deserializable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

protocol Deserializable {
    static func fromJSON(from dictionary: [String: Any]) -> Self?
}

extension Deserializable {
    static func buildArray(_ jsonData: [[String : Any]]?) -> [Self] {
        var array: [Self] = []
        guard let jsonData = jsonData else { return array }
        
        for data in jsonData {
            guard let element = Self.fromJSON(from: data) else { continue }
            array.append(element)
        }
        
        return array
    }
}
