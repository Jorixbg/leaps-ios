//
//  CustomExtention.swift
//  Leaps
//
//  Created by Slav Sarafski on 17/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

extension UIDevice {
    static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA           = UIScreen.main.scale >= 2.0
    
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_X = IS_IPHONE && SCREEN_MAX_LENGTH == 812
}

extension UIViewController {
    func setupDefaultNavigationController() {
        //the below code should be extracted to a parent view controller if there is enough time. It is used in edit profile, create event etc.
        //show navbar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        
        //back button
//        let buttonSelector = #selector(self.didPressBack)
//        let cancelNavButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: buttonSelector)
//        cancelNavButton.tintColor = UIColor.leapsOnboardingBlue
//        navigationItem.leftBarButtonItem  = cancelNavButton
        let buttonSelector = #selector(self.didPressBack)
        let cancelNavButton = UIButton(type: .custom)
        cancelNavButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        cancelNavButton.addTarget(self, action: buttonSelector, for: .touchUpInside)
        cancelNavButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cancelNavButton.imageEdgeInsets = UIEdgeInsetsMake(0, -11, 0, 0)
        cancelNavButton.tintColor = .leapsOnboardingBlue
        cancelNavButton.contentHorizontalAlignment = .left
        cancelNavButton.contentVerticalAlignment = .center
        let barButton = UIBarButtonItem(customView: cancelNavButton)
        navigationItem.leftBarButtonItem  = barButton
        
        //remove bottom line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //set attributed title
        guard let font = UIFont.leapsSFFont(size: 12) else {
            return
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: font,
                                                                   NSAttributedStringKey.foregroundColor: UIColor.leapsOnboardingBlue]
    }
    
    @objc func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension UITextField {
    func modifyClearButton(with image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(UITextField.clear(_:)), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .always
    }
    
    @objc func clear(_ sender : AnyObject) {
        self.text = ""
        sendActions(for: .editingChanged)
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

extension String {
    func twoLengthString(lead:String="0") -> String {
        return self.count > 1 ? self : "\(lead)\(self)"
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
        }
    }
    
    mutating func move(_ element: Element) {
        self.remove(element)
        self.append(element)
    }
}
