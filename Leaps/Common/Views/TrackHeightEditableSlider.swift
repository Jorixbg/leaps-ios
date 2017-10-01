//
//  TrackHeightEditableSlider.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/30/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TrackHeightEditableSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 2
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //set your bounds here
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
    }
}
