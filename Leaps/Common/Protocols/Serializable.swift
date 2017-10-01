//
//  Serializable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

protocol Serializable {
    func toJSON() -> [String: Any]
}
