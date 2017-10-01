//
//  KeyboardDismissable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/28/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

@objc protocol KeyboardDismissible: class {
    func dismissKeyboard()
}

extension KeyboardDismissible where Self: UIViewController {
    
    func configureToDismissKeyboard() {
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(gesture)
    }
}
