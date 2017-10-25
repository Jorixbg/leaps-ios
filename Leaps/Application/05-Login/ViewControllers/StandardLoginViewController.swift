//
//  StandardLoginViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

class StandardLoginViewController: UIViewController {
    typealias T = LoginViewModel
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextField: LeapsRegistrationTextField!
    @IBOutlet weak var bottomTextField: LeapsRegistrationTextField!
    
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] = []
    var referenceFrame: CGRect = .zero
    fileprivate var viewModel: LoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        layoutConstraintsForKeyboard.append(containerViewAlignmentConstraint)
        referenceFrame = containerView.frame
        addKeyboardObservers()
        configureToDismissKeyboard()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
 
    @IBAction func didPressSignIn(_ sender: Any) {
        viewModel?.login(username: topTextField.text, password: bottomTextField.text, completion: { (error) in
            if error != nil {
                //handle error
            } else {
                //whatever
            }
        })
    }
}
extension StandardLoginViewController: KeyboardDismissible {
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension StandardLoginViewController: KeyboardAvoidableByFrame { }

extension StandardLoginViewController: Injectable {
    func inject(_ viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
}
