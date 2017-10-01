//
//  KeyboardAvoidableByFrame.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

private typealias KeyboardHeightDuration = (height: CGFloat, duration: Double)

protocol KeyboardAvoidableByFrame: class {
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] { get }
    var referenceFrame: CGRect { get set }
    func addKeyboardObservers()
    func removeKeyboardObservers()
}

extension KeyboardAvoidableByFrame where Self: UIViewController {
    
    func addKeyboardObservers() {
        NotificationCenter
            .default
            .addObserver(forName: .UIKeyboardWillShow,
                         object: nil,
                         queue: nil,
                         using: { [weak self] notification in
                            self?.keyboardWillShow(notification: notification as NSNotification)
            })
        
        NotificationCenter
            .default
            .addObserver(forName: .UIKeyboardWillHide,
                         object: nil,
                         queue: nil,
                         using: { [weak self] notification in
                            self?.keyboardWillHide(notification: notification as NSNotification)
            })
        
    }
    
    func removeKeyboardObservers() {
        NotificationCenter
            .default
            .removeObserver(self,
                            name: .UIKeyboardWillShow,
                            object: nil)
        
        NotificationCenter
            .default
            .removeObserver(self,
                            name: .UIKeyboardWillHide,
                            object: nil)
    }
    
    private func keyboardWillShow(notification: NSNotification) {
        guard let info = getKeyboardInfo(notification: notification) else { return }
        
        let keboardY = UIScreen.main.bounds.height - info.height
        let heightDifference = referenceFrame.maxY - keboardY
        guard heightDifference >= 0 else {
            return
        }
        
        let aboveKeyboardHeight: CGFloat = -(heightDifference + 20)
        animateConstraints(constant: aboveKeyboardHeight, duration: info.duration)
    }
    
    private func keyboardWillHide(notification: NSNotification) {
        guard let info = getKeyboardInfo(notification: notification) else { return }
        animateConstraints(constant: 0, duration: info.duration)
    }
    
    private func getKeyboardInfo(notification: NSNotification) -> KeyboardHeightDuration? {
        guard let userInfo = notification.userInfo else { return nil }
        guard let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return nil }
        guard let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return nil }
        
        return (rect.height, duration)
    }
    
    private func animateConstraints(constant: CGFloat, duration: Double) {
        var hasToAnimatedConstant = false
        for c in layoutConstraintsForKeyboard where c.constant != constant {
            c.constant = constant
            hasToAnimatedConstant = true
        }
        
        guard hasToAnimatedConstant else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
