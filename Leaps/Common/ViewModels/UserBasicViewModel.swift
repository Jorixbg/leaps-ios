//
//  UserBasicViewModel.swift
//  Leaps
//
//  Created by Slav Sarafski on 16/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class UserBasicViewModel: BaseViewModel {
    
    var user: Dynamic<User?>
    internal let service: UserService
    internal let userManager: UserManager
    
    init(user: User, userManager: UserManager = UserManager.shared, service: UserService = UserService()) {
        self.user = Dynamic(user)
        self.userManager = userManager
        self.service = service
    }
    
    var fullname: String {
        if let user = user.value {
            return "\(user.firstName) \(user.lastName)"
        }
        return ""
    }
    
    var username: String {
        if let user = user.value {
            return user.username
        }
        return ""
    }
    
    func fetchUser(id:Int, completion: ((Error?) -> Void)? = nil) {
        service.fetchUser(forUserWith: String(id)) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.user.value = user
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func followAction(completion: ((Error?) -> Void)? = nil) {
        guard let userID = user.value?.userID else {
            return
        }
        if isUserFollowed(){
            unfollowUser(id: userID)
        }
        else {
            followUser(id: userID)
        }
    }
    
    func followUser(id:Int, completion: ((Error?) -> Void)? = nil) {
        service.follow(userID: id) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.user.value = user
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func unfollowUser(id:Int, completion: ((Error?) -> Void)? = nil) {
        service.unfollow(userID: id) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.user.value = user
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func isUserFollowed() -> Bool {
        guard let userID = userManager.userID else {
            return false
        }
        return user.value?.followedBy?.contains(where: {String($0.userID) == userID}) ?? false
    }
    
    func isLoggedUser() -> Bool {
        guard   let userID = userManager.userID,
            let selfUserID = user.value?.userID else {
                return false
        }
        return userID == String(selfUserID)
    }
}
