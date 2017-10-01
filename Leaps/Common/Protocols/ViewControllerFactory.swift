//
//  ViewControllerFactory.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//
import UIKit

protocol ViewControllerFactory {
    
    //MARK: - ONBOARDING-
    func createOnboradingStepOneViewController() -> StepViewController?
    func createOnboradingStepTwoViewCotroller() -> StepViewController?
    func createOnboradingStepThreeViewController() -> StepViewController?
    func createOnboradingStepFourViewController() -> StepViewController?
    func createOnboradingStepFiveViewController() -> StepViewController?
    func createOnboardingFlowViewController() -> StepsFlowViewController?
    
    //MARK: - HOME-
    func createHomeViewController() -> HomeViewController?
    
    //MARK: - HOME-ALL ACTIVITIES-
    func createAllActivitiesViewController(type: EventType) -> AllActivitiesViewController?
    
    //MARK: - HOME-TRAINERS-
    func createTrainersViewController() -> TrainersViewController?
    
    //MARK: - REGISTRATION FLOW-
    func createRegistrationFlowViewController(prefilledData: UserSignUpStepsData?, isSocialNetworkRegistration: Bool, onLogin: ((Bool) -> Void)?) -> StepsFlowViewController?
    func createStepOneRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController?
    func createStepTwoRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController?
    func createStepThreeRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController?
    func createStepFourRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController?
    
    //MARK: - LOGIN-
    func createStandardLoginFlowViewController(onLogin: ((Bool) -> Void)?) -> StepsFlowViewController?
    func createLoginViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController?
    
    //MARK: - SEARCH-
    func createSearchViewController(onSearchPressed: @escaping ((SearchEntry) -> Void)) -> SearchViewController?
    
    //MARK: - ACTIVITIES-
    func createActivitiesViewController() -> ActivitiesViewController?
    
    //MARK: - EVENT DETAILS-
    func createEventDetailsViewController(event: Event) -> EventDetailsViewController?
    
    //MARK: - BECOME TRAINER-
    func createBecomeATrainerFlowViewController() -> StepsFlowViewController?
    func createStepOneBecomeTrainerViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController?
    func createStepTwoBecomeTrainerViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController?
    func createStepThreeBecomeTrainerViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController?
    
    //MARK: - FORGOTTEN PASSWORD-
    func createForgottenPasswordFlowViewController() -> StepsFlowViewController?
    func createStepOneForgottenPasswordViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController?
    
    //MARK: - TRAINER PROFILE-
    func createTrainerProfileViewController(trainer: User) -> TrainerDetailsViewController?
    
    //MARK: - CREATE EVENT-
    func createCreateAnEventStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController?
    func createLocationStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController?
    func createPriceAndSlotsStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController?
    func createTimeAndDateStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController?
    func createCreateEventFlow() -> UINavigationController?
    
    //MARK: - EDIT PROFILE
    func createEditProvfileViewController(viewModel: ProfileViewModel) -> EditProfileViewController?
    
    //MARK: - MAX DISTANCE SETTINGS
    func createMaxDistanceSettingsViewController(viewModel: ProfileViewModel) -> MaxDistanseSettingViewController?
    
    //MARK: - USER PROFILE 
    func createUserProfileViewController(user: User) -> UserDetailsViewController?
    
    //MARK: - ATTENDED EVENTS
    func createPastAttendingEventsViewController(events: [Event]) -> EventsListWithNavViewController?
    
    //MARK: - HOSTED EVENTS
    func createPastHostingEventsViewController(events: [Event]) -> EventsListWithNavViewController?
}
