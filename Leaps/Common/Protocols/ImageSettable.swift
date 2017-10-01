//
//  ImageSettable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/23/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

protocol ImageSettable: class {
    func setImage(image: UIImage)
    func unsetImage()
}
