//
//  ProfileViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum ProfileRowType {
    case aboutMe(String)
    case edit
    case settings
    case inviteFriends
    case giveFeedback
    case viewHelpTutorial
    case logout
    case becomeTrainer(String, String)
    
    var titleForType: String {
        switch self {
        case .aboutMe:
            return ""
        case .edit:
            return "Edit Profile"
        case .settings:
            return "Settings"
        case .inviteFriends:
            return "Invite Friends"
        case .giveFeedback:
            return "Give Us Feedback"
        case .viewHelpTutorial:
            return "View Help Tutorial Again"
        case .logout:
            return "Log Out"
        case .becomeTrainer:
            return ""
        }
    }
}

enum EditProfileRowType {
    //should be Image
    case userPicture(Image?)
    case trainerPictures(String, [Image]?)
    
//    not in the designs
    case firstName(String)
//    not in the designs
    case lastName(String)
    
    case username(String)
    case gender(String?)
    case birthday(String)
    case location(String?)
    case aboutMe(String?)
    case yearsOfTraining(String)
    case individualSessionPerHour(String)
//    not in the designs
    case phoneNumber(String)
    
    func titleForRow() -> String? {
        switch self {
        case .userPicture:
            return nil
        case .trainerPictures:
            return "Profile picture and background photos"
        case .firstName:
            return "First name"
        case .lastName:
            return "Last name"
        case .username:
            return "Username"
        case .gender:
            return "Gender"
        case .birthday:
            return "Birthday"
        case .location:
            return "Location"
        case .aboutMe:
            return "About me"
        case .yearsOfTraining:
            return "Years of training"
        case .individualSessionPerHour:
            return "Individual session price per hout"
        case .phoneNumber:
            return "Phone number"
        }
    }
    
    func textForType() -> String? {
        switch self {
        case .userPicture:
            return ""
        case .trainerPictures:
            return ""
        case .firstName(let firstName):
            return firstName
        case .lastName(let lastName):
            return lastName
        case .username(let username):
            return username
        case .gender(let gender):
            return gender
        case .birthday(let birthday):
            return birthday
        case .location(let location):
            return location
        case .aboutMe(let description):
            return description
        case .yearsOfTraining(let yearsOfTraining):
            return yearsOfTraining
        case .individualSessionPerHour(let price):
            return price
        case .phoneNumber(let phone):
            return phone
        }
    }
}

struct ProfileSection {
    var items: [ProfileRowType]
}

struct EditProfileSection {
    var items: [EditProfileRowType]
}

class ProfileViewModel: BaseViewModel {
    
    private let service: UserService
    private let userManager: UserManager
    private let dateManager: DateManager
    var user: Dynamic<User?> = Dynamic(nil)
    var seetingsSections: Dynamic<[ProfileSection]> = Dynamic([])
    
    var userUpdateData: UserUpdateData?
    
    var isLoggedIn: Bool {
        return userManager.isLoggedIn
    }
    
    //no concrete reason to make it dynamic right now
    var editProfileSections: Dynamic<[EditProfileSection]> = Dynamic([])
    var numberOfSettingsSections: Int {
        return seetingsSections.value.count
    }
    
    init(service: UserService = UserService(), userManager: UserManager = UserManager.shared, dateManager: DateManager = DateManager.shared) {
        self.service = service
        self.userManager = userManager
        self.dateManager = dateManager
    }
    
    convenience init(user: User, service: UserService = UserService(), userManager: UserManager = UserManager.shared, dateManager: DateManager = DateManager.shared) {
        self.init(service: service, userManager: userManager, dateManager: dateManager)
        self.user.value = user
        userUpdateData = UserUpdateData(user: user)
        setupSettingsRequiredData(with: user)
        setupEditProfileData(with: user)
    }
    
    func logout() {
        userManager.logout()
    }
    
    func numberOfItemsSettings(for section: Int) -> Int {
        return seetingsSections.value[section].items.count
    }
    
    func type(forIndexPath indexPath: IndexPath) -> ProfileRowType {
        return seetingsSections.value[indexPath.section].items[indexPath.row]
    }
    
    func fetchUser(completion: ((Error?) -> Void)? = nil) {
        guard let id = userManager.userID else {
            return
        }
        
        service.fetchUser(forUserWith: id) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.user.value = user
                self?.userUpdateData = UserUpdateData(user: user)
                self?.setupSettingsRequiredData(with: user)
                self?.setupEditProfileData(with: user)
                self?.userManager.set(isTrainer: user.isTrainer)
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func setupSettingsRequiredData(with user: User) {
        var rows: [ProfileRowType] = []
        
        let aboutMe = ProfileRowType.aboutMe(user.description ?? "Edit your profile to show here information about you.")
        rows.append(aboutMe)
        
        let editProfile = ProfileRowType.edit
        rows.append(editProfile)
        
        let settingsRows = ProfileRowType.settings
        rows.append(settingsRows)
        
        let inviteFrieindsRow = ProfileRowType.inviteFriends
        rows.append(inviteFrieindsRow)
        
        let giveFeedbackRow = ProfileRowType.giveFeedback
        rows.append(giveFeedbackRow)
        
        let viewTutorialRow = ProfileRowType.viewHelpTutorial
        rows.append(viewTutorialRow)
        
        let logout = ProfileRowType.logout
        rows.append(logout)
        
        if !user.isTrainer {
            let becomeTrainerRow = ProfileRowType.becomeTrainer("BECOME A TRAINER", "Switch to professional profile and gain access to trainer features.")
            rows.append(becomeTrainerRow)
        }
        
        seetingsSections.value = [ProfileSection(items: rows)]
    }
    
    func setupEditProfileData(with user: User) {
        var rows: [EditProfileRowType] = []
        
        //profile image
        if user.isTrainer {
            let trainerImagesRow = EditProfileRowType.trainerPictures(user.imageURL ?? "", user.images)
            rows.append(trainerImagesRow)
        } else {
            //let profileImageRow = EditProfileRowType.userPicture(user.imageByUrl(url: user.imageURL))
            let profileImageRow = EditProfileRowType.userPicture(Image(id: 0, url: user.imageURL ?? ""))
            rows.append(profileImageRow)
        }
    
        //first name row
        let firstNameRow = EditProfileRowType.firstName(user.firstName)
        rows.append(firstNameRow)
        
        //last name row
        let lastNameRow = EditProfileRowType.lastName(user.lastName)
        rows.append(lastNameRow)
        
        //username row
        let usernameRow = EditProfileRowType.username(user.username)
        rows.append(usernameRow)
        
        //gender row
        let genderRow = EditProfileRowType.gender(user.gender)
        rows.append(genderRow)
        
        //birthday row
        let formatter = dateManager.createEventStandardCellDateFormatter
        let dateAsString = formatter.string(from: user.birthday)
        let birthdayRow = EditProfileRowType.birthday(dateAsString)
        rows.append(birthdayRow)
        
        //location row
        let locationRow = EditProfileRowType.location(user.location)
        rows.append(locationRow)
        
        //about me row
        let aboutMe = EditProfileRowType.aboutMe(user.description)
        rows.append(aboutMe)
        
        //trainer additional rows
        guard let yearsOfTraining = user.yearsOfTraining,
            let trainerPhoneNumber = user.phone,
            let pricePerSession = user.sessionPrice,
            user.isTrainer else {
            editProfileSections.value = [EditProfileSection(items: rows)]
            return
        }
        
        //years of training row
        let yearsOfTrainingRow = EditProfileRowType.yearsOfTraining(String(yearsOfTraining))
        rows.append(yearsOfTrainingRow)
        
        //sesssion price row
        let sessionPriceRow = EditProfileRowType.individualSessionPerHour(String(pricePerSession))
        rows.append(sessionPriceRow)
        
        //phone number row
        let phoneNumberRow = EditProfileRowType.phoneNumber(trainerPhoneNumber)
        rows.append(phoneNumberRow)
        
        editProfileSections.value = [EditProfileSection(items: rows)]
    }
    
    func numberOfItemsEditProfile(for section: Int) -> Int {
        return editProfileSections.value[section].items.count
    }
    
    var numberOfEditProfileSections: Int {
        return editProfileSections.value.count
    }
    
    func editProfileType(forIndexPath indexPath: IndexPath) -> EditProfileRowType {
        return editProfileSections.value[indexPath.section].items[indexPath.row]
    }
    
    func setBirthday(dateAsString: String) {
        let formatter = dateManager.createEventStandardCellDateFormatter
        guard let date = formatter.date(from: dateAsString) else {
            print("bad date entry")
            return
        }
        
        userUpdateData?.birthday = date
    }
    
    func setYearsOfTraining(yearsAsString: String) {
        guard let years = Int(yearsAsString) else {
            return
        }
        
        userUpdateData?.yearsOfTraining = years
    }
    
    func setPricePerSession(priceAsString: String) {
        guard let price = Int(priceAsString) else {
            return
        }
        
        userUpdateData?.pricePerSession = price
    }
    
    func addImage(image: UplodableImage) {
        userUpdateData?.images.append(image)
    }
    
    func removeImage(currentImageID: Int, image: UplodableImage) {
        //related to the deletion of current image
        userUpdateData?.toDeleteImageIDs.append(currentImageID)
        
        //related to the deletion of newly added image for upload 
        guard let index = userUpdateData?.images.index(of: image) else {
            return
        }
        
        userUpdateData?.images.remove(at: index)
    }
    
    func updateProfile(completion: ((Error?) -> Void)? = nil) {
        guard let userUpdateData = userUpdateData else {
            return
        }
        
        service.update(userUpdateData: userUpdateData) { [weak self] result in
            switch result {
            case .success:
                completion?(nil)
                //TODO: Once you are sure it works move it to the completion above
                guard let images = self?.userUpdateData?.images else {
                    return
                }
                
                for image in images {
                    self?.service.upload(imageData: image, eventID: nil)
                }
                
                guard let deleteImageIDs = self?.userUpdateData?.toDeleteImageIDs else {
                    return
                }
                
                for id in deleteImageIDs {
                    self?.service.delete(imageID: id)
                }
                
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func followUser(userID:Int, completion: ((Error?) -> Void)? = nil) {
        service.follow(userID: userID) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.user.value = user
                self?.userUpdateData = UserUpdateData(user: user)
                self?.setupSettingsRequiredData(with: user)
                self?.setupEditProfileData(with: user)
                self?.userManager.set(isTrainer: user.isTrainer)
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
}
