//
//  UISegmentedControl+Borderless.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

//marker
private class UnderlineView: UIView { }

extension UISegmentedControl{
    func removeBorder(){
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor,
 andSize: bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        
        let dividerImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor,
                                                           andSize: CGSize(width: 1.0,
                                                                           height: bounds.size.height))
        self.setDividerImage(dividerImage,
                             forLeftSegmentState: .selected,
                             rightSegmentState: .normal,
                             barMetrics: .default)
        
        guard let font = UIFont.leapsCervoFont(size: 17) else {
            return
        }
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.leapsBlueWithAlpha, NSFontAttributeName: font], for: .normal)
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.leapsOnboardingBlue], for: .selected)
    }
    
    func removeExistingBorder() {
        subviews.first(where: { $0 is UnderlineView })?.removeFromSuperview()
    }
    
    func addUnderlineForSelectedSegment(){
        let underlineWidth: CGFloat = bounds.size.width / CGFloat(numberOfSegments)
        let underlineHeight: CGFloat = 1.0
        let underlineXPosition: CGFloat
        var isAlreadyASubview: Bool
        if let _ = subviews.first(where: { $0 is UnderlineView }) {
            isAlreadyASubview = true
            underlineXPosition = (bounds.width / CGFloat(numberOfSegments)) * CGFloat(selectedSegmentIndex)
        } else {
            isAlreadyASubview = false
            underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        }
        
        let underLineYPosition = bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition,
                                    y: underLineYPosition,
                                    width: underlineWidth,
                                    height: underlineHeight)
        let underline = UnderlineView(frame: underlineFrame)
        underline.layer.zPosition = layer.zPosition + 1
        underline.backgroundColor = .leapsOnboardingBlue
        
        if !isAlreadyASubview {
            addSubview(underline)
        }
    }
    
    func changeUnderlinePosition(){
        guard let underline = subviews.first(where: { $0 is UnderlineView }) else { return }
        let underlineFinalXPosition = (bounds.width / CGFloat(numberOfSegments)) * CGFloat(selectedSegmentIndex)
        //        UIView.animate(withDuration: 0.1, animations: {
        underline.frame.origin.x = underlineFinalXPosition
        //        })
    }
}

extension UIImage{
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}
