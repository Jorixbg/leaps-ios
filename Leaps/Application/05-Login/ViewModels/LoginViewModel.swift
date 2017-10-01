//
//  LoginViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/6/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class LoginViewModel: BaseViewModel {
    
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
    }
    
    func requestFacebookInfo(completion: ((Result<UserSignUpStepsData>) -> Void)?) {
        service.requestFacebookInfo(completion: completion)
    }
    
    func login(fbID: String?, completion: ((Error?) -> Void)?) {
        guard let fbID = fbID else {
            completion?(LeapsError.missingToken)
            return
        }
        service.login(fbID: fbID) { [weak self] (result) in
            self?.handleLoginResponse(response: result, completion: completion)
        }
    }
    
    func login(googleID: String?, completion: ((Error?) -> Void)?) {
        guard let googleID = googleID else {
            completion?(LeapsError.missingToken)
            return
        }
        service.login(googleID: googleID) { [weak self] (result) in
            self?.handleLoginResponse(response: result, completion: completion)
        }
    }
    
    func login(username: String?, password: String?, completion: ((Error?) -> Void)?) {
        guard let username = username, let password = password else {
            print("username or password missing")
            return
        }
        service.login(username: username, password: password) { [weak self] (result) in
            self?.handleLoginResponse(response: result, completion: completion)
        }
    }
    
    private func handleLoginResponse(response: LoginResult, completion: ((Error?) -> Void)?) {
        switch response {
        case .error(let error):
            completion?(error)
        case .success(let userID):
            completion?(nil)
        }
    }
}
