//
//  AlertManager.swift
//  Leaps
//
//  Created by Slav Sarafski on 30/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SwiftMessages

enum MessageErrorType: String {
    case login = ""
}

enum MessageType: String {
    case login = "You've successfully logged in."
    case register = "You've successfully registered."
    case createEvent = "You've successfully created event."
    case becomeTrainer = "Congratulations! You are trainer now."
}

class AlertManager {

    static let shared: AlertManager = AlertManager()
    
    func hideAll() {
        SwiftMessages.hideAll()
    }
    
    func showSuccessMessage(type: MessageType) {
        showSuccessMessage(message: type.rawValue)
    }
    
    func showSuccessMessage(message: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(.success)
        view.configureDropShadow()
        view.configureContent(title: "Success", body: message)
        view.button?.isHidden = true
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    func showWarningMessage(message: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(.warning)
        view.configureDropShadow()
        view.configureContent(title: "Warning", body: message)
        view.button?.isHidden = true
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    
    func showErrorMessage(type: MessageErrorType) {
        showErrorMessage(message: type.rawValue)
    }
    
    func showErrorMessage(message: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        var config = SwiftMessages.Config()
        config.duration = .forever
        config.presentationContext = .window(windowLevel: 0)
        
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(title: "Error", body: message)
        view.buttonTapHandler = { _ in SwiftMessages.hide() }
        view.button?.setTitle("OK", for: .normal)
        
        // Show the message.
        SwiftMessages.show(config: config, view: view)
    }
    
    func showTryAgainMessage(message: String, block: @escaping ()->Void) {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        var config = SwiftMessages.Config()
        config.duration = .forever
        
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(title: "Error", body: message)
        view.buttonTapHandler = { _ in block() }
        view.button?.setTitle("Try again", for: .normal)
        
        // Show the message.
        SwiftMessages.show(config: config, view: view)
    }
}
