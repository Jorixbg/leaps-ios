//
//  UplodableImage.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/30/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum UplodableImageType {
    case userMainImage
    case userAdditionalImage
    case eventMainImage
    case eventAdditionalImage
}

extension UplodableImageType: Equatable {
    static func ==(lhs: UplodableImageType, rhs: UplodableImageType) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}

struct UplodableImage {
    let imageData: Data
    let type: UplodableImageType
}

extension UplodableImage: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: UplodableImage, rhs: UplodableImage) -> Bool {
        return lhs.imageData == rhs.imageData
            && lhs.type == rhs.type
    }
}
