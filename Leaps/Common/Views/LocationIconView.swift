//
//  LocationIcon.swift
//  Leaps
//
//  Created by Slav Sarafski on 25/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

//protocol LocationIconView {}
//extension UIView : LocationIconView {}
//
//extension LocationIconView where Self : UIView {

class LocationIconView: UIView {

    var index:Int = -1
    @IBOutlet var priceLabel:UILabel!
    @IBOutlet var locationIconImageView:UIImageView!
    
    var isActieve:Bool = false {
        didSet {
            if isActieve {
                locationIconImageView.image = #imageLiteral(resourceName: "pin-map-active")
            }
            else {
                locationIconImageView.image = #imageLiteral(resourceName: "pin-map")
            }
        }
    }
    
    func setup(price:Int, index i:Int) {
        index = i
        isActieve = false
        if price != 0 {
            priceLabel.text = "from BGN \(price)"
            priceLabel.backgroundColor = .white
            priceLabel.textColor = .leapsOnboardingBlue
        } else {
            priceLabel.text = "FREE"
            priceLabel.backgroundColor = .leapsOnboardingRed
            priceLabel.textColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceLabel.layer.cornerRadius = Constants.General.standradCornerRadius
    }
    
    class func instanceFromNib() -> LocationIconView {
        return Bundle.main.loadNibNamed("LocationIconView", owner: self, options: nil)?.first as! LocationIconView
    }
}
