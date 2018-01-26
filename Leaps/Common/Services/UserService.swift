//
//  UserService.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/6/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import FBSDKLoginKit

typealias UserResult = Result<(User)>
typealias UserFetchingHandler = (UserResult) -> Void
typealias LoginResult = Result<String>
typealias LoginResultHandler = (LoginResult) -> Void
typealias TrainersResult = Result<[User]>
typealias TrainersFetchHandler = (TrainersResult) -> Void
typealias UserFetchResult = Result<User>
typealias UserFetchResultHandler = (UserFetchResult) -> Void
typealias UserEventsResult = Result<([Event])>
typealias UserEventsResultHandler = (UserEventsResult) -> Void
typealias EventCreateResult = Result<Int>
typealias EventCreateResultHandler = (EventCreateResult) -> Void
typealias UserUpdateResult = Result<Int>
typealias UserUpdateResultHandler = (UserUpdateResult) -> Void

class UserService {
    private let networkManager: NetworkManager
    private let userManager: UserManager
    
    init(networkManager: NetworkManager = NetworkManager(), userManager: UserManager = UserManager.shared) {
        self.networkManager = networkManager
        self.userManager = userManager
    }
    
    //TODO: extract to trainers service
    //MARK: - TRAINERS FETCH
    func fetchTrainers(completion: TrainersFetchHandler?) {
        let token = userManager.authToken ?? ""
        
        let endPoint = "user/trainer/feed/"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        
        networkManager.get(path: endPoint, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let data = data as? [[String: Any]] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                let trainers = User.buildArray(data)
                completion?(Result.success(trainers))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }

    //MARK: - TRAINERS SEARRCH
    func serachTrainers(searchEntry: SearchEntry, completion: TrainersFetchHandler?) {
        let endPoint = "user/trainer/filter/"
        let params = searchEntry.toJSON()
        let headers = ["Content-Type": "application/json"]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let data = data as? [String: Any],
                        //let totalResults = data["total_results"] as? Int,
                        let trainersArray = data["trainers"] as? [[String: Any]] else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                let trainers = User.buildArray(trainersArray)
                completion?(Result.success(trainers))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    //MARK: - REGISTER
    func register(userDetails: UserSignUpStepsData, completion: LoginResultHandler?) {
        let endPoint = "register"
        let params = userDetails.toJSON()
        let headers = ["Content-Type": "application/json"]
        networkManager.post(path: endPoint, params: params, headers: headers, completion: { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.handleUserID(data: data, completion: completion)
            case .error(let error):
                completion?(Result.error(error))
            }
        })
    }
    
    //MARK: - HANDLE LOGIN AND REGISTER
    private func handleUserID(data: Any, completion: LoginResultHandler?) {
        guard let data = data as? [String: Any],
                    let id = data["user_id"] as? Int else {
            completion?(Result.error(LeapsError.deserializing))
            return
        }
        
        let idAsString = String(id)
        
        fetchUser(forUserWith: idAsString) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.userManager.set(isTrainer: user.isTrainer)
                self?.userManager.setID(id: idAsString)
                self?.userManager.setName(name: user.fullname)
                self?.userManager.setImage(image: user.imageURL ?? "")
                AppDelegate.shared.registerFCMTokenToDatabase(token: UserManager.shared.fcmToken ?? "")
                completion?(Result.success(idAsString))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    //MARK: - LOGIN
    func login(fbID: String, completion: LoginResultHandler?) {
        let params = ["fb_id": fbID]
        requesLogin(endPoint: "login/fb", params: params, completion: completion)
    }
    
    func login(googleID: String, completion: LoginResultHandler?) {
        print("googleID = \(googleID)")

        let params = ["google_id": googleID]
        requesLogin(endPoint: "login/google", params: params, completion: completion)
    }
    
    func login(username: String, password: String, completion: LoginResultHandler?) {
        let params = [ "name": "\(username)", "password": "\(password)"]
        requesLogin(endPoint: "login", params: params, completion: completion)
    }
    
    private func requesLogin(endPoint: String, params: [String: Any], completion: LoginResultHandler?) {
        let endPoint = endPoint
        let headers: [String: String] = ["Content-Type": "application/json"]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { [weak self] (result) in
            // parse data to user or trainer and return it
            switch result {
            case .error(let error):
                completion?(Result.error(error))
            case .success(let idData):
                guard let idData = idData as? [String: Any] else {
                        completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                self?.handleUserID(data: idData, completion: completion)
            }
        }
    }
    
    func requestFacebookInfo(completion: ((Result<UserSignUpStepsData>) -> Void)?) {
        let req = FBSDKGraphRequest(graphPath: "me",
                                    parameters: ["fields":"email, name"],
                                    tokenString: FBSDKAccessToken.current().tokenString,
                                    version: nil,
                                    httpMethod: "GET")
        _ = req?.start(completionHandler: { (connection, result, error) in
            
            if let error = error {
                completion?(Result.error(error))
            }
            guard let result = result as? [String: Any],
                    let userPrefilledData = UserSignUpStepsData.fromJSON(from: result), FBSDKAccessToken.current() != nil  else {
                        print("facebook failed")
                return
            }
            
            userPrefilledData.facebookID = FBSDKAccessToken.current().userID
            completion?(Result.success(userPrefilledData))
        })
    }
    
    //MARK: - FETCH USER
    func fetchUser(forUserWith id: String, completion: UserFetchResultHandler?) {
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let endPoint = "user/\(id)"
        let headers = ["Content-Type": "application/json",
                        "Authorization": token]
        
        networkManager.get(path: endPoint, params: nil, headers: headers) { (result) in
            switch result {
            case .error(let error):
                completion?(Result.error(error))
            case .success(let data):
                guard let result = data as? [String: Any],
                        let user = User.fromJSON(from: result) else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                
                completion?(Result.success(user))
            }
        }
    }
    
    //MARK: - UPDATE USER
    func update(userUpdateData: UserUpdateData, completion: UserUpdateResultHandler?) {
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let headers = ["Content-Type": "application/json", "Authorization": token]
        let endpoint = "user/update"
        let params = userUpdateData.toJSON()

        networkManager.post(path: endpoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let statusCode):
                guard let statusCode = statusCode as? Int else {
                    return
                }
                print("update user status code = \(statusCode)")
                completion?(Result.success(statusCode))
            case .error(let error):
                print("update user error = \(error)")
                completion?(Result.error(error))
            }
        }
    }
    
    func delete(imageID: Int) {
        guard let token = userManager.authToken else {
            return
        }
        
        let headers = ["Content-Type": "application/json", "Authorization": token]
        let endpoint = "pic/user"
        let params = ["image_id": imageID]
        
        networkManager.delete(path: endpoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let code):
                print("delete code = \(code)")
            case .error(_):
                break
            }
        }
    }
    
    //MARK: - FORGOTTEN PASS
    func forgottenPassword(email: String, completion: ((Error?) -> Void)?) {
        let endpoint = "user/resetPassword"
        let headers = ["Content-Type": "application/json"]
        let params = ["email_address": email]
        
        networkManager.post(path: endpoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(_):
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    //MARK: - FOLLOW USER WITH ID
    func follow(userID: Int, completion: UserFetchResultHandler?) {
        guard let token = userManager.authToken else {
            return
        }
        let endpoint = "user/follow"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        let params = ["user_id": userID]
        
        print("try to follow user: \(userID)")
        networkManager.post(path: endpoint, params: params, headers: headers) { (result) in
            switch result {
            case .error(let error):
                completion?(Result.error(error))
            case .success(let data):
                guard let result = data as? [String: Any],
                    let user = User.fromJSON(from: result) else {
                        completion?(Result.error(LeapsError.deserializing))
                        return
                }
                
                completion?(Result.success(user))
            }
        }
    }
    
    //MARK: - UNFOLLOW USER WITH ID
    func unfollow(userID: Int, completion: UserFetchResultHandler?) {
        guard let token = userManager.authToken else {
                return
        }
        let endpoint = "user/unfollow"
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        let params = ["user_id": userID]
        
        print("try to unfollow user: \(userID)")
        networkManager.post(path: endpoint, params: params, headers: headers) { (result) in
            switch result {
            case .error(let error):
                completion?(Result.error(error))
            case .success(let data):
                guard let result = data as? [String: Any],
                    let user = User.fromJSON(from: result) else {
                        completion?(Result.error(LeapsError.deserializing))
                        return
                }
                
                completion?(Result.success(user))
            }
        }
    }

    //MARK: - FETCH EVENTS
    func fetchEvents(userID: Int,
                     userCalndarType: UserCalendarType,
                     periodType: CalendarPeriodType,
                     page: Int,
                     completion: UserEventsResultHandler?) {
        switch userCalndarType {
        case .attending:
            switch periodType {
            case .upcoming:
                fetchUserAttendingEentsFuture(userID: userID, page: page, completion: completion)
            case .past:
                fetchUserAttendingEentsPast(userID: userID, page: page, completion: completion)
            }
            
        case .hosting:
            switch periodType {
            case .upcoming:
                fetchUserHostingEentsFuture(userID: userID, page: page, completion: completion)
            case .past:
                fetchUserHostingEentsPast(userID: userID, page: page, completion: completion)
            }
        }
    }

    //MARK: - FETCH EVENTS BY TYPE
    func fetchUserAttendingEentsPast(userID: Int, page: Int, completion: UserEventsResultHandler?) {
        //TODO: uncomment for live
        let endpoint = "user/events/attending/past"
        fetchUserEvents(endPoint: endpoint, userID: userID, page: page, completion: completion)
    }
    
    func fetchUserAttendingEentsFuture(userID: Int, page: Int, completion: UserEventsResultHandler?) {
        //TODO: uncomment for live
        let endpoint = "user/events/attending/future"
        fetchUserEvents(endPoint: endpoint, userID: userID, page: page, completion: completion)
    }
    
    func fetchUserHostingEentsPast(userID: Int, page: Int, completion: UserEventsResultHandler?) {
        //TODO: uncomment for live
        let endpoint = "user/events/hosting/past"
        fetchUserEvents(endPoint: endpoint, userID: userID, page: page, completion: completion)
    }
    
    func fetchUserHostingEentsFuture(userID: Int, page: Int, completion: UserEventsResultHandler?) {
        //TODO: uncomment for live
        let endpoint = "user/events/hosting/future"
        fetchUserEvents(endPoint: endpoint, userID: userID, page: page, completion: completion)
    }
    
    private func fetchUserEvents(endPoint: String, userID: Int, page: Int, completion: UserEventsResultHandler?) {
        
        //TODO: uncomment for live
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let headers = ["Content-Type": "application/json",
                       "Authorization": token]
        
        let params = ["user_id": userID,
                      "limit": Constants.Requests.pageSize,
                      "page": page]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            switch result {
            case .success(let data):
                guard let eventsData = data as? [[String: Any]] else {
                        completion?(Result.error(LeapsError.deserializing))
                        return
                }
                
                let events = Event.buildArray(eventsData)
                
                completion?(Result.success(events))
            case .error(let error):
                completion?(Result.error(error))
            }
        }
    }
    
    //MARK: - CREATE EVENT
    func createEvent(eventCreateData: EventCreateData, completion: EventCreateResultHandler?) {
        let endPoint = "event/create"
        guard let token = userManager.authToken else {
            completion?(Result.error(LeapsError.missingToken))
            return
        }
        
        let headers = ["Content-Type": "application/json",
                        "Authorization": token]
        
        let params = eventCreateData.toJSON()
        
        networkManager.put(path: endPoint,
                            params: params,
                            headers: headers) { (result) in
                                switch result {
                                case .success(let eventIDData):
                                    print("eventIDData = \(eventIDData)")
                                    guard let eventIDData = eventIDData as? [String: Any],
                                        let eventID = eventIDData["event_id"] as? Int else {
                                        return
                                    }
                                    completion?(Result.success(eventID))
                                    print("new event id = \(eventID)")
                                case .error(let error):
                                    completion?(Result.error(error))
                                    print("create event erro = \(error)")
                                }
        }
    }
    
    //MARK: - UPLOAD PICTURE
    func upload(imageData: UplodableImage, eventID: Int?) {
        guard let token = userManager.authToken,
            let id = userManager.userID else {
                return
        }
        
        let endPoint: String
        let params: [String: String]
        switch imageData.type {
        case .userMainImage:
             params = ["user_id": id]
            endPoint = "pic/user/main"
        case .userAdditionalImage:
              params = ["user_id": id]
            endPoint = "pic/user"
        case .eventMainImage:
            guard let eventID = eventID else {
                return
            }
            params = ["event_id": "\(eventID)"]
            endPoint = "pic/event/main"
        case .eventAdditionalImage:
            guard let eventID = eventID else {
                return
            }
            params = ["event_id": "\(eventID)"]
            endPoint = "pic/event"
        case .eventRateImage:
            guard let eventID = eventID else {
                return
            }
            endPoint = "pic/rate"
            params = ["rate_id": "\(eventID)"]
            break
        }
        
        let headers = ["Authorization": token]
        
        networkManager.upload(imageData: imageData.imageData,
                              toUrl: endPoint,
                              usingMethod: .post,
                              withParams: params,
                              withHeaders: headers)
    }
}
