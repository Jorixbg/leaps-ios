//
//  UserManager.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/28/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import CoreLocation

class UserManager {
    
    static var debugMode: Bool = false
    static let shared: UserManager = UserManager()
    var hasCurrentLocation: Dynamic<Bool> = Dynamic(false)
    var currentLocation: CLLocation? {
        didSet {
            hasCurrentLocation.value = true
        }
    }
    
    var currentCoordinates: (Double, Double)? {
        guard let lattitude = currentLocation?.coordinate.latitude,
            let longitude = currentLocation?.coordinate.longitude else {
                return nil
        }
        
        return (lattitude, longitude)
    }
    
    private init() {}
    
    func set(isSeenOnboarding: Bool) {
        print("set isSeenOnboarding = \(isSeenOnboarding)")
        UserDefaults.standard.setValue(isSeenOnboarding, forKey: .onboardingSeenKey)
    }
    
    func set(isTrainer: Bool) {
        print("set isTrainer = \(isTrainer)")
        UserDefaults.standard.setValue(isTrainer, forKey: .isTrainerKey)
        UserDefaults.standard.synchronize()
    }
    
    func hasSeenOnboarding() -> Bool? {
        return UserDefaults.standard.value(forKey: .onboardingSeenKey) as? Bool ?? false
    }
    
    //it's better to move these to the keychain if there's time available
    func setToken(authToken: String) {
        print("setToken = \(authToken)")
        UserDefaults.standard.set(authToken, forKey: .tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    private func removeToken() {
        UserDefaults.standard.removeObject(forKey: .tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    private func removeID() {
        UserDefaults.standard.removeObject(forKey: .idKey)
        UserDefaults.standard.synchronize()
    }
    
    //id as string as the getter returns nil if we don't have it set. For int it will return 0 if we haven't set any value which will be inaccurate as there will be a user with id 0.
    func setID(id: String) {
        UserDefaults.standard.set(id, forKey: .idKey)
        UserDefaults.standard.synchronize()
    }
    
    func setName(name: String) {
        UserDefaults.standard.set(name, forKey: .nameKey)
        UserDefaults.standard.synchronize()
    }
    
    func setImage(image: String) {
        UserDefaults.standard.set(image, forKey: .imageKey)
        UserDefaults.standard.synchronize()
    }
    
    func setFcmToken(token: String) {
        UserDefaults.standard.set(token, forKey: .fcmTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    //String as integer will return 0 if there is no value
    var userID: String? {
        return UserDefaults.standard.string(forKey: .idKey)
    }
    
    var userName: String? {
        return UserDefaults.standard.string(forKey: .nameKey)
    }
    
    var userImage: String? {
        return UserDefaults.standard.string(forKey: .imageKey)
    }
    
    var authToken: String? {
        return UserDefaults.standard.string(forKey: .tokenKey)
    }
    
    var fcmToken: String? {
        return UserDefaults.standard.string(forKey: .fcmTokenKey)
    }
    
    var isTrainer: Bool {
        return UserDefaults.standard.bool(forKey: .isTrainerKey)
    }
    
    var isLoggedIn: Bool {
        return authToken != nil
    }
    
    func logout() {
        set(isTrainer: false)
        removeToken()
        removeID()
    }
    
    func setTags(tags: [String]) {
        UserDefaults.standard.set(tags, forKey: .tagsKey)
        UserDefaults.standard.synchronize()
    }
    
    var tags: [String]? {
        return UserDefaults.standard.array(forKey: .tagsKey) as? [String]
    }
}
