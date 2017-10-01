//
//  StepFlowVIewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum StepFlowType {
    case onboarding
    case registration(UserSignUpStepsData?)
    case becomeTrainer(BecomeTrainerData)
    case login(LoginData)
    case forgottenPassword
    case createEvent(EventCreateData)
    
    func isCancelHidden() -> Bool {
        switch self {
        case .onboarding, .createEvent:
            return true
        case .registration, .becomeTrainer, .login, .forgottenPassword:
            return false
        }
    }
    
    func isSkipHidden() -> Bool {
        switch self {
        case .onboarding, .login:
            return false
        case .registration, .becomeTrainer, .forgottenPassword, .createEvent:
            return true
        }
    }
    
    func titleForTopRigtButton() -> String? {
        switch self {
        case .login:
            return "Forgot password?"
        case .onboarding:
            return "Skip"
        default:
            return nil
        }
    }
    
    func isNextButtonIsHidden() -> Bool {
        switch self {
        case .forgottenPassword:
            return true
        default:
            return false
        }
    }
    
    func titleForBottomButton() -> String? {
        switch self {
        case .createEvent:
            return "PUBLISH YOUR EVENT"
        default:
            return nil
        }
    }
    
    func isBottomButtonLastPageHidden() -> Bool {
        switch self {
        case .createEvent:
            return false
        default:
            return true
        }
    }
}

class StepFlowViewModel: BaseViewModel {
    
    let type: Dynamic<StepFlowType>
    fileprivate let service: UserService
    
    //MARK: Register flow
    fileprivate var userDetails: UserSignUpStepsData?
    
    //MARK: Become Trainer Flow
    fileprivate var becomeTrainderData: BecomeTrainerData?
    
    //MARK: Login Flow
    fileprivate var loginData: LoginData?
    
    //MARK: Forgot Pass Flow
    fileprivate var forgottenPassEmail: String?
    
    //MARK: Create Event Flow
    fileprivate var createEventData: EventCreateData?
    
    fileprivate var userManager: UserManager
    var isInitialOnboardingPresentation: Bool {
        guard let hasSeenOnboarding = userManager.hasSeenOnboarding() else {
            return true
        }
        return !hasSeenOnboarding
    }
    
    init(type: Dynamic<StepFlowType>, service: UserService, userManager: UserManager = UserManager.shared) {//, userDetails: UserSignUpStepsData? = nil) {
        self.type = type
        self.service = service
        self.userManager = userManager
        switch type.value {
        case .onboarding:
            break
        case .registration(let userDetails):
            self.userDetails = userDetails
        case .becomeTrainer(let trainerData):
            self.becomeTrainderData = trainerData
        case  .login(let loginData):
            self.loginData = loginData
        case .forgottenPassword:
            break
        case .createEvent(let createEventData):
            self.createEventData = createEventData
        }
        //TODO: dom't remember why this is here. Remove after successful real requests linkage.
//        self.userDetails = userDetails
    }
    
    func finishAllsteps(completion: ((Error?) -> Void)?) {
        //here make the registraion request
        switch type.value {
        case .onboarding:
            completion?(nil)
        case .registration:
            guard let userDetails = userDetails else {
                print("missing userDetials")
                return
            }
            service.register(userDetails: userDetails, completion: { [weak self] (result) in
                switch result {
                case .success(let userID):
                    self?.userManager.setID(id: userID)
                    self?.userManager.set(isTrainer: false)
                    completion?(nil)
                case .error(let error):
                    completion?(error)
                }
            })
            
        case .becomeTrainer:
            guard let userID = UserManager.shared.userID else {
                let error = LeapsError.missingID
                completion?(error)
                return
            }
            
            guard let sessionPrice = becomeTrainderData?.pricePerSession,
                    let yearsOfTraining = becomeTrainderData?.yearsOfTraining,
                    let phone = becomeTrainderData?.phoneNumber else {
                    print("missing become trainer info")
                    return
            }
            
            service.fetchUser(forUserWith: userID, completion: { [weak self] (result) in
                switch result {
                case .success(let user):
                    //should check if this and the current user are ==
                    let userData = UserUpdateData(user: user)
                    userData.pricePerSession = sessionPrice
                    userData.yearsOfTraining = yearsOfTraining
                    userData.phoneNumber = phone
                    userData.isTrainer = true
                    self?.service.update(userUpdateData: userData) { result in
                        switch result {
                        case .success(let _):
                            completion?(nil)
                        case .error(let error):
                            completion?(error)
                        }
                    }
                case .error(let error):
                    completion?(error)
                }
            })
        case .login:
            guard let username = loginData?.usernameOrEmail, let password = loginData?.password else {
                completion?(LeapsError.missingLoginData)
                return
            }
            
            service.login(username: username, password: password, completion: { (result) in
                switch result {
                case .success(let user):
                    completion?(nil)
                    print("successful login")
                case .error(let error):
                    print("login error = \(error)")
                    completion?(error)
                }
            })
        case .forgottenPassword:
            break
        case .createEvent:
            let idString = userManager.userID ?? "1"
            guard //let idString = userManager.userID,
                    let id = Int(idString),
                    let createEventData = createEventData else {
                return
            }
            createEventData.dateCreated = Date()
            createEventData.ownerID = id
            service.createEvent(eventCreateData: createEventData, completion: { [weak self] (result) in
                switch result {
                case .success(let eventID):
                    for image in createEventData.imagesToUpload {
                        self?.service.upload(imageData: image, eventID: eventID)
                    }
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                    completion?(nil)
                case .error(let error):
                    completion?(error)
                }
            })
        }
    }
}

// User Connectected Entries/ Reusing Register Step VC for
extension StepFlowViewModel: UserEntryDelegate {
    
    //MARK: Forgotten Pass Flow
    func enterForgottenPassEmail(email: String) {
        forgottenPassEmail = email
    }

    func forgottenPasswordPressed(completion: ((Error?) -> Void)?) {
        guard let email = forgottenPassEmail else {
            completion?(LeapsError.missingForgottenPassEmail)
            return
        }
        
        service.forgottenPassword(email: email, completion: completion)
    }
    
    //MARK: Login Flow
    func enterLoginPassword(password: String) {
        loginData?.password = password
    }

    func enterLoginUsernameOrEmail(usenrameOrPass: String) {
        loginData?.usernameOrEmail = usenrameOrPass
    }

    //MARK: Become Trainer Flow
    func enterPhoneNumber(phoneNumber: String) {
        becomeTrainderData?.phoneNumber = phoneNumber
    }

    func enterPricePerSession(pricePerSession: String) {
        becomeTrainderData?.pricePerSession = Int(pricePerSession)
    }

    func enterYearsOfTraining(yearsOfTraining: String) {
        becomeTrainderData?.yearsOfTraining = Int(yearsOfTraining)
    }

    //MARK: Register Flow
    func enterFirstName(firstName: String) {
        userDetails?.firstName = firstName
    }
    
    func enterLastName(lastName: String) {
        userDetails?.lastName = lastName
    }
    
    func enterEimal(email: String) {
        userDetails?.email = email
    }
    
    func enterPassword(password: String) {
        userDetails?.password = password
    }
    
    func enterBirthday(birthday: Date) {
        userDetails?.date = birthday.timeIntervalSince1970Miliseconds
        print(birthday.timeIntervalSince1970Miliseconds)
    }
}

//MARK: - Create Event Flow
extension StepFlowViewModel: EventEntryDelegate {
    func removeImage(image: UplodableImage) {
        guard let index = createEventData?.imagesToUpload.index(of: image) else {
            return
        }

        createEventData?.imagesToUpload.remove(at: index)
    }

    func addImage(image: UplodableImage) {
        createEventData?.imagesToUpload.append(image)
    }

    func enterTime(time: String) {
        let formatter = DateManager.shared.createEventStandardCellTimeFormatter
        guard let date = formatter.date(from: time) else {
            return
        }
        
        createEventData?.timeFrom = date
        createEventData?.timeTo = date
    }

    func enterDate(date: String) {
        let formatter = DateManager.shared.createEventStandardCellDateFormatter
        guard let date = formatter.date(from: date) else {
            return
        }
        
        createEventData?.date = date
    }

    func enterFreeSlots(slots: String) {
        guard let freeSlots = Int(slots) else {
            return
        }
        
        createEventData?.freeSlots = freeSlots
    }

    func enterPrice(price: String) {
        guard let priceAsInt = Int(price) else {
            return
        }
        
        createEventData?.priceFrom = priceAsInt
    }

    func enterLocation(location: String) {
        //TODO: check what is required here
        createEventData?.address = location
        createEventData?.coordLongitude = 0
        createEventData?.coordLatitude = 0
    }

    func removeTag(tag: String) {
        guard let index = createEventData?.tags.index(of: tag) else {
            return
        }
        
        createEventData?.tags.remove(at: index)
    }

    func addTag(tag: String) {
        createEventData?.tags.append(tag)
    }

    func enterDescription(description: String) {
        createEventData?.description = description
    }

    func enterTitle(title: String) {
        createEventData?.title = title
    }
}